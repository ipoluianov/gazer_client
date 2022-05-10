import 'dart:convert';

import 'package:archive/archive.dart';

String pack(String json) {
  String result = "";
  List<int> jsonBytes = utf8.encode(json);

  var encoder = ZipEncoder();
  Archive archive = Archive();
  ArchiveFile file = ArchiveFile("data", jsonBytes.length, jsonBytes);
  archive.addFile(file);
  List<int>? zippedContent = encoder.encode(archive);
  if (zippedContent != null) {
    result = base64.encode(zippedContent);
  }
  return result;
}

String unpack(String b64) {
  String jsonString = "";
  var decoded = base64.decode(b64);
  final archive = ZipDecoder().decodeBytes(decoded);
  var file = archive.findFile("data");
  if (file != null) {
    final data1 = file.content as List<int>;
    jsonString = utf8.decode(data1);
  }
  return jsonString;
}
