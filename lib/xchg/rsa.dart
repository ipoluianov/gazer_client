import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/asn1/asn1_object.dart';
import 'package:pointycastle/asn1/asn1_parser.dart';
import 'package:pointycastle/asn1/primitives/asn1_bit_string.dart';
import 'package:pointycastle/asn1/primitives/asn1_integer.dart';
import 'package:pointycastle/asn1/primitives/asn1_null.dart';
import 'package:pointycastle/asn1/primitives/asn1_object_identifier.dart';
import 'package:pointycastle/asn1/primitives/asn1_sequence.dart';
import "package:pointycastle/export.dart";
import 'dart:math';

import 'package:fast_rsa/fast_rsa.dart' as frsa;

SecureRandom exampleSecureRandom() {
  final _sGen = Random.secure();
  var n = BigInt.from(1);
  var ran = SecureRandom('Fortuna');
  ran.seed(KeyParameter(
      Uint8List.fromList(List.generate(32, (_) => _sGen.nextInt(255)))));
  return ran;
}

AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAkeyPair(
    {int bitLength = 2048}) {
  SecureRandom secureRandom = exampleSecureRandom();
  // Create an RSA key generator and initialize it

  //final keyGen = KeyGenerator('RSA'); // Get using registry
  final keyGen = RSAKeyGenerator();

  keyGen.init(ParametersWithRandom(
      RSAKeyGeneratorParameters(BigInt.parse('65537'), bitLength, 64),
      secureRandom));

  // Use the generator

  final pair = keyGen.generateKeyPair();

  // Cast the generated key pair into the RSA key types

  final myPublic = pair.publicKey as RSAPublicKey;
  final myPrivate = pair.privateKey as RSAPrivateKey;

  return AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey>(myPublic, myPrivate);
}

Uint8List encodePublicKeyToPKIX(RSAPublicKey publicKey) {
  var topLevel = ASN1Sequence();

  var seqType = ASN1Sequence();
  try {
    var id = ASN1ObjectIdentifier.fromBytes(Uint8List.fromList(
        [0x06, 0x09, 0x2A, 0x86, 0x48, 0x86, 0xF7, 0x0D, 0x01, 0x01, 0x01]));
    seqType.add(id);
  } catch (ee) {
    print(ee);
  }
  seqType.add(ASN1Null());
  topLevel.add(seqType);

  var seqPubKey = ASN1Sequence();
  seqPubKey.add(ASN1Integer(publicKey.modulus));
  seqPubKey.add(ASN1Integer(publicKey.exponent));
  var pubKeySeqBS = seqPubKey.encode();
  var seqPubKeyBS = ASN1BitString(stringValues: pubKeySeqBS);
  topLevel.add(seqPubKeyBS);

  /*var topLevel = ASN1Sequence();
  topLevel.add(ASN1Integer(publicKey.modulus));
  topLevel.add(ASN1Integer(publicKey.exponent));
  var bytes = topLevel.encode();*/
  var bytes = topLevel.encode();
  return bytes;
}

RSAPublicKey decodePublicKeyFromPKIX(Uint8List encodedBytes) {
  var topLevel = ASN1Parser(encodedBytes);
  var p1 = topLevel.nextObject();
  ASN1Sequence seq = p1 as ASN1Sequence;

  ASN1Sequence seqProtocol = seq.elements![0] as ASN1Sequence;
  // 42, 134, 72, 134, 247, 13, 1, 1, 1
  var el1 = seqProtocol.elements![0] as ASN1ObjectIdentifier;
  var el2 = seqProtocol.elements![1]; // ASN1Null

  ASN1BitString bsPublicKey = seq.elements![1] as ASN1BitString;
  var seqPubKey =
      ASN1Sequence.fromBytes(Uint8List.fromList(bsPublicKey.stringValues!));
  BigInt n = (seqPubKey.elements![0] as ASN1Integer).integer!;
  BigInt e = (seqPubKey.elements![1] as ASN1Integer).integer!;
  RSAPublicKey publicKey = RSAPublicKey(n, e);
  return publicKey;
}

BigInt readBytes(Uint8List bytes) {
  BigInt read(int start, int end) {
    if (end - start <= 4) {
      int result = 0;
      for (int i = end - 1; i >= start; i--) {
        result = result * 256 + bytes[i];
      }
      return new BigInt.from(result);
    }
    int mid = start + ((end - start) >> 1);
    var result =
        read(start, mid) + read(mid, end) * (BigInt.one << ((mid - start) * 8));
    return result;
  }

  return read(0, bytes.length);
}

Uint8List writeBigInt(BigInt number) {
  // Not handling negative numbers. Decide how you want to do that.
  int bytes = (number.bitLength + 7) >> 3;
  var b256 = new BigInt.from(256);
  var result = new Uint8List(bytes);
  for (int i = 0; i < bytes; i++) {
    result[i] = number.remainder(b256).toInt();
    number = number >> 8;
  }
  return result;
}

Uint8List encodePrivateKeyToPemPKCS1(RSAPrivateKey privateKey) {
  var topLevel = ASN1Sequence();

  var version = ASN1Integer(BigInt.from(0));
  var modulus = ASN1Integer(privateKey.n);
  var publicExponent = ASN1Integer(privateKey.exponent);
  var privateExponent = ASN1Integer(privateKey.d);
  var p = ASN1Integer(privateKey.p);
  var q = ASN1Integer(privateKey.q);
  var dP = privateKey.d! % (privateKey.p! - BigInt.from(1));
  var exp1 = ASN1Integer(dP);
  var dQ = privateKey.d! % (privateKey.q! - BigInt.from(1));
  var exp2 = ASN1Integer(dQ);
  var iQ = privateKey.q?.modInverse(privateKey.p!);
  var co = ASN1Integer(iQ);

  topLevel.add(version);
  topLevel.add(modulus);
  topLevel.add(publicExponent);
  topLevel.add(privateExponent);
  topLevel.add(p);
  topLevel.add(q);
  topLevel.add(exp1);
  topLevel.add(exp2);
  topLevel.add(co);

  return topLevel.encode();
}

Future<Uint8List> rsaEncrypt(
    RSAPublicKey myPublic, Uint8List dataToEncrypt) async {
  var publicKeyPem = rsaPublicKeyToPem(myPublic);
  var result = await frsa.RSA
      .encryptOAEPBytes(dataToEncrypt, "", frsa.Hash.SHA256, publicKeyPem);
  return result;

  /*final encryptor = OAEPEncoding(RSAEngine())
    ..init(true, PublicKeyParameter<RSAPublicKey>(myPublic)); // true=encrypt

  return _processInBlocks(encryptor, dataToEncrypt);*/
}

/*Future<Uint8List> rsaDecrypt(
    RSAPrivateKey myPrivate, Uint8List cipherText) async {
  final decryptor = OAEPEncoding(RSAEngine())
    ..init(
        false, PrivateKeyParameter<RSAPrivateKey>(myPrivate)); // false=decrypt

  return _processInBlocks(decryptor, cipherText);
}*/

Uint8List rsaSign(RSAPrivateKey privateKey, Uint8List dataToSign) {
  final signer = RSASigner(SHA256Digest(), '0609608648016503040201');

  signer.init(
      true, PrivateKeyParameter<RSAPrivateKey>(privateKey)); // true=sign

  final sig = signer.generateSignature(dataToSign);

  return sig.bytes;
}

String rsaPublicKeyToPem(RSAPublicKey publicKey) {
  var bs = encodePublicKeyToPKIX(publicKey);
  var bs64 = const Base64Encoder().convert(bs);
  var result =
      "-----BEGIN PUBLIC KEY-----\r\n" + bs64 + "\r\n-----END PUBLIC KEY-----";
  return result;
}

Future<bool> rsaVerify(
    RSAPublicKey publicKey, Uint8List signedData, Uint8List signature) async {
  var publicKeyPem = rsaPublicKeyToPem(publicKey);
  bool result = false;
  try {
    result = await frsa.RSA.verifyPSSBytes(signature, signedData,
        frsa.Hash.SHA256, frsa.SaltLength.EQUALS_HASH, publicKeyPem);
  } catch (ex) {
    frsa.RSAException ee = ex as frsa.RSAException;
    print("RSA EX:" + ee.cause);
    return false;
  }
  return result;
}

Uint8List _processInBlocks(AsymmetricBlockCipher engine, Uint8List input) {
  final numBlocks = input.length ~/ engine.inputBlockSize +
      ((input.length % engine.inputBlockSize != 0) ? 1 : 0);

  final output = Uint8List(numBlocks * engine.outputBlockSize);

  var inputOffset = 0;
  var outputOffset = 0;
  while (inputOffset < input.length) {
    final chunkSize = (inputOffset + engine.inputBlockSize <= input.length)
        ? engine.inputBlockSize
        : input.length - inputOffset;

    outputOffset += engine.processBlock(
        input, inputOffset, chunkSize, output, outputOffset);

    inputOffset += chunkSize;
  }

  return (output.length == outputOffset)
      ? output
      : output.sublist(0, outputOffset);
}
