import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';

Color colorByUOM(String uom) {
  if (uom == "error") {
    return DesignColors.bad();
  }
  if (uom == "stopped") {
    return DesignColors.fore1();
  }
  return Colors.green;
}

FontWeight fontWeightByUOM(String uom) {
  if (uom == "error") {
    return FontWeight.bold;
  }
  return FontWeight.normal;
}
