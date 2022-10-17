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
  RawDatagramSocket? socket;

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
      checkConnection();
    });
  }

  void start() {}

  void stop() {
    _timer.cancel();
  }

  void checkConnection() {
    if (currentUdpPortValid || currentUdpPortTrying) {
      return;
    }

    currentUdpPort++;
    currentUdpPortTrying = true;

    //var address = InternetAddress('0.0.0.0');
    print("binding udp port $currentUdpPort");

    RawDatagramSocket.bind(InternetAddress("127.0.0.1"), 42009,
            reuseAddress: false, reusePort: false)
        .then((udpSocket) {
      print("binding udp port OK");
      //udpSocket.setRawOption(RawSocketOption(RawSocketOption.levelSocket, ));
      socket = udpSocket;
      udpSocket.broadcastEnabled = true;
      udpSocket.readEventsEnabled = true;
      currentUdpPortValid = true;
      currentUdpPortTrying = false;

      udpSocket.handleError((err){
        print("udpSocket.handleError $err");
      });

      udpSocket.listen((event) {
        print("udp: onData1 " + event.toString());
        if (event == RawSocketEvent.read) {
          print("udp: onData2");
          Datagram? dg = udpSocket.receive();
          print("udp: onData3");
          if (dg != null) {
            print("udp: received ${dg.data}");
            processFrame(udpSocket, UdpAddress(dg.address, dg.port), dg.data);
          }
        }
        if (event == RawSocketEvent.closed) {
          print("closed");
        }
        if (event == RawSocketEvent.write) {
          print("write");
          /*udpSocket.send(new Utf8Codec().encode('Hello from client'),
              "255.255.255.255", 45214);*/
        }
        if (event == RawSocketEvent.readClosed) {
          print("readClosed");
        }
      }, onError: (err) {
        print("udp: listen ERROR $err");
        currentUdpPortTrying = false;
        currentUdpPortValid = false;
      });

      //udpSocket.send(dataToSend, addressesIListenFrom, portIListenOn);
      //udpSocket.send(dataToSend, InternetAddress('172.16.32.73'), 16123);
    }).onError((error, stackTrace) {
      // todo: error
      currentUdpPortTrying = false;
      print("udp: bind ERROR");
      print(error);
    });
  }

  void processFrame(
      RawDatagramSocket socket, UdpAddress sourceAddress, Uint8List frame) {
    print("received: ${sourceAddress} ${frame.length}");

    if (frame.length < 8) {
      return;
    }

    int frameType = frame[0];

    switch (frameType) {
      case 0x00:
        processFrame00(socket, sourceAddress, frame);
        break;
      case 0x01:
        processFrame01(socket, sourceAddress, frame);
        break;
      case 0x02:
        processFrame02(socket, sourceAddress, frame);
        break;
      case 0x03:
        processFrame03(socket, sourceAddress, frame);
        break;
      case 0x10:
        processFrame10(socket, sourceAddress, frame);
        break;
      case 0x11:
        processFrame11(socket, sourceAddress, frame);
        break;
      case 0x20:
        processFrame20(socket, sourceAddress, frame);
        break;
      case 0x21:
        processFrame21(socket, sourceAddress, frame);
        break;
      case 0x22:
        processFrame22(socket, sourceAddress, frame);
        break;
      case 0x23:
        processFrame23(socket, sourceAddress, frame);
        break;
      default:
    }
  }

  // Ping
  void processFrame00(
      RawDatagramSocket socket, UdpAddress sourceAddress, Uint8List frame) {
    frame[0] = 0x01;
    frame[1] = 0x00;
    socket.send(frame, sourceAddress.address, sourceAddress.port);
  }

  void processFrame01(
      RawDatagramSocket socket, UdpAddress sourceAddress, Uint8List frame) {}

// ----------------------------------------
// Nonce
// ----------------------------------------

  void processFrame02(
      RawDatagramSocket socket, UdpAddress sourceAddress, Uint8List frame) {
    // nothing to do
  }
  void processFrame03(
      RawDatagramSocket socket, UdpAddress sourceAddress, Uint8List frame) {
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

    socket.send(request, sourceAddress.address, sourceAddress.port);
  }

// ----------------------------------------
// Incoming Call - Server Role
// ----------------------------------------

  void processFrame10(
      RawDatagramSocket socket, UdpAddress sourceAddress, Uint8List frame) {
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

  void processFrame11(
      RawDatagramSocket socket, UdpAddress sourceAddress, Uint8List frame) {
    RemotePeer? remotePeer;
    String receivedFromConnectionPoint =
        RemotePeer.connectionPointString(sourceAddress);
    for (RemotePeer peer in remotePeers.values) {
      if (peer.lanConnectionPointString() == receivedFromConnectionPoint) {
        remotePeer = peer;
        break;
      }
      if (peer.internetConnectionPointString() == receivedFromConnectionPoint) {
        remotePeer = peer;
        break;
      }
    }
    if (remotePeer != null) {
      remotePeer.processFrame(socket, sourceAddress, frame);
    }
  }

  // ARP LAN request
  void processFrame20(
      RawDatagramSocket socket, UdpAddress sourceAddress, Uint8List frame) {
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
    socket.send(response, sourceAddress.address, sourceAddress.port);
  }

  // ARP LAN response
  void processFrame21(
      RawDatagramSocket socket, UdpAddress sourceAddress, Uint8List frame) {
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
  void processFrame22(
      RawDatagramSocket socket, UdpAddress sourceAddress, Uint8List frame) {
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
    socket.send(response, sourceAddress.address, sourceAddress.port);
  }

  // Get Public Key response
  void processFrame23(
      RawDatagramSocket socket, UdpAddress sourceAddress, Uint8List frame) {
    Uint8List receivedPublicKeyBS = frame.sublist(8);
    var receivedPublicKey = decodePublicKeyFromPKCS1(receivedPublicKeyBS);
    String receivedAddress = addressForPublicKey(receivedPublicKey);
    for (var peer in remotePeers.values) {
      if (peer.remoteAddress == receivedAddress) {
        peer.setRemotePublicKey(receivedPublicKey);
      }
    }
  }

  void processFrame24(
      RawDatagramSocket socket, UdpAddress sourceAddress, Uint8List frame) {}

  void setProcessor(XchgServerProcessor processor) {}

  Future<CallResult> call(String remoteAddress, String authData,
      String function, Uint8List data) async {
    if (socket == null) {
      return CallResult.createError("No connection");
    }

    RemotePeer? remotePeer;
    if (remotePeers.containsKey(remoteAddress)) {
      remotePeer = remotePeers[remoteAddress];
    } else {
      remotePeer = RemotePeer(remoteAddress, authData, keyPair, network);
      remotePeers[remoteAddress] = remotePeer;
    }

    return remotePeer!.call(socket!, function, data);
  }
}
