import 'package:flutter/material.dart';

import '../../core/design.dart';

void showSnackSuccess(BuildContext context, String text) {
  showSnackCommon(context, text, Colors.white, DesignColors.good());
}

void showSnackError(BuildContext context, String text) {
  showSnackCommon(context, text, Colors.white, DesignColors.bad());
}

void showSnackCommon(
    BuildContext context, String text, Color foreColor, Color backCol) {
  ScaffoldMessenger.of(context).removeCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    duration: const Duration(milliseconds: 1500),
    backgroundColor: DesignColors.back(),
    padding: const EdgeInsets.all(0),
    content: Container(
      decoration: BoxDecoration(
        color: backCol,
      ),
      padding: const EdgeInsets.all(10),
      child: Text(
        text,
        style: TextStyle(
          color: foreColor,
          fontSize: 16,
        ),
      ),
    ),
  ));
}
