import 'package:flutter/material.dart';
import 'package:gazer_client/core/design_settings.dart';
import 'package:gazer_client/core/tools/hex_colors.dart';

class DesignColors {
  static Color _accent = const Color(0xFFFFBF00);

  static Color _fore = const Color(0xFF00BCD4);
  static Color _fore1 = const Color(0x9000BCD4);
  static Color _fore2 = const Color(0x6000BCD4);

  static Color _back = const Color(0xFF222222);
  static Color _back1 = const Color(0x1000BCD4);
  static Color _back2 = const Color(0x3000BCD4);

  static Color mainBackgroundColor = _back;

  static Color _good = const Color(0xFF008800);
  static Color _bad = const Color(0xFFBF360C);
  static Color _warning = const Color(0xFFFF7700);

  static DesignSettings _settings = DesignSettings.makeDefault();

  static Color accent() {
    return _accent;
  }

  static Color fore() {
    return _fore;
  }

  static Color fore1() {
    return _fore1;
  }

  static Color fore2() {
    return _fore2;
  }

  static Color back() {
    return _back;
  }

  static Color back1() {
    return _back1;
  }

  static Color back2() {
    return _back2;
  }

  static Color good() {
    return _good;
  }

  static Color bad() {
    return _bad;
  }

  static Color warning() {
    return _warning;
  }

  void setDesignSettings(DesignSettings settings) {
    _settings = settings;
    _accent = colorFromHex(_settings.get("accent"));
    _fore = colorFromHex(_settings.get("fore"));
    _fore1 = colorFromHex(_settings.get("fore1"));
    _fore2 = colorFromHex(_settings.get("fore2"));
    _back = colorFromHex(_settings.get("back"));
    _back1 = colorFromHex(_settings.get("back1"));
    _back2 = colorFromHex(_settings.get("back2"));

    _good = colorFromHex(_settings.get("good"));
    _bad = colorFromHex(_settings.get("bad"));
    _warning = colorFromHex(_settings.get("warning"));
  }

  static Widget buildScrollBar({required Widget child, ScrollController? controller}) {
    return RawScrollbar(
      thumbColor: back2(),
      //shape: StadiumBorder(side: BorderSide(color: DesignColors.back1, width: 2.0)),
      //shape: RoundedRectangleBorder(side: BorderSide(color: back1(), width: 2.0)),
      isAlwaysShown: true,
      thickness: 12,
      controller: controller,
      child: child,
    );
  }
}
