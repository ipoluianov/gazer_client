import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
//import 'package:gazer_client/core/xchg/xchg.dart';
import 'package:gazer_client/xchg/network.dart';
import 'package:gazer_client/xchg/remote_peer.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';

import 'rsa.dart';
import 'session.dart';
import 'transaction.dart';
import 'udp_address.dart';
import 'utils.dart';
import 'package:base32/base32.dart';

class XchgServerProcessor {}

class Peer {
  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair = generateRSAkeyPair();
  String localAddress = "";
  bool started = false;
  bool stopping = false;
  XchgNetwork network = XchgNetwork("", "", "", [], []);
  XchgServerProcessor? processor;

  static int udpStartPort = 42000;
  static int udpEndPort = 42100;
  int currentUdpPort = 42000;
  bool currentUdpPortTrying = false;
  bool currentUdpPortValid = false;
  //RawDatagramSocket? socket;

  // Client
  Map<String, RemotePeer> remotePeers = {};

  // Server
  Map<String, Transaction> incomingTransactions = {};
  Map<int, Session> sessionsById = {};
  late Timer _timer;

  Peer(AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>? privKey) {
    print("PEER CREATED!");

    if (privKey == null) {
      AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> pair =
          generateRSAkeyPair();
      privKey = pair;
    }
    keyPair = privKey;

    _timer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      //checkConnection();
    });
  }

  void start() {}

  void stop() {
    _timer.cancel();
  }

  Future<void> requestUDP(UdpAddress address, List<Uint8List> frames) async {
    print("requestUDP: $address");
    InternetAddress bindAddr = InternetAddress.anyIPv4;

    /*if (address.address.type == InternetAddressType.IPv6) {
      bindAddr = InternetAddress.anyIPv6;
    }*/

    //String addrStr = address.address.rawAddress[];

    if (address.address.rawAddress.length == 16) {
      if (address.address.rawAddress[10] == 255 &&
          address.address.rawAddress[11] == 255) {
        address = UdpAddress(
            InternetAddress.fromRawAddress(
                address.address.rawAddress.sublist(12)),
            address.port);
      }
    }

    print("ADDR: ${address.address.rawAddress}");

    //address = UdpAddress(InternetAddress("127.0.0.1"), address.port);

    var udpSocket = await RawDatagramSocket.bind(bindAddr, 0);
    udpSocket.broadcastEnabled = true;
    udpSocket.listen(
        (event) {
          if (event == RawSocketEvent.write) {
            for (var fr in frames) {
              udpSocket.send(fr, address.address, address.port);
            }
          }
          if (event == RawSocketEvent.read) {
            Datagram? dg = udpSocket.receive();
            if (dg != null) {
              processFrame(UdpAddress(dg.address, dg.port), dg.data);
            }
            //udpSocket.close();
          }

          if (event == RawSocketEvent.closed) {
            udpSocket.close();
          }
          if (event == RawSocketEvent.readClosed) {
            udpSocket.close();
          }
        },
        cancelOnError: true,
        onDone: () {
          udpSocket.close();
        },
        onError: (err) {
          udpSocket.close();
        });

    await Future.delayed(const Duration(milliseconds: 2000));
    udpSocket.close();
  }

  void processFrame(UdpAddress sourceAddress, Uint8List frame) {
    print("received: $sourceAddress ${frame.length} ${frame[0]}");

    if (frame.length < 8) {
      return;
    }

    int frameType = frame[0];

    switch (frameType) {
      case 0x00:
        processFrame00(sourceAddress, frame);
        break;
      case 0x01:
        processFrame01(sourceAddress, frame);
        break;
      case 0x02:
        processFrame02(sourceAddress, frame);
        break;
      case 0x03:
        processFrame03(sourceAddress, frame);
        break;
      case 0x07:
        processFrame07(sourceAddress, frame);
        break;
      case 0x10:
        processFrame10(sourceAddress, frame);
        break;
      case 0x11:
        processFrame11(sourceAddress, frame);
        break;
      case 0x20:
        processFrame20(sourceAddress, frame);
        break;
      case 0x21:
        processFrame21(sourceAddress, frame);
        break;
      case 0x22:
        processFrame22(sourceAddress, frame);
        break;
      case 0x23:
        processFrame23(sourceAddress, frame);
        break;
      default:
    }
  }

  // Ping
  void processFrame00(UdpAddress sourceAddress, Uint8List frame) {
    frame[0] = 0x01;
    frame[1] = 0x00;
    //socket.send(frame, sourceAddress.address, sourceAddress.port);
    requestUDP(sourceAddress, [frame]);
  }

  void processFrame01(UdpAddress sourceAddress, Uint8List frame) {}

// ----------------------------------------
// Nonce
// ----------------------------------------

  void processFrame02(UdpAddress sourceAddress, Uint8List frame) {
    // nothing to do
  }
  void processFrame03(UdpAddress sourceAddress, Uint8List frame) {
    if (frame[1] != 0) {
      return;
    }
    if (frame.length != 8 + 16) {
      return;
    }

    Uint8List nonce = frame.sublist(8);

    Uint8List data = Uint8List(0);
    Uint8List request = Uint8List(8);
    request[0] = 0x02;
    request[1] = 0x00;
    request[2] = 0x00;
    request[3] = 0x00;
    request[4] = 0x00;
    request[5] = 0x00;
    request[6] = 0x00;
    request[7] = 0x00;
    request.addAll(nonce);
    request.addAll(Uint8List(8));

    var signature = rsaSign(keyPair.privateKey, request.sublist(8, 32));
    request.addAll(signature);

    var publicKeyBS = encodePublicKeyToPemPKCS1(keyPair.publicKey);
    request.addAll(Uint8List(4));
    request.buffer.asInt32List(288)[0] = publicKeyBS.length;
    request.addAll(publicKeyBS);
    request.addAll(data);

    //socket.send(request, sourceAddress.address, sourceAddress.port);
    requestUDP(sourceAddress, [request]);
  }

  void processFrame07(UdpAddress sourceAddress, Uint8List frame) {
    List<int> addressBS = [];
    int dataOffset = -1;
    for (int i = 8; i < frame.length; i++) {
      var ch = frame[i];
      if (ch == 61) {
        // '='
        dataOffset = i + 1;
        break;
      } else {
        addressBS.add(frame[i]);
      }
    }

    var address = utf8.decode(addressBS);

    print("Received data from XCHGR $address");
    for (int i = dataOffset; i < frame.length; i += 32) {
      var type0 = frame[i];
      var type1 = frame[i + 1];
      var ipAddrAsList = frame.sublist(i + 2, i + 2 + 16);
      String ipAddr = frame.sublist(i + 2, i + 2 + 16).toString();
      int port = frame.buffer.asUint16List(i + 18)[0];
      print(" - $type0 $type1 $ipAddr $port");

      String addrHex = "";

      for (int q = 0; q < 16; q++) {
        if ((q % 2) == 0 && q != 0) {
          addrHex += ":";
        }

        var hh = ipAddrAsList[q].toRadixString(16);
        if (hh.length < 2) {
          hh = "0" + hh;
        }

        addrHex += hh;
      }

      InternetAddress addr = InternetAddress(addrHex);
      //print("------------- HEX:" + addrHex + " - " + addr.toString());

      UdpAddress udpAddress = UdpAddress(addr, port);

      /*for (var remotePeer in remotePeers.values) {
        remotePeer.setInternetConnectionPoint(address, udpAddress);
      }*/
    }
  }

// ----------------------------------------
// Incoming Call - Server Role
// ----------------------------------------

  void processFrame10(UdpAddress sourceAddress, Uint8List frame) {
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

    Transaction incomingTransaction = Transaction();

    String incomingTransactionCode =
        sourceAddress.toString() + "-" + transaction.transactionId.toString();
    if (incomingTransactions.containsKey(incomingTransactionCode)) {
      incomingTransaction = incomingTransactions[incomingTransactionCode]!;
    } else {
      incomingTransaction = Transaction();
      incomingTransaction.frameType = transaction.frameType;
      incomingTransaction.transactionId = transaction.frameType;
      incomingTransaction.sessionId = transaction.frameType;
      incomingTransaction.offset = 0;
      incomingTransaction.totalSize = transaction.totalSize;
      incomingTransaction.dtBegin = DateTime.now();
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

  void processFrame11(UdpAddress sourceAddress, Uint8List frame) {
    RemotePeer? remotePeer;
    String receivedFromConnectionPoint =
        RemotePeer.connectionPointString(sourceAddress);
    for (RemotePeer peer in remotePeers.values) {
      String lanPoint = peer.lanConnectionPointString();
      if (lanPoint == receivedFromConnectionPoint) {
        remotePeer = peer;
        break;
      }
      /*String inPoint = peer.internetConnectionPointString();
      if (inPoint == receivedFromConnectionPoint) {
        remotePeer = peer;
        break;
      }*/
    }
    if (remotePeer != null) {
      remotePeer.processFrame(sourceAddress, frame);
    }
  }

  // ARP LAN request
  void processFrame20(UdpAddress sourceAddress, Uint8List frame) {
    String localAddress = addressForPublicKey(keyPair.publicKey);
    Uint8List nonce = frame.sublist(8, 8 + 16);
    Uint8List nonceHash = Uint8List.fromList(sha256.convert(nonce).bytes);
    String requestedAddress = utf8.decode(frame.sublist(8 + 16));
    if (requestedAddress != localAddress) {
      return; // This is not my address
    }
    // Send my public key
    Uint8List publicKeyBS = encodePublicKeyToPemPKCS1(keyPair.publicKey);
    Uint8List signature = rsaSign(keyPair.privateKey, nonceHash);
    Uint8List response = Uint8List(0);
    response.addAll(frame.sublist(0, 8));
    response[0] = 0x21;
    response.addAll(nonce);
    response.addAll(signature);
    response.addAll(publicKeyBS);
    requestUDP(sourceAddress, [response]);
    //socket.send(response, sourceAddress.address, sourceAddress.port);
  }

  // ARP LAN response
  void processFrame21(UdpAddress sourceAddress, Uint8List frame) {
    Uint8List receivedPublicKeyBS = frame.sublist(8 + 16 + 256);
    var receivedPublicKey = decodePublicKeyFromPKCS1(receivedPublicKeyBS);
    String receivedAddress = addressForPublicKey(receivedPublicKey);
    for (var peer in remotePeers.values) {
      if (peer.remoteAddress == receivedAddress) {
        peer.setLANConnectionPoint(sourceAddress, receivedPublicKey,
            frame.sublist(8, 8 + 16), frame.sublist(8 + 16, 8 + 16 + 256));
      }
    }
  }

  // Get Public Key request
  void processFrame22(UdpAddress sourceAddress, Uint8List frame) {
    String localAddress = addressForPublicKey(keyPair.publicKey);
    String requestedAddress = utf8.decode(frame.sublist(8));
    if (requestedAddress != localAddress) {
      return; // This is not my address
    }
    // Send my public key
    Uint8List publicKeyBS = encodePublicKeyToPemPKCS1(keyPair.publicKey);
    Uint8List response = Uint8List(0);
    response.addAll(frame.sublist(0, 8));
    response[0] = 0x23;
    response.addAll(publicKeyBS);
    requestUDP(sourceAddress, [response]);
    //socket.send(response, sourceAddress.address, sourceAddress.port);
  }

  // Get Public Key response
  void processFrame23(UdpAddress sourceAddress, Uint8List frame) {
    Uint8List receivedPublicKeyBS = frame.sublist(8);
    var receivedPublicKey = decodePublicKeyFromPKCS1(receivedPublicKeyBS);
    String receivedAddress = addressForPublicKey(receivedPublicKey);
    for (var peer in remotePeers.values) {
      if (peer.remoteAddress == receivedAddress) {
        peer.setRemotePublicKey(receivedPublicKey);
      }
    }
  }

  void processFrame24(UdpAddress sourceAddress, Uint8List frame) {}

  void setProcessor(XchgServerProcessor processor) {}

  Future<CallResult> call(String remoteAddress, String authData,
      String function, Uint8List data) async {
    RemotePeer? remotePeer;
    CallResult? res;
    try {
      // Waiting for socket
      if (remotePeers.containsKey(remoteAddress)) {
        remotePeer = remotePeers[remoteAddress];
      } else {
        remotePeer =
            RemotePeer(this, remoteAddress, authData, keyPair, network);
        remotePeers[remoteAddress] = remotePeer;
      }
      res = await remotePeer!.call(function, data);
    } catch (err) {
      return CallResult.createError(err.toString());
    }
    return res;
  }
}
