import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:pointycastle/asn1/asn1_parser.dart';
import 'package:pointycastle/asn1/primitives/asn1_bit_string.dart';
import 'package:pointycastle/asn1/primitives/asn1_integer.dart';
import 'package:pointycastle/asn1/primitives/asn1_null.dart';
import 'package:pointycastle/asn1/primitives/asn1_object_identifier.dart';
import 'package:pointycastle/asn1/primitives/asn1_sequence.dart';
import "package:pointycastle/export.dart";
import 'dart:math';

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
  } catch (ee) {}
  seqType.add(ASN1Null());
  topLevel.add(seqType);

  var seqPubKey = ASN1Sequence();
  seqPubKey.add(ASN1Integer(publicKey.modulus));
  seqPubKey.add(ASN1Integer(publicKey.exponent));
  var pubKeySeqBS = seqPubKey.encode();
  var seqPubKeyBS = ASN1BitString(stringValues: pubKeySeqBS);
  topLevel.add(seqPubKeyBS);

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
      return BigInt.from(result);
    }
    int mid = start + ((end - start) >> 1);
    var result =
        read(start, mid) + read(mid, end) * (BigInt.one << ((mid - start) * 8));
    return result;
  }

  return read(0, bytes.length);
}

Uint8List bigIntToBytes(BigInt number) {
  int bytes = (number.bitLength + 7) >> 3;
  var b256 = BigInt.from(256);
  var result = Uint8List(bytes);
  for (int i = 0; i < bytes; i++) {
    result[i] = number.remainder(b256).toInt();
    number = number >> 8;
  }
  return result;
}

BigInt bytesToBigInt(List<int> data) {
  BigInt result = BigInt.from(0);
  for (int i = 0; i < data.length; i++) {
    var v = data[i];
    result = result * BigInt.from(256);
    result += BigInt.from(v);
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

BigInt encrypt(RSAPublicKey pub, BigInt m) {
  BigInt result = m.modPow(pub.exponent!, pub.modulus!);
  return result;
}

void incCounter(List<int> c) {
  c[3]++;
  if (c[3] != 0) {
    return;
  }
  c[2]++;
  if (c[2] != 0) {
    return;
  }
  c[1]++;
  if (c[1] != 0) {
    return;
  }
  c[0]++;
}

void mgf1XOR(List<int> data, int outOffset, int outSize, List<int> seed,
    int seedOffset, int seedSize) {
  Uint8List counter = Uint8List(4);

  int done = 0;
  while (done < outSize) {
    List<int> tempData = [];
    tempData.addAll(seed.sublist(seedOffset, seedOffset + seedSize));
    tempData.addAll(counter);
    var digest = sha256.convert(tempData);

    for (int i = 0; i < digest.bytes.length && done < outSize; i++) {
      data[outOffset + done] ^= digest.bytes[i];
      done++;
    }
    incCounter(counter);
  }
}

bool emsaPSSVerify(List<int> mHash, List<int> em, int emBits, int sLen) {
  // See RFC 8017, Section 9.1.2.

  var hLen = 32;

  var emLen = ((emBits + 7) / 8).floor();
  if (emLen != em.length) {
    return false;
  }

  // 1.  If the length of M is greater than the input limitation for the
  //     hash function (2^61 - 1 octets for SHA-1), output "inconsistent"
  //     and stop.
  //
  // 2.  Let mHash = Hash(M), an octet string of length hLen.
  if (hLen != mHash.length) {
    return false;
  }

  // 3.  If emLen < hLen + sLen + 2, output "inconsistent" and stop.
  if (emLen < hLen + sLen + 2) {
    return false;
  }

  // 4.  If the rightmost octet of EM does not have hexadecimal value
  //     0xbc, output "inconsistent" and stop.
  if (em.elementAt(emLen - 1) != 0xbc) {
    return false;
  }

  // 5.  Let maskedDB be the leftmost emLen - hLen - 1 octets of EM, and
  //     let H be the next hLen octets.
  var db = em.sublist(0, emLen - hLen - 1);
  var h = em.sublist(emLen - hLen - 1, emLen - 1);

  // 6.  If the leftmost 8 * emLen - emBits bits of the leftmost octet in
  //     maskedDB are not all equal to zero, output "inconsistent" and
  //     stop.
  var bitMask = 0xff >> (8 * emLen - emBits);
  if (em[0] & ~bitMask != 0) {
    return false;
  }

  // 7.  Let dbMask = MGF(H, emLen - hLen - 1).
  //
  // 8.  Let DB = maskedDB \xor dbMask.
  mgf1XOR(db, 0, db.length, h, 0, h.length);

  // 9.  Set the leftmost 8 * emLen - emBits bits of the leftmost octet in DB
  //     to zero.
  db[0] &= bitMask;

  // 10. If the emLen - hLen - sLen - 2 leftmost octets of DB are not zero
  //     or if the octet at position emLen - hLen - sLen - 1 (the leftmost
  //     position is "position 1") does not have hexadecimal value 0x01,
  //     output "inconsistent" and stop.
  var psLen = emLen - hLen - sLen - 2;
  for (int i = 0; i < psLen; i++) {
    if (db[i] != 0x00) {
      return false;
    }
  }

  if (db[psLen] != 0x01) {
    return false;
  }

  // 11.  Let salt be the last sLen octets of DB.
  var salt = db.sublist(db.length - sLen);

  // 12.  Let
  //          M' = (0x)00 00 00 00 00 00 00 00 || mHash || salt ;
  //     M' is an octet string of length 8 + hLen + sLen with eight
  //     initial zero octets.
  //
  // 13. Let H' = Hash(M'), an octet string of length hLen.
  List<int> tempList = [];
  tempList.addAll([0, 0, 0, 0, 0, 0, 0, 0]);
  tempList.addAll(mHash);
  tempList.addAll(salt);

  var digest = sha256.convert(tempList);
  var digestBytes = digest.bytes;

  // 14. If H = H', output "consistent." Otherwise, output "inconsistent."
  for (int i = 0; i < digestBytes.length; i++) {
    if (digestBytes[i] != h[i]) {
      return false;
    }
  }

  return true;
}

List<int> fillBytes(BigInt v, int len) {
  List<int> result = List.filled(len, 0);
  int bytes = (v.bitLength + 7) >> 3;
  var b256 = BigInt.from(256);
  var offset = len - 1;
  for (int i = 0; i < bytes; i++) {
    result[offset] = v.remainder(b256).toInt();
    v = v >> 8;
    offset--;
  }
  return result;
}

bool rsaVerify(
    RSAPublicKey publicKey, List<int> signedData, Uint8List signature) {
  var hash = sha256.convert(signedData);
  var digest = hash;

  var s = bytesToBigInt(signature);

  var m = encrypt(publicKey, s);
  var emBits = publicKey.n!.bitLength - 1;
  var emLen = ((emBits + 7) / 8).floor();
  if (m.bitLength > emLen * 8) {
    return false;
  }
  var em = fillBytes(m, emLen);
  var res = emsaPSSVerify(digest.bytes, em, emBits, 32);
  return res;
}

Future<Uint8List> rsaEncrypt(
    RSAPublicKey myPublic, Uint8List dataToEncrypt) async {
  var k = 256;
  if (dataToEncrypt.length > k - 2 * 32 - 2) {
    throw "wrong msg size";
  }
  List<int> label = [];
  var lHash = sha256.convert(label);
  List<int> em = List.filled(k, 0);

  var seedOffset = 1;
  var seedSize = 32;

  var dbOffset = 1 + 32;
  var dbSize = em.length - dbOffset;

  for (int i = 0; i < 32; i++) {
    em[dbOffset + i] = lHash.bytes[i];
  }
  var msgSize = dataToEncrypt.length;
  em[dbOffset + (dbSize - msgSize - 1)] = 1;

  var msgOffset = dbSize - msgSize;
  for (int i = 0; i < msgSize; i++) {
    em[dbOffset + msgOffset + i] = dataToEncrypt[i];
  }

  var rng = Random();
  for (int i = 0; i < 32; i++) {
    em[1 + i] = rng.nextInt(255);
  }

  mgf1XOR(em, dbOffset, dbSize, em, seedOffset, seedSize);
  mgf1XOR(em, seedOffset, seedSize, em, dbOffset, dbSize);
  var m = bytesToBigInt(em);
  var c = encrypt(myPublic, m);
  var result = fillBytes(c, k);

  return Uint8List.fromList(result);
}

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
