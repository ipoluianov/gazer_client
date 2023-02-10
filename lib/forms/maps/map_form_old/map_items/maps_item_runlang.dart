import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as dart_ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/tools/calc_preffered_scale.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_decorations/map_item_decoration_rect_01.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_decorations/map_item_decoration_set.dart';

import '../../../../runlang/program.dart';
import '../map_item.dart';

class MapItemRunlang extends MapItem {
  static const String sType = "runlang.01";
  static const String sName = "runlang.01";
  @override
  String type() {
    return sType;
  }

  double realValue = 0.0;
  double targetValue = 0.0;
  double lastValue = 0.0;
  double aniCounter = 0.0;

  bool isReplacer = false;
  String replaceType = "";

  MapItemRunlang(Connection connection) : super(connection) {
    setDouble("font_size", 20);
  }

  void runlangProgram(Canvas canvas, Size size, List<String> parentMaps) {
    Program p = Program();
    p.compile('''
fn draw(vv) {
  drawText(vv)
}
''');
    p.addFunction("drawText", fnDrawText);
    currentCanvas = canvas;
    var value = dataSourceValue();
    var res = p.runFn("draw", [value.value]);
    return;
  }

  late Canvas currentCanvas;

  List<dynamic> fnDrawText(List<dynamic> args) {
    if (args.length != 1) {
      return [];
    }
    drawText(
        currentCanvas,
        getDoubleZ("x"),
        getDoubleZ("y"),
        getDoubleZ("w"),
        getDoubleZ("h"),
        args[0].toString(),
        24,
        getColorWithThresholds("text_color"),
        TextAlign.center);
    return [];
  }

  @override
  void setDefaultsForItem() {
    postDecorations = MapItemDecorationList([]);
    {
      var decoration = MapItemDecorationRect01();
      decoration.initDefaultProperties();
      postDecorations.items.add(decoration);
    }
    setDouble("w", 100);
    setDouble("h", 40);
  }

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    try {
      runlangProgram(canvas, size, parentMaps);
    } catch (ex) {
      drawText(
          canvas,
          getDoubleZ("x"),
          getDoubleZ("y"),
          getDoubleZ("w"),
          getDoubleZ("h"),
          ex.toString(),
          24,
          getColorWithThresholds("text_color"),
          TextAlign.center);
    }
  }

  void drawText(Canvas canvas, double x, double y, double width, double height,
      String text, double size, Color color, TextAlign align) {
    canvas.save();
    var textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
      ),
    );
    final textPainter = TextPainter(
        text: textSpan, textDirection: TextDirection.ltr, textAlign: align);
    textPainter.layout(
      minWidth: width,
      maxWidth: width,
    );
    textPainter.paint(
        canvas, Offset(x, y + (height / 2) - (textPainter.height / 2)));
    //textPainter.paint(canvas, Offset(x, y));
    canvas.restore();
  }

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "text", "Text", "text", "Text"));

      props.add(
          MapItemPropItem("", "text_color", "Text Color", "color", "FF00EFFF"));
      props.add(MapItemPropItem("", "font_size", "Font Size", "double", "20"));
      props.add(MapItemPropItem("", "prefix", "Prefix", "text", ""));
      props.add(MapItemPropItem("", "suffix", "Suffix", "text", ""));
      groups.add(MapItemPropGroup("Text", true, props));
    }
    return groups;
  }

  @override
  List<MapItemPropItem> propThresholdOfItem() {
    List<MapItemPropItem> props = [];
    props.add(
        MapItemPropItem("", "text_color", "Text Color", "color", "FF00EFFF"));
    props.add(MapItemPropItem("", "font_size", "Font Size", "double", "20"));
    props.add(MapItemPropItem("", "prefix", "Prefix", "text", ""));
    props.add(MapItemPropItem("", "suffix", "Suffix", "text", ""));
    return props;
  }

  @override
  void tick() {
    var diff = targetValue - lastValue;
    lastValue += diff / 2;
    if ((lastValue - targetValue).abs() < 0.1) {
      lastValue = targetValue;
    }
  }

  @override
  void resetToEndOfAnimation() {
    targetValue = getDoubleZ("font_size");
    lastValue = targetValue;
  }
}
