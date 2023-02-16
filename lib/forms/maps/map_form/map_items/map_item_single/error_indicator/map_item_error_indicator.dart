import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as dart_ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gazer_client/core/tools/calc_preffered_scale.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import '../../../main/map_item.dart';

class MapItemErrorIndicator extends MapItem {
  static const String sType = "error_indicator.01";
  static const String sName = "Error Indicator.01";
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

  MapItemErrorIndicator(Connection connection) : super(connection) {
    setDouble("font_size", 20);
  }

  @override
  void setDefaultsForItem() {
    setDouble("w", 200);
    setDouble("h", 40);
  }

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    drawPre(canvas, size);
    Color color = Colors.green;

    var text = get("text");

    bool isError = false;

    if (hasDataSource()) {
      var value = dataSourceValue();
      if (value.uom == "error") {
        isError = true;
      }
    }

    targetValue = getDoubleZ("font_size");
    text = text.replaceAll("[nl]", "\n");

    double widthZ = getDoubleZ("w");
    double heightZ = getDoubleZ("h");

    double indicatorWidth = heightZ;
    double indicatorRadius = indicatorWidth / 2.5;

    var textColor = Colors.white;
    if (isError) {
      textColor = getColor("text_error_color");
    } else {
      textColor = getColor("text_regular_color");
    }

    drawText(
        canvas,
        getDoubleZ("x") + indicatorWidth,
        getDoubleZ("y"),
        getDoubleZ("w") - indicatorWidth,
        getDoubleZ("h"),
        text,
        lastValue,
        textColor,
        TextVAlign.middle,
        TextAlign.left);

    var indicatorColor = getColor("regular_color");
    if (isError) {
      indicatorColor = getColor("error_color");
    }
    canvas.drawCircle(
        Offset(getDoubleZ("x") + indicatorWidth / 2,
            (getDoubleZ("y") + getDoubleZ("h") / 2)),
        indicatorRadius,
        Paint()..color = indicatorColor);

    drawPost(canvas, size);
  }

  @override
  void drawDemo(Canvas canvas, Size size) {
    setDouble("w", 100);
    setDouble("h", 40);
    draw(canvas, size, []);
  }

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "text", "Text", "text", "Text"));

      props.add(MapItemPropItem(
          "", "regular_color", "Regular Color", "color", "FF3BD33B"));
      props.add(MapItemPropItem(
          "", "text_regular_color", "Text Regular Color", "color", "FF00EFFF"));
      props.add(MapItemPropItem(
          "", "font_regular_size", "Font Regular Size", "double", "20"));

      props.add(MapItemPropItem(
          "", "error_color", "Error Color", "color", "FFE53535"));
      props.add(MapItemPropItem(
          "", "text_error_color", "Text Error Color", "color", "FFE53535"));
      props.add(MapItemPropItem(
          "", "font_error_size", "Font Error Size", "double", "20"));
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
