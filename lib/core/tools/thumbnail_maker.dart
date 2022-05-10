import 'dart:typed_data';
import 'dart:ui' as dart_ui;

import 'package:image/image.dart';

Uint8List? makeThumbnail(Uint8List imageBytes) {
  Image? image = decodeImage(imageBytes);
  final thumbnail = copyResize(image!, width: 100);
  var resBytes = encodePng(thumbnail);
  return Uint8List.fromList(resBytes);
}
