import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as dart_ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/tools/calc_preffered_scale.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import '../map_item.dart';

class MapItemText extends MapItem {
  static const String sType = "text.01";
  static const String sName = "Text.01";
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

  MapItemText(Connection connection) : super(connection) {
    setDouble("font_size", 20);
  }

  @override
  void setDefaultsForItem() {
    setDouble("w", 100);
    setDouble("h", 40);
  }

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    drawPre(canvas, size);
    Color color = Colors.green;

    var text = get("text");
    var prefix = get("prefix");
    var suffix = get("suffix");

    if (hasDataSource()) {
      var value = dataSourceValue();
      text = value.value;

      double? valueAsDouble = double.tryParse(value.value);
      if (valueAsDouble != null) {
        realValue = valueAsDouble;
      }
    }

    targetValue = getDoubleZ("font_size");
    text = prefix + text + suffix;
    text = text.replaceAll("[nl]", "\n");
    text = text.replaceAll("[name]", dataSourceValue().displayName);
    text = text.replaceAll("[uom]", dataSourceValue().uom);
    lastValue = targetValue;

    if (isReplacer) {
      canvas.drawRect(
          Rect.fromLTWH(
              getDoubleZ("x"), getDoubleZ("y"), getDoubleZ("w"), z(60)),
          Paint()
            ..color = Colors.black54
            ..style = PaintingStyle.fill);
      drawText(
          canvas,
          getDoubleZ("x"),
          getDoubleZ("y"),
          getDoubleZ("w"),
          z(60),
          "replaced by a text element\r\nplease update your software\r\n[$replaceType]",
          z(14),
          Colors.red,
          TextAlign.center);
    }

    drawText(
        canvas,
        getDoubleZ("x"),
        getDoubleZ("y"),
        getDoubleZ("w"),
        getDoubleZ("h"),
        text,
        lastValue,
        getColor("text_color"),
        TextAlign.center);
    drawPost(canvas, size);
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
