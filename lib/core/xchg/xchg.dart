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

class Xchg {
  String address;
  late Timer _timer;
  int counter = 1;

  bool processing = false;

  Uint8List aesKey = Uint8List(0);

  Map<String, Transaction> transactions = {};

  Xchg(this.address) {

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
  }

  SecureRandom exampleSecureRandom() {
    final _sGen = Random.secure();
    var n = BigInt.from(1);
    var ran = SecureRandom('Fortuna');
    ran.seed(KeyParameter(
        Uint8List.fromList(List.generate(32, (_) => _sGen.nextInt(255)))));
    return ran;
  }

  AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> generateRSAkeyPair(
      SecureRandom secureRandom,
      {int bitLength = 2048}) {
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

  Uint8List encodePublicKeyToPemPKCS1(RSAPublicKey publicKey) {
    var topLevel = ASN1Sequence();
    topLevel.add(ASN1Integer(publicKey.modulus));
    topLevel.add(ASN1Integer(publicKey.exponent));
    var bytes = topLevel.encode();
    return bytes;
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

  Uint8List rsaEncrypt(RSAPublicKey myPublic, Uint8List dataToEncrypt) {
    final encryptor = PKCS1Encoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(myPublic)); // true=encrypt

    return _processInBlocks(encryptor, dataToEncrypt);
  }

  Uint8List rsaDecrypt(RSAPrivateKey myPrivate, Uint8List cipherText) {
    final decryptor = PKCS1Encoding(RSAEngine())
      ..init(false, PrivateKeyParameter<RSAPrivateKey>(myPrivate)); // false=decrypt

    return _processInBlocks(decryptor, cipherText);
  }

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
