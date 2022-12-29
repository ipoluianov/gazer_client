import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/asymmetric/api.dart';

import 'rsa.dart';
import 'package:base32/base32.dart';

class CallResult {
  Uint8List data = Uint8List(0);
  String error = "";

  CallResult();

  factory CallResult.createError(String err) {
    CallResult res = CallResult();
    res.data = Uint8List(0);
    res.error = err;
    return res;
  }

  bool isError() {
    return error.isNotEmpty;
  }
}

String addressForPublicKey(RSAPublicKey publicKey) {
  var publicKeyBS = encodePublicKeyToPKIX(publicKey);
  var d = sha256.convert(publicKeyBS);
  return "#" +
      base32.encode(Uint8List.fromList(d.bytes.sublist(0, 30))).toLowerCase();
}

Uint8List addressBSForPublicKey(RSAPublicKey publicKey) {
  var publicKeyBS = encodePublicKeyToPKIX(publicKey);
  var d = sha256.convert(publicKeyBS);
  return Uint8List.fromList(d.bytes.sublist(0, 30));
}

void copyBytes(Uint8List dest, int offset, Uint8List src) {
  for (int i = 0; i < src.length; i++) {
    int destIndex = i + offset;
    if (destIndex >= 0 && destIndex < dest.length) {
      dest[destIndex] = src[i];
    }
  }
}
