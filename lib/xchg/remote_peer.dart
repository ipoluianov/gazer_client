import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:gazer_client/xchg/request_udp.dart';
import 'package:gazer_client/xchg/rsa.dart';
import 'package:gazer_client/xchg/aes.dart';
import 'package:gazer_client/xchg/packer.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';

import 'network.dart';
import 'nonces.dart';
import 'peer.dart';
import 'transaction.dart';
import 'udp_address.dart';
import 'utils.dart';

class RemotePeer {
  Peer peer;
  String remoteAddress;
  String authData;

  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair = generateRSAkeyPair();

  RSAPublicKey? remotePublicKey;

  Nonces nonces = Nonces(100);

  UdpAddress? lanConnectionPoint1;

  bool findingConnection = false;
  bool authProcessing = false;
  Uint8List aesKey = Uint8List(0);
  int sessionId = 0;
  int sessionNonceCounter = 0;
  Map<int, Transaction> outgoingTransactions = {};
  int nextTransactionId = 1;

  DateTime lastTransactionDT = DateTime(0);

  RemotePeer(this.peer, this.remoteAddress, this.authData, this.keyPair) {
    nextTransactionId = (DateTime.now().microsecondsSinceEpoch % 1000000);
  }

  static String connectionPointString(UdpAddress? udpAddress) {
    if (udpAddress != null) {
      if (udpAddress.address.rawAddress.length == 16) {
        if (udpAddress.address.rawAddress[10] == 255 &&
            udpAddress.address.rawAddress[11] == 255) {
          udpAddress = UdpAddress(
              InternetAddress.fromRawAddress(
                  udpAddress.address.rawAddress.sublist(12)),
              udpAddress.port);
        }
      }

      return udpAddress.toString();
    }
    return "";
  }

  void setRemotePublicKey(UdpAddress? udpAddress, RSAPublicKey publicKey,
      Uint8List nonce, Uint8List signature) {
    if (!nonces.check(nonce)) {
      return;
    }

    if (!rsaVerify(publicKey, nonce, signature)) {
      return;
    }

    print("setLANConnectionPoint for $remoteAddress is $udpAddress");

    lanConnectionPoint1 = udpAddress;
    remotePublicKey = publicKey;
  }

  String lanConnectionPointString() {
    return connectionPointString(lanConnectionPoint1);
  }

  void processFrame(Transaction transaction) {
    if (transaction.frameType == 0x11) {
      processFrame11(transaction);
    }
  }

  void processFrame11(Transaction transaction) {
    //Transaction transaction = Transaction.fromBinary(frame, 0, frame.length);

    if (outgoingTransactions.containsKey(transaction.transactionId)) {
      var t = outgoingTransactions[transaction.transactionId];
      if (t != null) {
        t.transportType = transaction.transportType;
      }
      if (transaction.error == "") {
        if (t!.result.length != transaction.totalSize) {
          t.result = Uint8List(transaction.totalSize);
        }
        for (int i = 0; i < transaction.data.length; i++) {
          int targetOffset = i + transaction.offset;
          if (targetOffset >= 0 && targetOffset < t.result.length) {
            t.result[targetOffset] = transaction.data[i];
          }
        }
        t.receivedDataLen += transaction.data.length;
        if (t.receivedDataLen >= transaction.totalSize) {
          t.complete = true;
        }
      } else {
        t!.result = transaction.data;
        t.error = transaction.error;
        t.complete = true;
      }
    }
  }

  void send0x20(UdpAddress udpAddress) {
    return;

    var nonce = nonces.next();
    var addressBS = utf8.encode(remoteAddress);
    var request = Uint8List(8 + 16 + addressBS.length);
    request[0] = 0x20;
    copyBytes(request, 8, nonce);
    copyBytes(request, 8 + 16, Uint8List.fromList(addressBS));
    sendFrame(udpAddress, [request], peer);
  }

  Future<void> checkInternetConnectionPoint() async {
    if (remotePublicKey != null) {
      return;
    }

    var nonce = nonces.next();
    var addressBS = utf8.encode(remoteAddress);
    var data = Uint8List(16 + addressBS.length);
    copyBytes(data, 0, nonce);
    copyBytes(data, 16, Uint8List.fromList(addressBS));
    Transaction tr = Transaction(
        0x20, localAddress(), remoteAddress, 0, 0, 0, data.length, data);

    var frame = tr.serialize();
    var frameBS = Uint8List.fromList(frame);
    sendFrame(null, [frameBS], peer);
  }

  String lastSuccessTransactionTransport_ = "";

  String lastSuccessTransactionTransport() {
    return lastSuccessTransactionTransport_;
  }

  Future<void> checkLANConnectionPoint() async {
    return;
    print("checkLANConnectionPoint");
    var nonce = nonces.next();
    var addressBS = utf8.encode(remoteAddress);
    var data = Uint8List(16 + addressBS.length);
    copyBytes(data, 0, nonce);
    copyBytes(data, 16, Uint8List.fromList(addressBS));

    Transaction tr = Transaction(
        0x20, localAddress(), remoteAddress, 0, 0, 0, data.length, data);

    var frame = tr.serialize();
    var frameBS = Uint8List.fromList(frame);

    for (int i = Peer.udpStartPort; i < Peer.udpEndPort; i++) {
      sendFrame(UdpAddress(InternetAddress("127.0.0.1"), i), [frameBS], peer);
    }
  }

  void resetSession() {
    print("reseting session");
    sessionId = 0;
    sessionNonceCounter = 0;
    aesKey = Uint8List(0);
    nextTransactionId = 1;
  }

  Future<CallResult> call(String function, Uint8List data) async {
    if (DateTime.now().difference(lastTransactionDT).inSeconds > 30) {
      resetSession();
    }
    lastTransactionDT = DateTime.now();

    await checkInternetConnectionPoint();

    if (lanConnectionPoint1 == null) {
      if (lanConnectionPoint1 == null) {
        checkLANConnectionPoint();
      }
    }

    // Waiting for network
    for (int i = 0; i < 100; i++) {
      if (peer.network != null) {
        break;
      }
      await Future.delayed(const Duration(milliseconds: 10));
    }
    await checkInternetConnectionPoint();

    // Waiting for public key
    for (int i = 0; i < 100; i++) {
      if (remotePublicKey != null) {
        break;
      }
      await Future.delayed(const Duration(milliseconds: 10));
    }

    if (peer.network == null && lanConnectionPoint1 == null) {
      // No route
      return CallResult.createError("connecting to xchg network");
    }

    if (sessionId == 0) {
      print("auth start");
      String authRes = await auth(lanConnectionPoint1);
      if (authRes.isNotEmpty) {
        CallResult result = CallResult();
        result.error = "auth error:" + authRes;
        sessionId = 0;
        aesKey = Uint8List(0);
        return result;
      }
      print("auth ok");
    }

    CallResult result =
        await regularCall(lanConnectionPoint1, function, data, aesKey);
    return result;
  }

  Future<String> auth(UdpAddress? remoteConnectionPoint) async {
    if (authProcessing) {
      return "auth processing ...";
    }

    try {
      authProcessing = true;
      var getNonceResult = await regularCall(
          remoteConnectionPoint, "/xchg-get-nonce", Uint8List(0), Uint8List(0));
      if (getNonceResult.isError()) {
        authProcessing = false;
        return "get nonce error:" + getNonceResult.error;
      }
      if (getNonceResult.data.length != 16) {
        authProcessing = false;
        return "nonce != 16";
      }

      if (remotePublicKey == null) {
        authProcessing = false;
        return "remotePublicKey == null";
      }

      var authDataBS = utf8.encode(authData);

      var localPublicKeyBS = encodePublicKeyToPKIX(keyPair.publicKey);

      // Prepare auth frame
      Uint8List authFrameSecret = Uint8List(16 + authDataBS.length);
      copyBytes(authFrameSecret, 0, getNonceResult.data);
      copyBytes(authFrameSecret, 16, Uint8List.fromList(authDataBS));
      // Encrypt auth frame
      Uint8List encryptedAuthFrame =
          await rsaEncrypt(remotePublicKey!, authFrameSecret);

      Uint8List authFrame =
          Uint8List(4 + localPublicKeyBS.length + encryptedAuthFrame.length);
      authFrame.buffer.asUint32List(0)[0] =
          localPublicKeyBS.buffer.lengthInBytes;
      copyBytes(authFrame, 4, localPublicKeyBS);
      copyBytes(authFrame, 4 + localPublicKeyBS.length, encryptedAuthFrame);

      CallResult authResult = await regularCall(
          remoteConnectionPoint, "/xchg-auth", authFrame, Uint8List(0));
      if (authResult.isError()) {
        authProcessing = false;
        return "auth error-:" + authResult.error;
      }

      Uint8List authResultDecrypted =
          await rsaDecrypt(keyPair.privateKey, authResult.data);

      if (authResultDecrypted.length != 8 + 32) {
        authProcessing = false;
        return "authResultDecrypted.length != 8 + 32";
      }

      sessionId = authResultDecrypted.buffer.asInt64List(0)[0];
      aesKey = authResultDecrypted.sublist(8);
    } catch (ex) {
      print("******************** auth Exception ee: $ex");
      authProcessing = false;
    }
    authProcessing = false;
    return "";
  }

  Future<CallResult> regularCall(UdpAddress? remoteConnectionPoint,
      String function, Uint8List data, Uint8List aesKey) async {
    CallResult result = CallResult();

    Uint8List functionBS = Uint8List.fromList(utf8.encode(function));

    bool encrypted = false;
    int localSessionNonceCounter = sessionNonceCounter;
    sessionNonceCounter++;

    if (functionBS.length > 255) {
      return CallResult.createError("functionBS.length > 255");
    }

    Uint8List frame = Uint8List(0);

    if (aesKey.length == 32) {
      frame = Uint8List(8 + 1 + functionBS.length + data.length);
      frame.buffer.asInt64List()[0] = localSessionNonceCounter;
      frame[8] = functionBS.length;
      copyBytes(frame, 9, functionBS);
      copyBytes(frame, 9 + functionBS.length, data);
      frame = packBytes(frame);
      frame = aesEncrypt(aesKey, frame);
      encrypted = true;
    } else {
      frame = Uint8List(1 + functionBS.length + data.length);
      frame[0] = functionBS.length;
      copyBytes(frame, 1, functionBS);
      copyBytes(frame, 1 + functionBS.length, data);
    }

    if (!function.contains("data_item_history")) {
      //print("regularCall: $function len:${frame.length} sessionId:$sessionId");
    }

    CallResult callResult =
        await executeTransaction(remoteConnectionPoint, sessionId, frame);
    if (callResult.isError()) {
      print("call error: ${callResult.toString()}");
      return callResult;
    }

    if (encrypted) {
      try {
        callResult.data = aesDecrypt(aesKey, callResult.data);
        callResult.data = unpack(callResult.data);
      } catch (ex) {
        print("aes error: $ex");
        sessionId = 0;
        aesKey = Uint8List(0);
        return CallResult.createError(ex.toString());
      }
    }

    if (callResult.data.isEmpty) {
      return CallResult.createError("callResult.data.length < 1");
    }

    if (callResult.data[0] == 0) {
      // Success
      result = CallResult();
      result.data = callResult.data.sublist(1);

      if (!function.contains("data_item_history")) {
        //print("regularCall ok: $function");
      }

      return result;
    }

    if (callResult.data[0] == 1) {
      // High level Error
      result = CallResult.createError(utf8.decode(callResult.data.sublist(1)));
      return result;
    }

    result = CallResult.createError("Wrong response status");

    return result;
  }

  String localAddress() {
    return addressForPublicKey(keyPair.publicKey);
  }

  Future<CallResult> executeTransaction(
      UdpAddress? remoteConnectionPoint, int sessionId, Uint8List data) async {
    int localTransactionId = nextTransactionId;
    nextTransactionId++;

    Transaction tr = Transaction(0x10, localAddress(), remoteAddress,
        localTransactionId, sessionId, 0, data.length, data);
    outgoingTransactions[tr.transactionId] = tr;

    List<Uint8List> frames = [];

    int offset = 0;
    int blockSize = 524;
    while (offset < tr.data.length) {
      int currentBlockSize = blockSize;
      int restDataLen = tr.data.length - offset;
      if (restDataLen < currentBlockSize) {
        currentBlockSize = restDataLen;
      }

      var blockTransaction = Transaction(
          tr.frameType,
          tr.srcAddress,
          tr.destAddress,
          tr.transactionId,
          tr.sessionId,
          offset,
          tr.totalSize,
          tr.data.sublist(offset, offset + currentBlockSize));

      Uint8List blockFrame = Uint8List.fromList(blockTransaction.serialize());
      frames.add(blockFrame);
      offset += currentBlockSize;
    }
    sendFrame(remoteConnectionPoint, frames, peer);

    for (int i = 0; i < 500; i++) {
      if (tr.complete) {
        outgoingTransactions.remove(localTransactionId);
        if (tr.error.isNotEmpty) {
          return CallResult.createError(tr.error);
        }

        lastSuccessTransactionTransport_ = tr.transportType;
        //print("transport: " + lastSuccessTransactionTransport_);

        CallResult result = CallResult();
        result.data = tr.result;
        return result;
      }
      await Future.delayed(const Duration(milliseconds: 10));
    }

    outgoingTransactions.remove(localTransactionId);
    resetConnectionPoint();
    return CallResult.createError("transaction timeout");
  }

  void resetConnectionPoint() {
    lanConnectionPoint1 = null;
  }
}
