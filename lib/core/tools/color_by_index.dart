import 'package:flutter/material.dart';
import 'package:gazer_client/core/tools/hex_colors.dart';

Color colorByIndex(int index) {
  Color result = Colors.white;
  switch (index % 4) {
    case 0:
      result = colorFromHex("#00ABC5");
      break;
    case 1:
      result = colorFromHex("#F7941D");
      break;
    case 2:
      result = colorFromHex("#6EC05C");
      break;
    case 3:
      result = colorFromHex("#EF4C45");
      break;
  }
  return result;
}
