import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as dart_ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/tools/calc_preffered_scale.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import '../../../../utils/draw_text.dart';
import '../../../main/map_item.dart';
import '../map_item_single.dart';

class MapItemText02 extends MapItemSingle {
  static const String sType = "text.02";
  static const String sName = "Text.02";
  @override
  String type() {
    return sType;
  }

  double targetValue = 0.0;
  double lastValue = 0.0;
  double aniCounter = 0.0;

  MapItemText02(Connection connection) : super(connection) {
    setDouble("font_size", 20);
  }

  @override
  void setDefaultsForItem() {
    setDouble("w", 400);
    setDouble("h", 30);
  }

  bool isDemo = false;

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    drawPre(canvas, size);
    var itemName = "";
    var text = "";
    var uom = "";

    if (hasDataSource()) {
      var value = dataSourceValue();
      itemName = value.displayName;
      text = value.value;
      uom = value.uom;
    }

    targetValue = getDoubleZ("font_size");

    if (isDemo) {
      itemName = "Name";
      text = "Value";
      uom = "";
    }

    var padding = z(10);

    drawText(
      canvas,
      getDoubleZ("x") + padding,
      getDoubleZ("y"),
      getDoubleZ("w") - padding * 2,
      getDoubleZ("h"),
      itemName,
      lastValue,
      getColor("name_color"),
      TextVAlign.middle,
      TextAlign.left,
      null,
      0,
    );

    drawValueAndUOM(
        canvas,
        getDoubleZ("x") + padding,
        getDoubleZ("y"),
        getDoubleZ("w") - padding * 2,
        getDoubleZ("h"),
        text,
        uom,
        lastValue,
        getColor("text_color"),
        getColor("uom_color"),
        TextAlign.right);
    drawPost(canvas, size);
  }

  void drawValueAndUOM(
      Canvas canvas,
      double x,
      double y,
      double width,
      double height,
      String value,
      String uom,
      double size,
      Color colorValue,
      Color colorUOM,
      TextAlign align) {
    var textSpan = TextSpan(children: [
      TextSpan(
        text: value + " ",
        style: TextStyle(
          color: colorValue,
          fontSize: size,
        ),
      ),
      TextSpan(
        text: uom,
        style: TextStyle(
          color: colorUOM,
          fontSize: size,
        ),
      ),
    ]);
    final textPainter = TextPainter(
        text: textSpan, textDirection: TextDirection.ltr, textAlign: align);
    textPainter.layout(
      minWidth: width,
      maxWidth: width,
    );
    textPainter.paint(
        canvas, Offset(x, y + (height / 2) - (textPainter.height / 2)));
  }

  @override
  void drawDemo(Canvas canvas, Size size) {
    setDefaultsForItem();
    canvas.drawRect(
        Rect.fromLTWH(0, 0, getDoubleZ("w"), getDoubleZ("h")),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.teal
          ..strokeWidth = 2);
    isDemo = true;
    draw(canvas, size, []);
  }

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    groups.addAll(super.propGroupsOfItem());
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem(
          "", "name_color", "Item Name Color", "color", "FF00BCD4"));
      props.add(
          MapItemPropItem("", "text_color", "Text Color", "color", "FF19EE46"));
      props.add(
          MapItemPropItem("", "uom_color", "UOM Color", "color", "FF009688"));
      props.add(MapItemPropItem("", "font_size", "Font Size", "double", "20"));
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
