import 'dart:io';
import 'dart:typed_data';

import 'package:pointycastle/asn1/primitives/asn1_integer.dart';
import 'package:pointycastle/asn1/primitives/asn1_sequence.dart';
import "package:pointycastle/export.dart";
import 'dart:math';

Uint8List aesEncrypt(Uint8List keyBytes, Uint8List dataToEncrypt) {
  final nonce = Uint8List(12);
  nonce[0] = 1;
  nonce[1] = 2;
  nonce[2] = 3;
  nonce[3] = 4;

  if (keyBytes.isEmpty) {
    return Uint8List(0);
  }

  final cipher = GCMBlockCipher(AESEngine())
    ..init(
        true, // encrypt (or decrypt)
        AEADParameters(
          KeyParameter(keyBytes), // the 256 bit (32 byte) key
          16 * 8, // the mac size (16 bytes)
          nonce, // the 12 byte nonce
          Uint8List(0), // empty extra data
        ));

  var encryptedData = cipher.process(dataToEncrypt);
  var b = BytesBuilder();
  b.add(nonce);
  b.add(encryptedData);
  var result = b.toBytes();

  //print(keyBytes);
  //print(result);
  //print(result.length);

  //aesDecrypt(keyBytes, encryptedData);
  return result;
}

Uint8List aesDecrypt(Uint8List keyBytes, Uint8List dataToDecrypt) {
  final nonce = Uint8List(12);

  for (int i = 0; i < 12; i++) {
    nonce[i] = dataToDecrypt[i];
  }
  dataToDecrypt = dataToDecrypt.sublist(12);

  if (keyBytes.isEmpty) {
    return Uint8List(0);
  }

  //dataToDecrypt = base64Decode(utf8.decode(dataToDecrypt));
  //print("decode---------------------");
  //print(dataToDecrypt);
  //print("decode---------------------");

  final cipher = GCMBlockCipher(AESEngine())
    ..init(
        false, // encrypt (or decrypt)
        AEADParameters(
          KeyParameter(keyBytes), // the 256 bit (32 byte) key
          16 * 8, // the mac size (16 bytes)
          nonce, // the 12 byte nonce
          Uint8List(0), // empty extra data
        ));

  var encryptedData = cipher.process(dataToDecrypt);
  //print("decrypt:");
  //print(utf8.decode(encryptedData));
  //print(base64Encode(keyBytes));
  return encryptedData;
}


