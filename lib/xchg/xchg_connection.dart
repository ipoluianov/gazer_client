import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:gazer_client/xchg/aes.dart';
import 'package:gazer_client/xchg/packer.dart';
import 'package:gazer_client/xchg/rsa.dart';
import 'package:gazer_client/xchg/utils.dart';
import "package:pointycastle/export.dart";
import 'dart:math';
import 'package:base32/base32.dart';

import 'package:gazer_client/xchg/xchg_transaction.dart';

class XchgConnection {
  String id = "";
  String remotePeerAddress = "";

  Socket? socket;
  List<int> inputBufferList = [];

  bool init2Received = false;
  bool init3Received = false;
  bool init6Received = false;
  Uint8List localSecret = Uint8List(32);
  Uint8List remoteSecret = Uint8List(0);

  RSAPublicKey? remoteRouterPublicKey;

  int currentSID = 0;
  RSAPublicKey? remotePeerPublicKey;
  Uint8List aesKey = Uint8List(0);
  int sessionID = 0;
  int sessionNonceCounter = 1;

  int nextTransactionId = 1;

  Map<int, Transaction> transactions = {};
  String authData = "";

  bool statusConnecting = false;

  late AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair;

  XchgConnection(String remotePeerAddressL, String authString) {
    id = DateTime.now().toString();
    keyPair = generateRSAkeyPair();
    remotePeerAddress = remotePeerAddressL;
    authData = authString;
  }

  void fillLocalSecret() {
    var rnd = Random();
    for (int i = 0; i < 32; i++) {
      localSecret[i] = rnd.nextInt(255);
    }
  }

  void onData(List<int> event) {
    inputBufferList.addAll(event);
    Uint8List inputBufferBytes = Uint8List.fromList(inputBufferList);

    int processedLen = 0;
    int incomingDataOffset = inputBufferBytes.length;
    while (true) {
      while (processedLen < incomingDataOffset &&
          inputBufferBytes[processedLen] != 0xAA) {
        processedLen++;
      }
      int restBytes = incomingDataOffset - processedLen;
      if (restBytes < 40) {
        break;
      }
      int frameLen =
          inputBufferBytes.sublist(processedLen).buffer.asUint32List(4)[0];
      if (frameLen < 40 || frameLen > 128*1024) {
        processedLen++;
        continue;
      }
      if (restBytes < frameLen) {
        break;
      }
      Transaction tr =
          Transaction.fromBinary(inputBufferBytes, processedLen, frameLen);
      switch (tr.frameType) {
        case 0x02:
          processInit2(tr);
          break;
        case 0x03:
          processInit3(tr);
          break;
        case 0x06:
          processInit6(tr);
          break;
        case 0x21:
          processResponse(tr);
          break;
        case 0xFF:
          processError(tr);
          break;
      }
      processedLen += frameLen;
    }

    inputBufferList.removeRange(0, processedLen);
  }

  void processInit2(Transaction tr) {
    init2Received = true;
    remoteRouterPublicKey = decodePublicKeyFromPKCS1(tr.data);
    sendInit5();
    if (init2Received && init3Received) {
      sendInit4();
    }
  }

  void processInit3(Transaction tr) {
    init3Received = true;
    remoteSecret = rsaDecrypt(keyPair.privateKey, tr.data);
    if (init2Received && init3Received) {
      sendInit4();
    }
  }

  void processInit6(Transaction tr) {
    init6Received = true;
    var localSecretBytesReceived = rsaDecrypt(keyPair.privateKey, tr.data);
  }

  void processResponse(Transaction tr) {
    if (transactions.containsKey(tr.transactionId)) {
      Transaction originalTransaction = transactions[tr.transactionId]!;
      if (originalTransaction.response.length != tr.totalSize) {
        originalTransaction.response = Uint8List(tr.totalSize);
      }

      // Copy data
      for (int i = tr.offset; i < (tr.offset + tr.data.length); i++) {
        if (i >= 0 && i < originalTransaction.response.length) {
          originalTransaction.response[i] = tr.data[i - tr.offset];
        }
      }
      originalTransaction.receivedDataLen += tr.data.length;

      if (originalTransaction.receivedDataLen < tr.totalSize) {
        return;
      }

      originalTransaction.error = "";
      originalTransaction.complete = true;
      transactions.remove(tr.transactionId);
    }
  }

  void processError(Transaction tr) {
    if (transactions.containsKey(tr.transactionId)) {
      Transaction originalTransaction = transactions[tr.transactionId]!;
      originalTransaction.response = Uint8List(0);
      originalTransaction.error = utf8.decode(tr.data);
      originalTransaction.complete = true;
      transactions.remove(tr.transactionId);
    }
    reset();
  }

  Future<CallResult> call(String function, Uint8List data) async {
    if (statusConnecting) {
      print("connect ing ...");
      return CallResult.createError("connecting ...");
    }

    if (socket == null) {
      statusConnecting = true;
      try {
        print("connect processing ...");
        socket = await Socket.connect('x01.gazer.cloud', 8484,
            timeout: const Duration(milliseconds: 1000));
      } catch (err) {
        print("connect error");
        statusConnecting = false;
        return CallResult.createError("can not connect: $err");
      }
      if (socket == null) {
        print("connect error (null)");
        statusConnecting = false;
        return CallResult.createError("can not connect");
      }
      print("connect ok");
      socket!.listen(onData);

      fillLocalSecret();
      sendInit1();
      for (int i = 0; i < 20; i++) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (init6Received) {
          print("connect init ok");
          break;
        }
      }
      if (!init6Received) {
        print("connect init timeout");
        statusConnecting = false;
        return CallResult.createError("can not init");
      }
    }

    if (currentSID == 0) {
      print("connect resolve ...");
      var resolveResult = await resolveAddress();
      if (resolveResult.isError()) {
        print("connect resolve error");
        statusConnecting = false;
        return resolveResult;
      }
      print("connect resolve ok");
    }

    if (sessionID == 0) {
      print("connect auth ...");
      var authRes = await auth();
      if (authRes.isError()) {
        print("connect auth error");
        statusConnecting = false;
        return authRes;
      }
      print("connect auth ok");
    }

    //print("connect call ... ${function}");

    statusConnecting = false;

    var result = await regularCall(function, data);
    if (result.isError()) {
      print("connect call error $id");
      return result;
    }

    //print("connect call ok $id");
    return result;
  }

  Future<CallResult> auth() async {
    CallResult result = CallResult();

    {
      CallResult nonceResult = await regularCall("/xchg-get-nonce", Uint8List(0));
      if (nonceResult.isError()) {
        return nonceResult;
      }
      List<int> authFrameToEncrypt = [];
      authFrameToEncrypt.addAll(nonceResult.data);
      authFrameToEncrypt.addAll(utf8.encode(authData));
      var encryptedAuthFrame = rsaEncrypt(remotePeerPublicKey!, Uint8List.fromList(authFrameToEncrypt));
      Uint8List authFramePublicKeySize = Uint8List(4);
      var strPublicKeyBS = encodePublicKeyToPemPKCS1(keyPair.publicKey);
      authFramePublicKeySize.buffer.asUint32List()[0] = strPublicKeyBS.length;
      List<int> authFrameList = [];
      authFrameList.addAll(authFramePublicKeySize);
      authFrameList.addAll(strPublicKeyBS);
      authFrameList.addAll(encryptedAuthFrame);
      CallResult authResult = await regularCall("/xchg-auth", Uint8List.fromList(authFrameList));
      if (authResult.isError()) {
        return authResult;
      }
      var authResultDecrypted = rsaDecrypt(keyPair.privateKey, authResult.data);
      sessionID = authResultDecrypted.buffer.asUint64List()[0];
      aesKey = authResultDecrypted.sublist(8);
    }

    return result;
  }

  String addressByPublicKey(RSAPublicKey publicKey) {
    var publicKeyBS = encodePublicKeyToPemPKCS1(publicKey);
    var d = sha256.convert(publicKeyBS);
    return base32.encode(Uint8List.fromList(d.bytes.sublist(0, 30))).toLowerCase();
  }

  Future<CallResult> resolveAddress() async {
    var res = await executeTransaction(0x10, 0, 0, Uint8List.fromList(utf8.encode(remotePeerAddress)));
    if (res.error.isEmpty) {
      remotePeerPublicKey = decodePublicKeyFromPKCS1(res.data.sublist(8));
      var receivedAddr = addressByPublicKey(remotePeerPublicKey!);
      if (receivedAddr == remotePeerAddress) {
        currentSID = res.data.buffer.asUint64List()[0];
      }
    } else {
    }
    return res;
  }

  Future<CallResult> regularCall(String function, Uint8List data) async {
    List<int> frame = [];

    bool encrypted = false;

    if (aesKey.length == 32) {
      var functionBS = utf8.encode(function);
      frame.addAll(Uint8List(8)..buffer.asUint64List()[0] = sessionNonceCounter);
      frame.add(functionBS.length);
      frame.addAll(functionBS);
      frame.addAll(data);
      frame = packBytes(Uint8List.fromList(frame));
      frame = aesEncrypt(aesKey, Uint8List.fromList(frame));
      encrypted = true;
      sessionNonceCounter++;
    } else {
      var functionBS = utf8.encode(function);
      frame.add(functionBS.length);
      frame.addAll(functionBS);
      frame.addAll(data);
    }

    var res = await executeTransaction(0x20, currentSID, sessionID, Uint8List.fromList(frame));
    if (res.isError()) {
      return res;
    }

    if (encrypted) {
      res.data = aesDecrypt(aesKey, res.data);
      res.data = unpack(res.data);
    }

    if (res.data.isEmpty) {
      return CallResult.createError("wrong data len");
    }
    var result = CallResult();
    if (res.data[0] == 0x00) {
      result.error = "";
      result.data = res.data.sublist(1);
    } else {
      result.error = utf8.decode(res.data.sublist(1));
      result.data = Uint8List(0);
    }
    return result;
  }

  Future<CallResult> executeTransaction(
      int frameType, int targetSID, int sessionID, Uint8List data) async {

    if (socket == null || !init6Received) {
      return CallResult.createError("no connection");
    }

    int transactionId = nextTransactionId;
    nextTransactionId++;
    Transaction tr = Transaction();
    tr.transactionId = transactionId;
    tr.frameType = frameType;
    tr.sid = targetSID;
    tr.sessionId = sessionID;
    tr.data = data;
    tr.offset = 0;
    tr.totalSize = data.length;
    transactions[transactionId] = tr;
    try {
      socket?.add(tr.serialize());
    } catch (err) {
      reset();
      return CallResult.createError("{ERR_XCHG_PEER_CONN_TR_TIMEOUT}");
    }

    for (int i = 0; i < 50; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (tr.complete) {
        if (transactions.containsKey(tr.transactionId)) {
          transactions.remove(tr.transactionId);
        }
        CallResult res = CallResult();
        res.error = tr.error;
        res.data = tr.response;
        return res;
      }
    }

    if (transactions.containsKey(tr.transactionId)) {
      transactions.remove(tr.transactionId);
    }

    reset();

    return CallResult.createError("{ERR_XCHG_PEER_CONN_TR_TIMEOUT}");
  }

  void reset() {
    statusConnecting = false;
    if (socket != null) {
      socket!.close();
    }
    socket = null;
    sessionNonceCounter = 1;
    currentSID = 0;
    sessionID = 0;
    aesKey = Uint8List(0);
    inputBufferList = [];
    for (var tId in transactions.keys) {
      transactions[tId]?.error = "Connection Lost";
      transactions[tId]?.complete = true;
    }
    transactions = {};
  }

  void sendInit1() {
    Transaction tr = Transaction();
    tr.frameType = 0x01;
    tr.sessionId = 0;
    tr.sid = 0;
    tr.transactionId = 0;
    var strPublicKeyBS = encodePublicKeyToPemPKCS1(keyPair.publicKey);
    tr.data = strPublicKeyBS;
    tr.offset = 0;
    tr.totalSize = tr.data.length;
    var bs = tr.serialize();
    socket?.add(bs);
  }

  void sendInit4() {
    Transaction tr = Transaction();
    tr.frameType = 0x04;
    tr.sessionId = 0;
    tr.sid = 0;
    tr.transactionId = 0;

    var encryptedRemoteSecret = rsaEncrypt(remoteRouterPublicKey!, remoteSecret);
    tr.data = encryptedRemoteSecret;
    tr.offset = 0;
    tr.totalSize = tr.data.length;
    socket?.add(tr.serialize());
  }

  void sendInit5() {
    Transaction tr = Transaction();
    tr.frameType = 0x05;
    tr.sessionId = 0;
    tr.sid = 0;
    tr.transactionId = 0;
    var encryptedLocalSecret = rsaEncrypt(remoteRouterPublicKey!, localSecret);
    tr.data = encryptedLocalSecret;
    tr.offset = 0;
    tr.totalSize = tr.data.length;
    socket?.add(tr.serialize());
  }
}
