import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:gazer_client/xchg/network.dart';
import 'package:gazer_client/xchg/remote_peer.dart';
import 'package:gazer_client/xchg/request_udp.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';

import 'network_container.dart';
import 'rsa.dart';
import 'session.dart';
import 'transaction.dart';
import 'udp_address.dart';
import 'utils.dart';

import 'package:http/http.dart' as http;

class XchgServerProcessor {}

class Peer {
  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair = generateRSAkeyPair();
  bool started = false;
  bool stopping = false;

  DateTime lastNetworkUpdateTime = DateTime.now();
  XchgNetwork? network;

  XchgServerProcessor? processor;

  static int udpStartPort = 42000;
  static int udpEndPort = 42031;

  bool currentUdpPortTrying = false;
  bool currentUdpPortValid = false;

  // Client
  Map<String, RemotePeer> remotePeers = {};

  // Server
  Map<String, Transaction> incomingTransactions = {};
  Map<int, Session> sessionsById = {};
  late Timer _timer;
  bool useLocalRouter = false;

  Peer(AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>? privKey,
      this.useLocalRouter) {
    print("PEER CREATED!");

    if (privKey == null) {
      AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> pair =
          generateRSAkeyPair();
      privKey = pair;
    }
    keyPair = privKey;

    requestIncomingFramesFromInternet();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      requestIncomingFramesFromInternet();
    });
  }

  void requestIncomingFramesFromInternet() {
    checkNetwork();
    if (network != null) {
      String localAddress = addressForPublicKey(keyPair.publicKey);
      var routers = network!.getNodesAddressesByAddress(localAddress);
      for (var router in routers) {
        requestFramesFromInternet(router);
      }
    }
  }

  void start() {}

  void stop() {
    _timer.cancel();
  }

  int lastReceivedMessageId = 0;
  bool requestingFromInternet = false;

  Future<void> requestFramesFromInternet(String host) async {
    if (requestingFromInternet) {
      return;
    }

    requestingFromInternet = true;
    Uint8List localAddressBS = addressBSForPublicKey(keyPair.publicKey);
    Uint8List getMessagesRequest = Uint8List(16 + 30);
    getMessagesRequest.buffer.asUint64List(0)[0] = lastReceivedMessageId;
    getMessagesRequest.buffer.asUint64List(8)[0] = 1024 * 1024;
    copyBytes(getMessagesRequest, 16, localAddressBS);

    Uint8List res = Uint8List(0);
    try {
      res = await httpCall(host, "r", getMessagesRequest, 20000);
    } catch (err) {
      print("ex: $err");
    }
    if (res.length >= 8) {
      lastReceivedMessageId = res.buffer.asUint64List(0)[0];
      int offset = 8;
      while (offset < res.length) {
        if (offset + 128 < res.length) {
          var tempBuf = res.sublist(offset);
          int frameLen = tempBuf.buffer.asUint32List(0)[0];
          if (offset + frameLen <= res.length) {
            Uint8List frame = res.sublist(offset, offset + frameLen);
            processFrame(null, host, frame);
          } else {
            break;
          }
          offset += frameLen;
        } else {
          break;
        }
      }
    }
    requestingFromInternet = false;
  }

  bool updatingNetwork = false;
  Future<void> updateNetwork() async {
    if (updatingNetwork) {
      return;
    }

    if (useLocalRouter) {
      network = XchgNetwork.localRouter();
      return;
    }
    updatingNetwork = true;
    try {
      network = await networkContainerLoadFromInternet();
      if (network != null) {
        /*print(
            "networkContainerLoadFromInternet ok ${network!.name} source:${network!.debugSource}");*/
      }
    } catch (ex) {
      print("networkContainerLoadFromInternet ex $ex");
    }
    updatingNetwork = false;
  }

  Map<String, http.Client> httpClients = {};

  Future<Uint8List> httpCall(String routerHost, String function,
      Uint8List frame, int timeoutMs) async {
    //print("httpCall $routerHost $function");
    http.Client? client;
    if (httpClients.containsKey(routerHost)) {
      client = httpClients[routerHost];
    } else {
      HttpClient.enableTimelineLogging = false;
      client = http.Client();
      httpClients[routerHost] = client;
    }

    if (client != null) {
      try {
        var req = http.MultipartRequest(
            'POST', Uri.parse("http://$routerHost/api/$function"));
        req.fields['d'] = base64Encode(frame);
        http.Response response = await http.Response.fromStream(
            await client.send(req).timeout(Duration(milliseconds: timeoutMs)));
        if (response.statusCode == 200) {
          var resStr = base64Decode(response.body);
          return resStr;
        }
      } catch (ex) {
        print("exception $function exception: $ex");
      } finally {}
    }
    throw "Exception: status code";
  }

  Future<void> processFrame(
      UdpAddress? sourceAddress, String router, Uint8List frame) async {
    // Min size of frame is 128 bytes
    if (frame.length < 128) {
      return;
    }

    int frameType = frame[8];
    switch (frameType) {
      case 0x10:
        processFrame10(sourceAddress, frame);
        break;
      case 0x11:
        processFrame11(sourceAddress, router, frame);
        break;
      case 0x20:
        processFrame20(sourceAddress, frame);
        break;
      case 0x21:
        processFrame21(sourceAddress, frame);
        break;
      default:
    }
  }

// ----------------------------------------
// Incoming Call - Server Role
// ----------------------------------------

  void processFrame10(UdpAddress? sourceAddress, Uint8List frame) {
    Transaction transaction = Transaction.fromBinary(frame, 0, frame.length);

    List<String> transactionsToRemove = [];
    for (var trKey in incomingTransactions.keys) {
      Transaction? incomingTransaction = incomingTransactions[trKey];
      if (incomingTransaction != null) {
        var diff = DateTime.now().difference(incomingTransaction.dtBegin);
        if (diff.inSeconds > 10) {
          transactionsToRemove.add(trKey);
        }
      }
    }
    for (String trKey in transactionsToRemove) {
      incomingTransactions.remove(trKey);
    }

    Transaction incomingTransaction =
        Transaction(0, "", "", 0, 0, 0, 0, Uint8List(0));

    String incomingTransactionCode =
        sourceAddress.toString() + "-" + transaction.transactionId.toString();
    if (incomingTransactions.containsKey(incomingTransactionCode)) {
      incomingTransaction = incomingTransactions[incomingTransactionCode]!;
    } else {
      incomingTransaction = Transaction(0, "", "", 0, 0, 0, 0, Uint8List(0));
      incomingTransaction.frameType = transaction.frameType;
      incomingTransaction.transactionId = transaction.frameType;
      incomingTransaction.sessionId = transaction.frameType;
      incomingTransaction.offset = 0;
      incomingTransaction.totalSize = transaction.totalSize;
      incomingTransaction.dtBegin = DateTime.now();
      incomingTransaction.srcAddress = transaction.srcAddress;
      incomingTransaction.destAddress = transaction.destAddress;
    }

    if (incomingTransaction.data.length != incomingTransaction.totalSize) {
      incomingTransaction.data = Uint8List(incomingTransaction.totalSize);
    }

    for (int i = 0; i < transaction.data.length; i++) {
      int targetIndex = transaction.offset + i;
      if (targetIndex < incomingTransaction.data.length) {
        incomingTransaction.data[targetIndex] = transaction.data[i];
      }
    }
    incomingTransaction.receivedDataLen += transaction.data.length;

    if (incomingTransaction.receivedDataLen < incomingTransaction.totalSize) {
      return;
    }

    incomingTransactions.remove(incomingTransactionCode);

    {
      // TODO: process Call
    }
  }

  void processFrame11(
      UdpAddress? sourceAddress, String router, Uint8List frame) {
    Transaction transaction = Transaction.fromBinary(frame, 0, frame.length);
    RemotePeer? remotePeer;
    for (RemotePeer peer in remotePeers.values) {
      if (peer.remoteAddress == transaction.srcAddress) {
        remotePeer = peer;
        break;
      }
    }
    if (remotePeer != null) {
      transaction.srcUdpAddr = sourceAddress;
      transaction.srcRouterAddr = router;
      remotePeer.processFrame(transaction);
    }
  }

  // ARP LAN request
  void processFrame20(UdpAddress? sourceAddress, Uint8List frame) {
    String localAddress = addressForPublicKey(keyPair.publicKey);
    Uint8List nonce = frame.sublist(8, 8 + 16);
    Uint8List nonceHash = Uint8List.fromList(sha256.convert(nonce).bytes);
    String requestedAddress = utf8.decode(frame.sublist(8 + 16));
    if (requestedAddress != localAddress) {
      return; // This is not my address
    }
    // Send my public key
    Uint8List publicKeyBS = encodePublicKeyToPKIX(keyPair.publicKey);
    Uint8List signature = rsaSign(keyPair.privateKey, nonceHash);
    Uint8List response = Uint8List(0);
    response.addAll(frame.sublist(0, 8));
    response[0] = 0x21;
    response.addAll(nonce);
    response.addAll(signature);
    response.addAll(publicKeyBS);
    sendFrame(sourceAddress, [response], this);
  }

  // ARP LAN response
  void processFrame21(UdpAddress? sourceAddress, Uint8List frame) {
    try {
      Uint8List receivedPublicKeyBS = frame.sublist(128 + 16 + 256);
      var receivedPublicKey = decodePublicKeyFromPKIX(receivedPublicKeyBS);
      String receivedAddress = addressForPublicKey(receivedPublicKey);
      for (var peer in remotePeers.values) {
        if (peer.remoteAddress == receivedAddress) {
          peer.setRemotePublicKey(
              sourceAddress,
              receivedPublicKey,
              frame.sublist(128, 128 + 16),
              frame.sublist(128 + 16, 128 + 16 + 256));
        }
      }
    } catch (ex) {
      print("Exception (0x21)" + ex.toString());
    }
  }

  void checkNetwork() {
    var diffSec = lastNetworkUpdateTime.difference(DateTime.now()).inSeconds;
    if (network == null || diffSec.abs() > 10) {
      updateNetwork();
      lastNetworkUpdateTime = DateTime.now();
    }
  }

  Future<CallResult> call(String remoteAddress, String authData,
      String function, Uint8List data) async {
    RemotePeer? remotePeer;
    CallResult? res;
    res = CallResult();

    // Update network file
    checkNetwork();

    try {
      // Waiting for socket
      if (remotePeers.containsKey(remoteAddress)) {
        remotePeer = remotePeers[remoteAddress];
      } else {
        remotePeer = RemotePeer(this, remoteAddress, authData, keyPair);
        remotePeers[remoteAddress] = remotePeer;
      }
      res = await remotePeer!.call(function, data);
    } catch (err) {
      return CallResult.createError(err.toString());
    }
    return res;
  }
}
