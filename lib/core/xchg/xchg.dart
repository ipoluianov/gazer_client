import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

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
  Frame request;
  bool complete = false;
  int responseCode = 0;
  String error = "";
  Frame? response;
  Transaction(this.transactionId, this.request) {
    response = null;
  }

  Future<Transaction> wait() async {
    for (int i = 0; i < 3000; i++) {
      await Future.delayed(const Duration(milliseconds: 1));
      //sleep(const Duration(milliseconds: 10));
      if (complete) {
        print("TRANSACTION COMPLETE!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
        break;
      }
    }
    return this;
  }
}

class Xchg {
  String address;
  late Timer _timer;

  bool processing = false;

  Map<String, Transaction> transactions = {};

  Xchg(this.address) {
    _timer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      if (processing) {
        return;
      }
      requestR();
    });
  }

  void requestR() async {
    processing = true;
    var req = http.MultipartRequest('POST', Uri.parse("http://rep01.gazer.cloud:8987/"));
    req.fields['f'] = "r";
    req.fields['a'] = address;
    http.Response? response;
    try {
      print("read begin: ${address}");
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

        var fResp = Frame.fromJson(jsonDecode(s));
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
  }

  Future<Transaction> requestW(String dest, String function, Uint8List data) async {
    print("requestW $dest, $function");
    String transactionId = nextTransactionId();
    Frame frame = Frame(address, function, transactionId, data);
    Transaction tr = Transaction(transactionId, frame);
    var jsonBytesB64 = jsonEncode(frame);
    var req = http.MultipartRequest('POST', Uri.parse("http://rep01.gazer.cloud:8987/"));
    req.fields['f'] = "w";
    req.fields['a'] = dest;
    req.fields['d'] = jsonBytesB64;
    transactions[transactionId] = tr;
    http.Response response;
    try {
      response = await http.Response.fromStream(await req.send().timeout(const Duration(milliseconds: 1000)));
    } on TimeoutException catch (_) {
      //throw GazerClientException("timeout");
    }
    return tr;
  }

  String nextTransactionId() {
    var rnd = Random();
    return DateTime.now().microsecondsSinceEpoch.toString() + "_" + rnd.nextInt(1000000).toString();
  }
}
