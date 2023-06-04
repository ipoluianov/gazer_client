import 'package:flutter/material.dart';
import 'package:gazer_client/core/design_settings.dart';
import 'package:gazer_client/core/tools/hex_colors.dart';

class DesignColors {
  static Color _accent = const Color(0xFFFFBF00);

  static Color _fore = Color(0xFF00BCFF);
  static Color _fore1 = const Color(0xB000BCFF);
  static Color _fore2 = const Color(0x9000BCFF);

  static Color _back = const Color(0xFF1E1E1E);
  static Color _back1 = const Color(0x1000BCFF);
  static Color _back2 = const Color(0x3000BCFF);

  static Color mainBackgroundColor = _back;

  static Color _good = const Color(0xFF008800);
  static Color _bad = const Color(0xFFBF360C);
  static Color _warning = const Color(0xFFFF7700);

  static DesignSettings _settings = DesignSettings.makeDefault();

  static Color paletteColor(String code) {
    code = code.replaceAll("{", "");
    code = code.replaceAll("}", "");
    if (code == "fore") {
      return DesignColors.fore();
    }
    if (code == "fore1") {
      return DesignColors.fore1();
    }
    if (code == "fore2") {
      return DesignColors.fore2();
    }
    if (code == "back") {
      return DesignColors.back();
    }
    if (code == "back1") {
      return DesignColors.back1();
    }
    if (code == "back2") {
      return DesignColors.back2();
    }
    if (code == "good") {
      return DesignColors.good();
    }
    if (code == "bad") {
      return DesignColors.bad();
    }
    return fore();
  }

  static void setPalette(String code) {
    if (code == "blue") {
      _fore = const Color(0xFF00BCFF);
      _fore1 = const Color(0xB000BCFF);
      _fore2 = const Color(0x9000BCFF);

      _back = const Color(0xFF151515);
      _back1 = const Color(0x1000BCFF);
      _back2 = const Color(0x3000BCFF);

      mainBackgroundColor = _back;

      _good = const Color(0xFF008800);
      _bad = const Color(0xFFBF360C);
      _warning = const Color(0xFFFF7700);
    }
    if (code == "green") {
      _fore = const Color(0xFF009922);
      _fore1 = const Color(0xB0009922);
      _fore2 = const Color(0x90009922);

      _back = const Color(0xFF151515);
      _back1 = const Color(0x10009922);
      _back2 = const Color(0x30009922);

      mainBackgroundColor = _back;

      _good = const Color(0xFF008800);
      _bad = const Color(0xFFBF360C);
      _warning = const Color(0xFFFF7700);
    }
    if (code == "turquoise") {
      _fore = const Color(0xFF00EFFF);
      _fore1 = const Color(0xB000EFFF);
      _fore2 = const Color(0x9000EFFF);

      _back = const Color(0xFF151515);
      _back1 = const Color(0x1000EFFF);
      _back2 = const Color(0x3000EFFF);

      mainBackgroundColor = _back;

      _good = const Color(0xFF008800);
      _bad = const Color(0xFFBF360C);
      _warning = const Color(0xFFFF7700);
    }
    if (code == "yellow") {
      _fore = const Color(0xFFDDAA00);
      _fore1 = const Color(0xB0DDAA00);
      _fore2 = const Color(0x90DDAA00);

      _back = const Color(0xFF151515);
      _back1 = const Color(0x10DDAA00);
      _back2 = const Color(0x30DDAA00);

      mainBackgroundColor = _back;

      _good = const Color(0xFF008800);
      _bad = const Color(0xFFBF360C);
      _warning = const Color(0xFFFF7700);
    }
    if (code == "white") {
      _fore = const Color(0xFFBBBBBB);
      _fore1 = const Color(0xB0BBBBBB);
      _fore2 = const Color(0x90BBBBBB);

      _back = const Color(0xFF151515);
      _back1 = const Color(0x10151515);
      _back2 = const Color(0x30151515);

      mainBackgroundColor = _back;

      _good = const Color(0xFF008800);
      _bad = const Color(0xFFBF360C);
      _warning = const Color(0xFFFF7700);
    }
  }

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

  static Widget buildScrollBar(
      {required Widget child, ScrollController? controller}) {
    return RawScrollbar(
      thumbColor: back2(),
      //shape: StadiumBorder(side: BorderSide(color: DesignColors.back1, width: 2.0)),
      //shape: RoundedRectangleBorder(side: BorderSide(color: back1(), width: 2.0)),
      thumbVisibility: true,
      thickness: 12,
      controller: controller,
      child: child,
    );
  }
}
