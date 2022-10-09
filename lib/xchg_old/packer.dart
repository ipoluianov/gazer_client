import 'dart:typed_data';

import 'package:archive/archive.dart';

Uint8List packBytes(Uint8List data) {
  Uint8List result = Uint8List(0);
  var encoder = ZipEncoder();
  Archive archive = Archive();
  ArchiveFile file = ArchiveFile("data", data.length, data);
  archive.addFile(file);
  List<int>? zippedContent = encoder.encode(archive);
  if (zippedContent != null) {
    result = Uint8List.fromList(zippedContent);
  }
  return result;
}

Uint8List unpack(Uint8List packedData) {
  Uint8List unpackedData = Uint8List(0);
  final archive = ZipDecoder().decodeBytes(packedData);
  var file = archive.findFile("data");
  if (file != null) {
    unpackedData = Uint8List.fromList(file.content as List<int>);
  }
  return unpackedData;
}
