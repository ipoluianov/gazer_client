import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:gazer_client/xchg/rsa.dart';

import 'network.dart';
import 'package:http/http.dart' as http;

const NetworkContainerDefault =
    "UEsDBBQACAAIADWLdFUAAAAAAAAAAAAAAAAMAAkAbmV0d29yay5qc29uVVQFAAEGVXpj1NBBbqswEAbgvU8xmnXkBEIc4A7vXaBClQMTsAo2Mq6KEuXulVNaqVGlsJ2NF+Nfv76ZqwC0eiAsAf9pY/9TwI0ADGagKehhxBISpfJCJYcsjT/GmmB0/zo6Y8OEJbwIAOxCGMvtdq67dpaWwtZS+HD+TV7MKE96IpXF3l9B2eoLeVn37r15ltd9TzXJ2g0rkysMS9L59q+kgCqu67Vt6XvNqwAAHD2dzRwvtrv3AXZu+jnFkgJA3TSepjjHQyb3R3ncy0TtynyXf0Fi6PH49/Ft87QoTYs1RfGtxNL4yE9481Pe/D1vfsabf+DNV7z5R978nDe/4M3XvPkn3vyaN7/hzSfe/DMfvoBK3D4DAAD//1BLBwhlUgJHEgEAAB8NAABQSwMEFAAIAAgANYt0VQAAAAAAAAAAAAAAABAACQBzaWduYXR1cmUuYmFzZTY0VVQFAAEGVXpjBMC5YoIwAADQD3IQtRwZOpQiigiBkEPckDQiCfepX99nuIzPH/n3m4tLX6Q+CEXoEZ5n5krHxPCMMGg1rdINDYP0bk3EDRaYwyz+2qyH7aaBq05jPSKbL4zJJhC8/TxAqenIKqx17GYRLQ4RwgLEHsemOuK7HaC1nvwnQ9ihGPw5rxxdpIqdM5c/2+hj8u2yC4L5wIaMUV8/LUkamQenaK8t6HZSS0169DJ0O1fuYncXrin9RftQm9NwJS7sVcYqiSvmJz8wM492vIP1VdgKLV3BKbxJte0eahHesC+oFacP62hYDodEINOt97u3o/ryagPRdjWL6qj8fV9t5u9lM8kpU/3A/BqO1fN98nJx8pvb9ByCi3tOwClBJVF3HH9//wcAAP//UEsHCNxX1PkmAQAAWAEAAFBLAQIUABQACAAIADWLdFVlUgJHEgEAAB8NAAAMAAkAAAAAAAAAAAAAAAAAAABuZXR3b3JrLmpzb25VVAUAAQZVemNQSwECFAAUAAgACAA1i3RV3FfU+SYBAABYAQAAEAAJAAAAAAAAAAAAAABVAQAAc2lnbmF0dXJlLmJhc2U2NFVUBQABBlV6Y1BLBQYAAAAAAgACAIoAAADCAgAAAAA=";
const NetworkContainerEncryptedPrivateKey =
    "uTC09uvV2vNvwes9yj+bb80UbQh14JSFG22MSMFYgd6odNyqRw9jluBfWg4ZE38k/rugSyvchj23DN54QM3lQxuiqe35YaSvkdAsNxumOaSvsXbezY4iz/WljSfqMjKVPHtUl81RusgNZAAegp8XL7u8UBFREPSQGqhqQGggDcnp8qtXz13yo3NVFJ1Zq+kkfWT2EJyhhi+u3LIpPE4s8I/ht9LERqYeGsXbWBxCwHWHa9MWHIsa6B2naL1VEEUdpQ1GvHNY62FWFMcjpUbXNJwNDEo2GUYXYv3cbj/HFrEebhglB6FomyjkHXWEPQf7CVZx3TVjZfmCTBL5f6ud/5MOvPX2aAbeVtvLw5fT5ZocnPExAMoFlYmwfSZWRauGFAavV7FLHvtkdGDQn33Z1adkL/Bgnz68ijR9SjA+XfQn7d2OTYIgN9FhhN1m8a4wovx4geRxFxJhe0kUVDHt+gXFPavBAcNb/iGu10CDk23WkFaN+eVTRP7WKviVhUsiraTW0CsGr1E0HYy6SY0A6PbEgWEP2azg8jAZRKiYG0uLyy81JN9C55oSAXcNKooqblcX4bPB9tI1cy4zbdhj6GehfxRQ872ZsGwnpDzy3iiQstI7XYhUvQKctl7IPz4JN++sP1qUvkFaUfEeXFtzzgZ5d92qsaMqz+6yA5kFk792I+W3F/mJdQnqeLhNKN3e+PWj2UlPpjFOmcCg6d/pKHCZk6GWYHU/V37/rLYkI6uw63r6/xMmpukXcbYvH5yd/5Ej0ohrtwz3iR5ZzpXVBIOlapW50lvYoBPLpPFtIKCPj3GMp8jqut9OsiYqCCmOdTKa49regsyJtomVhU+o26i8EHrvgGqQdHhFgDY2XlUB6C/KgKuYuML/8DzTyc+0qxnxeVMwC5Ug+H8qaBJMBlj0p1TDnGIKU2B/fostvL980a6pu9OUhgbCkEvQk8ba6KbDIsVjsVV2bAGi2sx4Gsr5z6x8O0taW+pO2ZE8gjq4WNiF9iWvG4JPclux0NbNhz3CPmfxhC80is25r6KbYHm8UhCTmsa7scWxV60pArpJyyoFf65L4kvxrmEKHAvUQYXs02wQ3e/mqaJuIzkfPkJFqB0R8y68nFLf3XKZQNaBT6QKaMEBfg0/CSkHCPZMRJMu+Rn85w1n4dB+J5mRKo/0cSk+3zGbQR+NbjgNIMUb/pUkJwrKhEJppejRBuu9Yvolu+q/2rnbBEElz/OrOyqw2vP9bbv0Q0HB2JkYD97j8aPbg8Vw6SOfaoyGzbJ21LNNlfPAWF4skyi8RvEAXGRnGS/zRDkTSUqANK+unAMgRTxEFgK2b86BMQuCxm6kPAW0GdY0nqkGvrdTK6Gs+8aLSI21dPHN/n2OCoIZvOqu3l9v6mlHtONJqbvfsDFk64hztO2p0SdhVi84I19y/hMJQESkKorGVR5XH/mKCBcBanYtpKhOtQZdWNT9taImL9EKtTeXcOfjs8YPSCGunueYp+nDBSmhlrC/K1mVCBAaUXVTxe1YaVGrXRMlIYUIB2g+KkV0d7ZNxzhqNJcw1Aud322IXI9aB4c8HismCRUp7NkRmTPYlT/hBJUJ1hVCIYWvzNYXd2Cse6bksv8KSpYf1rJHszGlvlHD4T8VBs29i0XDb5UyGLmLeyYRGz4=";
const NetworkContainerPublicKey =
    "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA8V7FEvpzVo4sLhE3rIEmKwbLmNZkweZLucv/vxIbj3y8jpJiEGT3kQA9JvGscdsS85gca34WCfKdMJBKErUm28/UAWnDZeVUmQyxwGXs2jO/OLQukwJT76Umsu/KIfr7zKxkzfm7fTsJ8q1ZYuHgndi4OTblKqy/tSynyEYFnlbpEvmIAS2ZJblarxaG5VJo3YA5ZdO5FTcuaSkZ+9v4uMvcwFK9qIigJCS+xJa+ubgN9cv2RuHuQB7+Qw9bGbCjk9cSGnbV0ttwoVMZxFkT72lAXdp5/NLWcRpKnnjEvkWKjo21ROeH6hk4qfa30Q/Q+hLbPxhLlXX2r9sNEEZkWQIDAQAB";
const NetworkContainerFileNetwork = "network.json";
const NetworkContainerFileSignature = "signature.base64";

XchgNetwork networkContainerLoadStaticDefault() {
  var zipFileBS = base64Decode(NetworkContainerDefault);
  return networkContainerLoad(zipFileBS, NetworkContainerPublicKey);
}

Future<Uint8List> httpCall(String url) async {
  throw "123";
  http.Response response = await http
      .get(Uri.parse(url))
      .timeout(const Duration(milliseconds: 1500));
  if (response.statusCode == 200) {
    var body = response.body.trim();
    return base64Decode(body);
  }
  throw "Exception: ${response.statusCode}";
}

Future<XchgNetwork> networkContainerLoadFromInternet() async {
  // Load local static network
  var network = networkContainerLoadStaticDefault();
  network.debugSource = "local static";

  List<XchgNetwork> networks = [];

  for (var initialPoint in network.initialPoints) {
    try {
      var resp = await httpCall(initialPoint);
      XchgNetwork n = networkContainerLoadDefault(resp);
      n.debugSource = initialPoint;
      networks.add(n);
    } catch (ex) {
      print("initial points error: $ex");
    }
  }

  // No fresh networks - use default static network
  if (networks.isEmpty) {
    return network;
  }

  for (var n in networks) {
    if (n.timestamp >= network.timestamp) {
      network = n;
    }
  }

  return network;
}

XchgNetwork networkContainerLoadDefault(Uint8List zipFileBS) {
  return networkContainerLoad(zipFileBS, NetworkContainerPublicKey);
}

Uint8List networkContainerUnpack(Uint8List packedData, String fileName) {
  Uint8List unpackedData = Uint8List(0);
  final archive = ZipDecoder().decodeBytes(packedData);
  var file = archive.findFile(fileName);
  if (file != null) {
    unpackedData = Uint8List.fromList(file.content as List<int>);
  }
  return unpackedData;
}

XchgNetwork networkContainerLoad(Uint8List zipFileBS, String publicKeyBase64) {
  var publicKeyBS = base64Decode(publicKeyBase64);
  var publicKey = decodePublicKeyFromPKIX(publicKeyBS);

  Uint8List networkFileBS64 =
      networkContainerUnpack(zipFileBS, NetworkContainerFileNetwork);
  Uint8List signatureFileBS64 =
      networkContainerUnpack(zipFileBS, NetworkContainerFileSignature);
  var networkFileBS = networkFileBS64;
  var signatureFileBS = base64Decode(utf8.decode(signatureFileBS64));

  var verifyResult = rsaVerify(publicKey, networkFileBS, signatureFileBS);
  if (!verifyResult) {
    throw "wrong signature";
  }

  var networkFileString = utf8.decode(networkFileBS);
  var json = jsonDecode(networkFileString);

  var network = XchgNetwork.fromJson(json);

  return network;
}
