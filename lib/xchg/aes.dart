import 'dart:math';
import 'dart:typed_data';
import "package:pointycastle/export.dart";

Uint8List aesEncrypt(Uint8List keyBytes, Uint8List dataToEncrypt) {
  if (keyBytes.length != 32) {
    return Uint8List(0);
  }

  // Generate 12 random bytes for nonce
  final nonce = Uint8List(12);
  var rnd = Random.secure();
  for (int i = 0; i < 12; i++) {
    nonce[i] = rnd.nextInt(255);
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
  return b.toBytes();
}

Uint8List aesDecrypt(Uint8List keyBytes, Uint8List dataToDecrypt) {
  if (keyBytes.length != 32) {
    return Uint8List(0);
  }

  // Get nonce from block
  final nonce = Uint8List(12);
  for (int i = 0; i < 12; i++) {
    nonce[i] = dataToDecrypt[i];
  }

  // Get cipher
  dataToDecrypt = dataToDecrypt.sublist(12);

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
  return encryptedData;
}
