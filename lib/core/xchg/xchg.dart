import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/asn1/primitives/asn1_integer.dart';
import 'package:pointycastle/asn1/primitives/asn1_sequence.dart';
import "package:pointycastle/export.dart";

import '../gazer_local_client.dart';

class Frame {
  String src;
  String function;
  String transactionId;
  Uint8List data;
  Frame(this.src, this.function, this.transactionId, this.data);
  factory Frame.fromJson(Map<String, dynamic> json) {
    Uint8List cn = Uint8List(0);
    {
      String? cnString = json['data'];
      if (cnString != null) {
        cn = const Base64Decoder().convert(cnString);
      }
    }

    return Frame(json['src'], json['function'], json['transaction'], cn);
  }

  Map<String, dynamic> toJson() {
    var dataString = const Base64Encoder().convert(data);
    return {'src': src, 'function': function, 'transaction': transactionId, 'data': dataString};
  }
}

class Transaction {
  String transactionId;
  bool complete = false;
  int responseCode = 0;
  String error = "";
  String response = "";
  Transaction(this.transactionId) {
  }

  Future<Transaction> wait() async {
    for (int i = 0; i < 3000; i++) {
      await Future.delayed(const Duration(milliseconds: 1));
      //sleep(const Duration(milliseconds: 10));
      if (complete) {
        //print("TRANSACTION COMPLETE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        break;
      }
    }
    return this;
  }
}

class Xchg1 {
  //String address;
  late Timer _timer;
  int counter = 1;

  bool processing = false;

  Uint8List aesKey = Uint8List(0);

  Map<String, Transaction> transactions = {};

  //Xchg(this.address) {

    /*_timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (aesKey.isEmpty) {
        //init();
      }

      if (address.isEmpty) {
        print("address empty");
        return;
      }

      if (processing) {
        return;
      }
      requestR();
    });*/
  //}






  /*void init() async {
    var req = http.MultipartRequest('POST', Uri.parse("http://127.0.0.1:8987/"));

    final pair = generateRSAkeyPair(exampleSecureRandom());
    print(pair.privateKey);
    print(pair.publicKey);

    var strPublicKeyBS = encodePublicKeyToPemPKCS1(pair.publicKey);
    var digest1 = sha256.convert(strPublicKeyBS);
    var a = digest1.bytes.sublist(0, 32);
    var aHex = hex.encode(a);
    var strPublicKeyBS64 = base64Encode(strPublicKeyBS);
    print("Public Key:" + strPublicKeyBS64);
    print("Addr:" + aHex);
    address = aHex;

    req.fields['f'] = "init";
    req.fields['a'] = address;
    req.fields['public_key'] = strPublicKeyBS64;
    http.Response? response;
    try {
      //print("read begin: ${address}");
      response = await http.Response.fromStream(await req.send().timeout(const Duration(milliseconds: 20000)));
      print("init read result: ${response.statusCode} body: ${response.body}");

      var responseBS = base64Decode(response.body);
      var decryptedText = rsaDecrypt(pair.privateKey, responseBS);
      var decryptedText64 = utf8.decode(decryptedText);
      aesKey = base64Decode(decryptedText64);
      print("AES KEY LEN: ${aesKey.length}");

    } on TimeoutException catch (_) {
      print("timeout");
      //throw GazerClientException("timeout");
    }
  }*/




  Uint8List int64bytes(int value) =>
      Uint8List(8)..buffer.asInt64List()[0] = value;

  /*void requestR() async {
    processing = true;
    var req = http.MultipartRequest('POST', Uri.parse("http://127.0.0.1:8987/"));

    //print("requestR");

    Uint8List counterBytes = int64bytes(counter);

    counter++;

    var data = aesEncrypt(aesKey, counterBytes);

    req.fields['f'] = "r";
    req.fields['a'] = address;
    req.fields['d'] = base64Encode(data);
    http.Response? response;
    try {
      //print("read begin: ${address}");
      response = await http.Response.fromStream(await req.send().timeout(const Duration(milliseconds: 20000)));
      //print("read result: ${response.statusCode} body: ${response.body}");
    } on TimeoutException catch (_) {
      print("timeout");
      //throw GazerClientException("timeout");
    }

    if (response != null) {
      //print("RESPONSE: ${response.statusCode} for addr $address");
      if (response.statusCode == 200) {
        String s = response.body;
        var aesEncrypted = base64Decode(s);
        var jsonString = aesDecrypt(aesKey, aesEncrypted);
        //print(jsonString);

        var fResp = Frame.fromJson(jsonDecode(utf8.decode(jsonString)));
        //String str = String.fromCharCodes(fResp.data);

        //print("Received transaction: ${fResp.transactionId}");

        if (transactions.containsKey(fResp.transactionId)) {
          var tr = transactions[fResp.transactionId];
          if (tr != null) {
            //print("Received transaction FOUND: ${fResp.transactionId}");
            tr.responseCode = response.statusCode;
            tr.response = fResp;
            tr.complete = true;
          }
        }
      }
    }

    processing = false;
  }*/

  Future<Transaction> requestW(String dest, String function, Uint8List data) async {
    Transaction tr = Transaction("");
    dest = "MIIBCgKCAQEAw3HnYPGjGltAf1vIw7U8/VrYrAtICk6gPy+K+q+YuQTjYJ8bdc7T5HcshkHpJ5gT9JR9fhC/JhFsRe1ZOV/CxLHYyD0ruo8ouyolC29CSHmeNqRp2TiV8sC642HoTphGRf0MQ0uaq7h7AYdVMxgUUKPgJs5eLI4KQnJa+Dwl0+HUUq54g2qQja4wAgrXhbtm+qm3hcJBycQbuBG2LfGl+lboA7cn0Vo+03QxQlXAp0MBuVOBIQ29PjR2hrq/T6+f48r4XzrUFfrV8iFrQtIq4R33j6UO/88jWcXXnlRAXt4/Eg65W+avBf83UIUVMMtn1QUcpBnyKis2qPF9o+bvCQIDAQAB";
    int lid = 0;
    {
      Uint8List publicKey = base64Decode(dest);
      List<int> bFrame = [];
      bFrame.add(0x05);
      bFrame.addAll(publicKey);
      var req = http.MultipartRequest('POST', Uri.parse("http://127.0.0.1:8987/"));
      req.fields['f'] = "b";
      req.fields['d'] = base64Encode(bFrame);
      http.Response response;
      try {
        response = await http.Response.fromStream(await req.send().timeout(const Duration(milliseconds: 1000)));
        //print("RESP:" + response.body);
        var resp = base64Decode(response.body);
        ByteBuffer byteBuffer = resp.buffer;
        Uint64List thirtytwoBitList = byteBuffer.asUint64List();
        lid = thirtytwoBitList[0];
        print("LID: ${lid}");
      } on TimeoutException catch (_) {
        //throw GazerClientException("timeout");
      }
    }
    {
      print("executing");
      Uint8List publicKey = base64Decode(dest);
      List<int> bFrame = [];
      bFrame.add(0x04);
      bFrame.addAll(int64bytes(lid));
      bFrame.addAll(data);
      var req = http.MultipartRequest('POST', Uri.parse("http://127.0.0.1:8987/"));
      req.fields['f'] = "b";
      req.fields['d'] = base64Encode(bFrame);
      http.Response response;
      try {
        print("send CALL");
        response = await http.Response.fromStream(await req.send().timeout(const Duration(milliseconds: 1000)));
        var resp = base64Decode(response.body);
        var textResp = utf8.decode(resp);
        print("RESPONSE:" + textResp);
        tr.response = textResp;
        tr.responseCode = 200;
      } on TimeoutException catch (_) {
        //throw GazerClientException("timeout");
      }
    }
    return tr;
  }

  String nextTransactionId() {
    var rnd = Random();
    return DateTime.now().microsecondsSinceEpoch.toString() + "_" + rnd.nextInt(1000000).toString();
  }
}
