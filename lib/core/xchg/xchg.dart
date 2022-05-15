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

  void wait() {
    for (int i = 0; i < 100; i++) {
      sleep(const Duration(milliseconds: 10));
      if (complete) {
        break;
      }
    }
  }
}

class Xchg {
  String address;
  late Timer _timer;

  Map<String, Transaction> transactions = {};

  Xchg(this.address) {
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      requestR();
    });
  }

  void requestR() async {
    var req = http.MultipartRequest('POST', Uri.parse("http://rep01.gazer.cloud:8987/"));
    req.fields['f'] = "r";
    req.fields['a'] = address;
    http.Response response;
    try {
      response = await http.Response.fromStream(await req.send().timeout(const Duration(milliseconds: 5000)));
      print("ok ${response.statusCode}");
    } on TimeoutException catch (_) {
      print("timeout");
      throw GazerClientException("timeout");
    }

    if (response.statusCode == 200) {
      String s = response.body;

      var fResp = Frame.fromJson(jsonDecode(s));
      String str = String.fromCharCodes(fResp.data);

      if (transactions.containsKey(fResp.transactionId)) {
        var tr = transactions[fResp.transactionId];
        if (tr != null) {
          tr.responseCode = response.statusCode;
          tr.response = fResp;
          tr.complete = true;
        }
      }
    }
  }

  Future<Transaction> requestW(String address, String function, Uint8List data) async {
    String transactionId = nextTransactionId();
    Frame frame = Frame("client", function, transactionId, data);
    Transaction tr = Transaction(transactionId, frame);
    var jsonBytesB64 = base64Encode(utf8.encode(jsonEncode(frame)));
    var req = http.MultipartRequest('POST', Uri.parse("http://rep01.gazer.cloud:8987/"));
    req.fields['f'] = "w";
    req.fields['a'] = address;
    req.fields['d'] = jsonBytesB64;
    transactions[transactionId] = tr;
    http.Response response;
    try {
      response = await http.Response.fromStream(await req.send().timeout(const Duration(milliseconds: 1000)));
    } on TimeoutException catch (_) {
      throw GazerClientException("timeout");
    }
    return tr;
  }

  String nextTransactionId() {
    var rnd = Random();
    return DateTime.now().microsecondsSinceEpoch.toString() + "_" + rnd.nextInt(1000000).toString();
  }
}
