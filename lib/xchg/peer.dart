import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:gazer_client/xchg/billing_for_address.dart';
import 'package:gazer_client/xchg/network.dart';
import 'package:gazer_client/xchg/remote_peer.dart';
import 'package:gazer_client/xchg/frame_writer.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';

import 'network_container.dart';
import 'rsa.dart';
import 'session.dart';
import 'transaction.dart';
import 'utils.dart';

class XchgServerProcessor {}

class Peer {
  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair = generateRSAkeyPair();
  bool started = false;
  bool stopping = false;

  DateTime lastNetworkUpdateTime = DateTime.now();
  XchgNetwork? network;

  XchgServerProcessor? processor;

  // Client
  Map<String, RemotePeer> remotePeers = {};
  //Map<String, BillingInfo> routersBillingInfo = {};

  // Server
  Map<String, Transaction> incomingTransactions = {};
  Map<int, Session> sessionsById = {};
  late Timer _timer;
  bool useLocalRouter = false;
  String networkId = "";

  Map<String, String> addressByName = {};

  Map<String, int> metrics = {};
  Map<String, int> metricsLast = {};
  Map<String, int> metricsRelease = {};

  Peer(AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>? privKey,
      this.useLocalRouter, this.networkId) {
    print("PEER CREATED! local: $useLocalRouter networkId: $networkId");

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

  String address() {
    String localAddress = addressForPublicKey(keyPair.publicKey);
    return localAddress;
  }

  bool usingLocalRouter(String address) {
    RemotePeer? remotePeer;
    if (remotePeers.containsKey(address)) {
      remotePeer = remotePeers[address];
    }
    if (remotePeer == null) {
      return false;
    }
    return remotePeer.usingLocalRouter();
  }

  bool usingDirectConnection() {
    if (networkId.isNotEmpty) {
      if (networkId.startsWith("addr#")) {
        return true;
      }
    }
    return false;
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

  Map<String, int> lastReceivedMessageId = {};
  //bool requestingFromInternet = false;
  Set<String> requestingFromInternet = {};

  Future<void> requestFramesFromInternet(String host) async {
    if (requestingFromInternet.contains(host)) {
      return;
    }

//    String localAddress = addressForPublicKey(keyPair.publicKey);

//    updateBillingInfo(host, localAddress);

    requestingFromInternet.add(host);
    Uint8List localAddressBS = addressBSForPublicKey(keyPair.publicKey);
    Uint8List getMessagesRequest = Uint8List(16 + 30);

    int lastReceivedMessageIdRouter = 0;
    if (lastReceivedMessageId.containsKey(host)) {
      lastReceivedMessageIdRouter = lastReceivedMessageId[host]!;
    }

    getMessagesRequest.buffer.asUint64List(0)[0] = lastReceivedMessageIdRouter;
    getMessagesRequest.buffer.asUint64List(8)[0] = 1024 * 1024;
    copyBytes(getMessagesRequest, 16, localAddressBS);

    Uint8List res = Uint8List(0);

    httpCall(host, "r", getMessagesRequest).then((res) {
      if (res.length >= 8) {
        lastReceivedMessageIdRouter = res.buffer.asUint64List(0)[0];
        lastReceivedMessageId[host] = lastReceivedMessageIdRouter;

        int offset = 8;
        while (offset < res.length) {
          if (offset + 128 < res.length) {
            var tempBuf = res.sublist(offset);
            int frameLen = tempBuf.buffer.asUint32List(0)[0];
            if (offset + frameLen <= res.length) {
              Uint8List frame = res.sublist(offset, offset + frameLen);
              processFrame(host, frame);
            } else {
              break;
            }
            offset += frameLen;
          } else {
            break;
          }
        }
      }
      requestingFromInternet.remove(host);
    }).catchError((err) {
      print("catchError read $err");
      requestingFromInternet.remove(host);
    });
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
      var networkFromInternet = await networkContainerLoadFromInternet();

      int existingNetworkTimestamp = 0;
      if (network != null) {
        existingNetworkTimestamp = network!.timestamp;
      }

      //network = networkFromInternet;
      if (network == null ||
          networkFromInternet.timestamp > existingNetworkTimestamp) {
        network = networkFromInternet;
      }
    } catch (ex) {
      print("networkContainerLoadFromInternet ex $ex");
    }
    updatingNetwork = false;
  }

  void addMetric(String code, int value) {
    if (metrics.containsKey(code)) {
      int oldValue = metrics[code]!;
      metrics[code] = oldValue + value;
    } else {
      metrics[code] = value;
    }
  }

  void releaseMetrics() {
    for (String code in metrics.keys) {
      int value = metrics[code]!;
      int lastValue = 0;
      if (metricsLast.containsKey(code)) {
        lastValue = metricsLast[code]!;
      }
      metricsLast[code] = value;

      int delta = value - lastValue;
      metricsRelease[code] = delta;
    }
    metricsLast = metrics;
    metrics = {};
  }

  Map<String, Dio> httpClients = {};

  int wcounter = 0;

  Future<Uint8List> httpCall(
      String routerHost, String function, Uint8List frame) async {
    //throw "Ex";
    //print("httpCall $routerHost $function");
    wcounter++;
    Dio? dio;
    if (httpClients.containsKey("$routerHost-$function")) {
      dio = httpClients["$routerHost-$function"];
    } else {
      //HttpClient.enableTimelineLogging = false;
      dio = Dio();
      dio.options.connectTimeout = const Duration(milliseconds: 1000);
      dio.options.sendTimeout = const Duration(milliseconds: 1000);
      dio.options.receiveDataWhenStatusError = true;
      //dio.options.persistentConnection = false;
      if (function == "w") {
        dio.options.receiveTimeout = const Duration(milliseconds: 1000);
      }
      if (function == "r") {
        print("Read from $routerHost");
        dio.options.receiveTimeout = const Duration(milliseconds: 1000);
      }
      httpClients["$routerHost-$function"] = dio;
    }

    if (dio != null) {
      CancelToken cancelToken = CancelToken();
      try {
        final formData = FormData.fromMap({
          'd': base64Encode(frame),
        });

        //print("----- SEND: ${formData.length}");

        addMetric("http-send-$routerHost-$function", formData.length);

        final response = await dio.post('http://$routerHost/api/$function',
            data: formData, cancelToken: cancelToken);
        cancelToken.cancel();
        if (response.statusCode == 200) {
          if (response.data == null) {
            return Uint8List(0);
          }
          addMetric("http-recv-$routerHost-$function", response.data.length);

          //print("----- RCV: ${response.data.length}");
          var resStr = base64Decode(response.data);
          return resStr;
        }
      } catch (ex) {
        cancelToken.cancel();
        //print("httpCall exception $function exception: $ex $wcounter");
      } finally {}
    }
    return Uint8List(0);
    //throw "Exception: status code";
  }

  String remotePeerTransport(String address) {
    if (!address.startsWith("#")) {
      if (addressByName.containsKey(address)) {
        address = addressByName[address]!;
      }
    }
    if (!address.startsWith("#")) {
      return "";
    }
    RemotePeer? remotePeer;
    for (RemotePeer peer in remotePeers.values) {
      if (peer.remoteAddress == address) {
        remotePeer = peer;
        break;
      }
    }

    if (remotePeer != null) {
      return remotePeer.lastSuccessTransactionTransport();
    }
    return "peer not found";
  }

  BillingDB billingDB = BillingDB();
  BillingSummary billingInfoForAddress(String address) {
    bool isDirectConnection = false;
    if (network != null) {
      isDirectConnection = network!.isDirectConnection;
    }

    String localAddress = addressForPublicKey(keyPair.publicKey);

    BillingSummary summary = billingDB.getSummaryForAddresses(
      network,
      localAddress,
      address,
      usingLocalRouter(address),
      isDirectConnection,
    );
    return summary;
  }

  Future<void> processFrame(String router, Uint8List frame) async {
    // Min size of frame is 128 bytes
    if (frame.length < 128) {
      return;
    }

    // Parse frame
    Transaction transaction = Transaction.fromBinary(frame, 0, frame.length);

    // Parse frame type
    switch (transaction.frameType) {
      case 0x10:
        processFrame10(transaction);
        break;
      case 0x11:
        processFrame11(router, transaction);
        break;
      case 0x20:
        processFrame20(frame);
        break;
      case 0x21:
        processFrame21(frame);
        break;
      default:
    }
  }

// ----------------------------------------
// Incoming Call - Server Role
// ----------------------------------------

  void processFrame10(Transaction transaction) {
    //Transaction transaction = Transaction.fromBinary(frame, 0, frame.length);

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
        transaction.srcAddress + "-" + transaction.transactionId.toString();
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

  void processFrame11(String router, Transaction transaction) {
    transaction.transportType = "HTTP $router";

    RemotePeer? remotePeer;
    for (RemotePeer peer in remotePeers.values) {
      if (peer.remoteAddress == transaction.srcAddress) {
        remotePeer = peer;
        break;
      }
    }
    if (remotePeer != null) {
      transaction.srcRouterAddr = router;
      remotePeer.processFrame(transaction);
    }
  }

  // Get Public Key
  void processFrame20(Uint8List frame) {
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
    sendFrame([response], this, false);
  }

  // Get Public Key Response
  void processFrame21(Uint8List frame) {
    try {
      Uint8List receivedPublicKeyBS = frame.sublist(128 + 16 + 256);
      var receivedPublicKey = decodePublicKeyFromPKIX(receivedPublicKeyBS);
      String receivedAddress = addressForPublicKey(receivedPublicKey);
      for (var peer in remotePeers.values) {
        if (peer.remoteAddress == receivedAddress) {
          peer.setRemotePublicKey(
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
    if (networkId.isNotEmpty) {
      if (networkId.startsWith("addr#")) {
        network =
            XchgNetwork.directAddressRouter(networkId.replaceAll("addr#", ""));
        return;
      }
      return;
    }

    var diffSec = lastNetworkUpdateTime.difference(DateTime.now()).inSeconds;
    if (network == null || diffSec.abs() > 10) {
      updateNetwork();
      lastNetworkUpdateTime = DateTime.now();
    }
  }

  Future<String> getAddressByName(String name) async {
    if (network != null) {
      Map<String, int> responses = {};
      const int requestCount = 3;
      for (int i = 0; i < requestCount; i++) {
        String node = network!.getRandomNode();
        String response = await httpGet("http://$node/api/ns?name=$name", 1000);
        if (response.startsWith("#") && response.length == 49) {
          int? counter = responses[response];
          if (counter == null) {
            responses[response] = 1;
          } else {
            responses[response] = counter + 1;
          }
        }
      }

      for (var resp in responses.keys) {
        int count = responses[resp]!;
        if (count >= requestCount / 2 + 1) {
          return resp;
        }
      }
      throw "no consensus";
    }
    throw "no xchg network";
  }

  Future<CallResult> call(String remoteAddress, String authData,
      String function, Uint8List data) async {
    RemotePeer? remotePeer;
    CallResult? res;
    res = CallResult();

    // print("Call $remoteAddress");

    // Update network file
    checkNetwork();

    if (!remoteAddress.startsWith("#")) {
      if (!addressByName.containsKey(remoteAddress)) {
        try {
          String addressFromNetwork = await getAddressByName(remoteAddress);
          addressByName[remoteAddress] = addressFromNetwork;
          remoteAddress = addressFromNetwork;
        } catch (ex) {
          return CallResult.createError("cannot resolve name: $ex");
        }
      } else {
        var addr = addressByName[remoteAddress];
        if (addr != null) {
          remoteAddress = addr;
        }
      }
    }

    if (remoteAddress.length != 49 || !remoteAddress.startsWith("#")) {
      return CallResult.createError("wrong address format");
    }

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
