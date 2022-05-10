
import 'dart:ui';

Color colorFromHex(String hexColor) {
  hexColor = hexColor.toUpperCase().replaceAll("#", "");
  if (hexColor.length == 6) {
    hexColor = "FF" + hexColor;
  }
  return Color(int.parse(hexColor, radix: 16));
}

String colorToHex(Color col) => '${col.alpha.toRadixString(16).padLeft(2, '0')}'
    '${col.red.toRadixString(16).padLeft(2, '0')}'
    '${col.green.toRadixString(16).padLeft(2, '0')}'
    '${col.blue.toRadixString(16).padLeft(2, '0')}';
