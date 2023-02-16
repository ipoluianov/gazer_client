import 'dart:ui' as dart_ui;

import 'package:flutter/material.dart';
import 'package:gazer_client/core/tools/hex_colors.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:intl/intl.dart' as international;

import '../../../../runlang/program.dart';
import '../main/map_item.dart';

class MapItemItem extends MapItem {
  static const String sType = "item";
  static const String sName = "item";
  @override
  String type() {
    return sType;
  }

  Program program_ = Program();

  MapItemItem(Connection connection) : super(connection) {
    setDouble("font_size", 20);
    program_.addFunction("drawText", fnDrawText);
    program_.addFunction("drawRect", fnDrawRect);
    program_.addFunction("drawRRect", fnDrawRRect);
    program_.addFunction("fillRect", fnFillRect);
    program_.addFunction("fillRRect", fnFillRRect);
    program_.addFunction("drawArc", fnDrawArc);
    program_.addFunction("itemValue", fnItemValue);
    program_.addFunction("itemUOM", fnItemUOM);
    program_.addFunction("run.dtFormat", fnDTFormat);
    program_.addFunction("run.concat", fnConcat);
    program_.addFunction("itemDT", fnItemDT);
    program_.addFunction("zoom", fnZoom);
    program_.addFunction("regProp", fnRegProp);
    program_.addFunction("getProp", fnGetProp);
    program_.addFunction("getPropDouble", fnGetPropDouble);
    program_.addFunction("getPropDoubleZ", fnGetPropDoubleZ);
  }

  @override
  void setDefaultsForItem() {}

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    canvas.save();
    canvas.translate(getDoubleZ("x"), getDoubleZ("y"));

    try {
      runlangProgram(canvas, size, parentMaps);
    } catch (ex) {
      print(ex);
    }

    canvas.restore();
  }

  @override
  void drawDemo(dart_ui.Canvas canvas, dart_ui.Size size) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.purple.withOpacity(0.5)
          ..strokeWidth = 2);
  }

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    {
      groups.add(MapItemPropGroup("Item properties", true, itemLocalProps));
    }
    return groups;
  }

  @override
  void tick() {}

  @override
  void resetToEndOfAnimation() {}

  late Canvas currentCanvas;

  void runlangProgram(Canvas canvas, Size size, List<String> parentMaps) {
    if (program_.compile(get("code"))) {
      runlangProgramInit();
    }

    currentCanvas = canvas;
    var value = dataSourceValue();
    var res = program_.runFn("draw", [value.value]);

    return;
  }

  void runlangProgramInit() {
    program_.compile(get("code"));
    program_.runFn("init", []);
  }

  List<MapItemPropItem> itemLocalProps = [];

  List<dynamic> fnGetProp(List<dynamic> args) {
    if (args.length != 1 || args[0] is! String) {
      throw "wrong argument";
    }

    return [get(args[0])];
  }

  List<dynamic> fnGetPropDouble(List<dynamic> args) {
    if (args.length != 1 || args[0] is! String) {
      throw "wrong argument";
    }

    return [getDouble(args[0])];
  }

  List<dynamic> fnGetPropDoubleZ(List<dynamic> args) {
    if (args.length != 1 || args[0] is! String) {
      throw "wrong argument";
    }

    return [getDoubleZ(args[0])];
  }

  List<dynamic> fnRegProp(List<dynamic> args) {
    if (args.length != 4 ||
        args[0] is! String ||
        args[1] is! String ||
        args[2] is! String ||
        args[3] is! String) {
      throw "wrong argument";
    }

    String propName = args[0];
    String propDisplayName = args[1];
    String propType = args[2];
    String propDefaultValue = args[3];

    MapItemPropItem? propItem;
    for (var p in itemLocalProps) {
      if (p.name == propName) {
        propItem = p;
      }
    }
    if (propItem != null) {
      propItem.type = propType;
      propItem.displayName = propDisplayName;
      propItem.defaultValue = propDefaultValue;
    } else {
      propItem = MapItemPropItem(
          "", propName, propDisplayName, propType, propDefaultValue);
      itemLocalProps.add(propItem);
    }

    return [];
  }

  List<dynamic> fnItemValue(List<dynamic> args) {
    if (args.length != 1 || args[0] is! String) {
      throw "wrong argument";
    }

    var itemVal = itemValue(args[0]);
    return [itemVal.value];
  }

  List<dynamic> fnItemUOM(List<dynamic> args) {
    if (args.length != 1 || args[0] is! String) {
      throw "wrong argument";
    }

    var itemVal = itemValue(args[0]);
    return [itemVal.uom];
  }

  List<dynamic> fnConcat(List<dynamic> args) {
    if (args.length != 2 || args[0] is! String || args[1] is! String) {
      throw "wrong argument";
    }

    var result = args[0] + args[1];
    return [result];
  }

  List<dynamic> fnItemDT(List<dynamic> args) {
    if (args.length != 1 || args[0] is! String) {
      throw "wrong argument";
    }
    var itemVal = itemValue(args[0]);
    return [itemVal.dt];
  }

  List<dynamic> fnDTFormat(List<dynamic> args) {
    if (args.length != 2 || args[0] is! int || args[1] is! String) {
      throw "wrong argument";
    }
    // "yyyy-MM-dd HH:mm:ss"
    international.DateFormat timeFormat = international.DateFormat(args[1]);
    DateTime dt = DateTime.fromMicrosecondsSinceEpoch(args[0]);
    var dtAsString = timeFormat.format(dt);
    return [dtAsString];
  }

  List<dynamic> fnZoom(List<dynamic> args) {
    if (args.length != 1 || args[0] is! double) {
      throw "wrong argument";
    }

    return [z(args[0])];
  }

  List<dynamic> fnDrawArc(List<dynamic> args) {
    // x t w h c stroke start stop
    if (args.length != 8 ||
        args[0] is! double ||
        args[1] is! double ||
        args[2] is! double ||
        args[3] is! double ||
        args[4] is! String ||
        args[5] is! double ||
        args[6] is! double ||
        args[7] is! double) {
      return [];
    }

    currentCanvas.drawArc(
        Rect.fromLTWH(args[0], args[1], args[2], args[3]),
        args[6],
        args[7],
        false,
        Paint()
          ..color = colorFromHex(args[4])
          ..style = PaintingStyle.stroke
          ..strokeWidth = args[5]);

    return [];
  }

  List<dynamic> fnDrawRect(List<dynamic> args) {
    // x t w h c stroke
    if (args.length != 6 ||
        args[0] is! double ||
        args[1] is! double ||
        args[2] is! double ||
        args[3] is! double ||
        args[4] is! String ||
        args[5] is! double) {
      return [];
    }

    currentCanvas.drawRect(
        Rect.fromLTWH(args[0], args[1], args[2], args[3]),
        Paint()
          ..color = colorFromHex(args[4])
          ..style = PaintingStyle.stroke
          ..strokeWidth = args[5]);

    return [];
  }

  List<dynamic> fnFillRect(List<dynamic> args) {
    // x t w h c stroke
    if (args.length != 6 ||
        args[0] is! double ||
        args[1] is! double ||
        args[2] is! double ||
        args[3] is! double ||
        args[4] is! String ||
        args[5] is! double) {
      return [];
    }

    currentCanvas.drawRect(
        Rect.fromLTWH(args[0], args[1], args[2], args[3]),
        Paint()
          ..color = colorFromHex(args[4])
          ..style = PaintingStyle.fill
          ..strokeWidth = args[5]);

    return [];
  }

  List<dynamic> fnDrawRRect(List<dynamic> args) {
    // x t w h c stroke
    if (args.length != 7 ||
        args[0] is! double ||
        args[1] is! double ||
        args[2] is! double ||
        args[3] is! double ||
        args[4] is! String ||
        args[5] is! double ||
        args[6] is! double) {
      return [];
    }

    currentCanvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(args[0], args[1], args[2], args[3]),
            Radius.circular(args[6])),
        Paint()
          ..color = colorFromHex(args[4])
          ..style = PaintingStyle.stroke
          ..strokeWidth = args[5]);

    return [];
  }

  List<dynamic> fnFillRRect(List<dynamic> args) {
    // x t w h c stroke
    if (args.length != 7 ||
        args[0] is! double ||
        args[1] is! double ||
        args[2] is! double ||
        args[3] is! double ||
        args[4] is! String ||
        args[5] is! double ||
        args[6] is! double) {
      return [];
    }

    currentCanvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(args[0], args[1], args[2], args[3]),
            Radius.circular(args[6])),
        Paint()
          ..color = colorFromHex(args[4])
          ..style = PaintingStyle.fill
          ..strokeWidth = args[5]);

    return [];
  }

  List<dynamic> fnDrawText(List<dynamic> args) {
    if (args.length != 3 ||
        args[0] is! String ||
        args[1] is! double ||
        args[2] is! String) {
      return [];
    }
    drawText(
        currentCanvas,
        0,
        0,
        getDoubleZ("w"),
        getDoubleZ("h"),
        args[0].toString(),
        args[1],
        colorFromHex(args[2]),
        TextVAlign.middle,
        TextAlign.center);
    return [];
  }
}
