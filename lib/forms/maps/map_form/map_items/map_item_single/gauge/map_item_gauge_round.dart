import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import '../../../main/map_item.dart';
import '../map_item_single.dart';

class MapItemGaugeRound extends MapItemSingle {
  static const String sType = "gauge.01";
  static const String sName = "Gauge.01";
  @override
  String type() {
    return sType;
  }

  double realValue = 0.0;
  double targetValue = 0.0;
  double lastValue = 0.0;
  double aniCounter1 = 0.0;
  double aniCounter2 = 0.0;
  String currentText = "";

  MapItemGaugeRound(Connection connection) : super(connection) {
    setDouble("font_size", 20);
  }

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    var rRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
            getDoubleZ("x"), getDoubleZ("y"), getDoubleZ("w"), getDoubleZ("h")),
        Radius.circular(getDoubleZ("w")));
    drawPre(canvas, size, rRect: rRect);
    Color color = getColor("text_color");

    var prefix = get("prefix");
    var suffix = get("suffix");
    var borderColor = getColor("border_color");
    var borderWidth = getDouble("border_width");
    var backColor = getColor("back_color");

    bool validValue = updateGaugeState();

    if (!validValue) {
      targetValue = 0;
      lastValue = 0;
    }

    double progressWidth = getDouble("progress_width");
    Color progressColor = getColor("progress_color");

    if (backColor.alpha > 0) {
      canvas.drawArc(
          Offset(getDoubleZ("x"), getDoubleZ("y")) &
              Size(getDoubleZ("w"), getDoubleZ("h")),
          0,
          pi * 2,
          false,
          Paint()
            ..style = PaintingStyle.fill
            ..color = backColor
            ..strokeWidth = z(1));
    }

    drawPre(canvas, size);

    canvas.drawArc(
        Offset(getDoubleZ("x"), getDoubleZ("y")) &
            Size(getDoubleZ("w"), getDoubleZ("h")),
        0,
        pi * 2,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = borderColor
          ..strokeWidth = z(borderWidth));
    if (borderWidth > 0.9) {
      canvas.drawArc(
          Offset(getDoubleZ("x"), getDoubleZ("y")) &
              Size(getDoubleZ("w"), getDoubleZ("h")),
          0,
          pi * 2,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..color = borderColor.withOpacity(0.3)
            ..strokeWidth = z(borderWidth) + 2);
    }

    var progressWidthZ = z(progressWidth);
    var progressPadding = progressWidthZ;

    canvas.drawArc(
        Offset(getDoubleZ("x") + progressPadding,
                getDoubleZ("y") + progressPadding) &
            Size(getDoubleZ("w") - progressPadding * 2,
                getDoubleZ("h") - progressPadding * 2),
        -pi / 2,
        lastValue * pi * 2,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = progressColor
          ..strokeWidth = progressWidthZ);

    canvas.drawArc(
        Offset(getDoubleZ("x") + progressPadding,
                getDoubleZ("y") + progressPadding) &
            Size(getDoubleZ("w") - progressPadding * 2,
                getDoubleZ("h") - progressPadding * 2),
        -pi / 2,
        pi * 2,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = progressColor.withOpacity(0.5)
          ..strokeWidth = progressWidthZ / 4);

    String text = prefix + currentText + suffix;
    text = text.replaceAll("[nl]", "\n");

    drawText(
        canvas,
        getDoubleZ("x"),
        getDoubleZ("y"),
        getDoubleZ("w"),
        getDoubleZ("h"),
        text,
        getDoubleZ("font_size"),
        color,
        TextVAlign.middle,
        TextAlign.center);

    drawAnimatedCircles(canvas);

    drawPost(canvas, size);
  }

  void drawAnimatedCircles(Canvas canvas) {
    canvas.drawArc(
        Offset(getDoubleZ("x") + getDoubleZ("w") / 8,
                getDoubleZ("y") + getDoubleZ("h") / 8) &
            Size(getDoubleZ("w") - getDoubleZ("w") / 4,
                getDoubleZ("h") - getDoubleZ("h") / 4),
        aniCounter1,
        3,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.lightBlueAccent.withOpacity(0.3)
          ..strokeCap = StrokeCap.round
          ..strokeWidth = z(5));

    canvas.drawArc(
        Offset(getDoubleZ("x") + getDoubleZ("w") / 8,
                getDoubleZ("y") + getDoubleZ("h") / 8) &
            Size(getDoubleZ("w") - getDoubleZ("w") / 4,
                getDoubleZ("h") - getDoubleZ("h") / 4),
        aniCounter2,
        5,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.lightBlueAccent
          ..strokeCap = StrokeCap.round
          ..strokeWidth = z(0.5));

    canvas.drawArc(
        Offset(getDoubleZ("x") + getDoubleZ("w") / 8,
                getDoubleZ("y") + getDoubleZ("h") / 8) &
            Size(getDoubleZ("w") - getDoubleZ("w") / 4,
                getDoubleZ("h") - getDoubleZ("h") / 4),
        aniCounter2,
        5,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.lightBlueAccent.withOpacity(0.5)
          ..strokeCap = StrokeCap.round
          ..strokeWidth = z(2));
  }

  @override
  void drawDemo(Canvas canvas, Size size) {
    setDefaultsForItem();
    drawItem(canvas, size, "", []);
  }

  @override
  void tick() {
    var diff = targetValue - lastValue;
    lastValue += diff / 8;

    aniCounter1 += 0.01;
    if (aniCounter1 > 2 * pi) {
      aniCounter1 = 0;
    }

    aniCounter2 += 0.03;
    if (aniCounter2 > 2 * pi) {
      aniCounter2 = 0;
    }

    double readyThreshold = 0.01;
    if ((lastValue - targetValue).abs() < readyThreshold) {
      lastValue = targetValue;
    }
  }

  @override
  void resetToEndOfAnimation() {
    updateGaugeState();
    lastValue = targetValue;
  }

  bool updateGaugeState() {
    bool validValue = false;

    String text = get("text");
    if (hasDataSource()) {
      var value = dataSourceValue();
      text = value.value;
    }
    currentText = text;

    double? valueAsDouble = double.tryParse(text);
    if (valueAsDouble != null) {
      realValue = valueAsDouble;
      double min = getDouble("min");
      double max = getDouble("max");
      double diapason = max - min;
      if (diapason.abs() > 0.000000001) {
        targetValue = (valueAsDouble - min) / diapason;
        validValue = true;
      }
    }

    return validValue;
  }

  @override
  void setDefaultsForItem() {
    setDouble("w", 100);
    setDouble("h", 100);
  }

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "text", "Text", "text", "42"));
      props.add(MapItemPropItem("", "min", "Minimum Value", "double", "0"));
      props.add(MapItemPropItem("", "max", "Maximum Value", "double", "100"));

      props.add(
          MapItemPropItem("", "text_color", "Text Color", "color", "FFFFFF"));
      props.add(MapItemPropItem("", "font_size", "Font Size", "double", "20"));
      props.add(MapItemPropItem("", "prefix", "Prefix", "text", ""));
      props.add(MapItemPropItem("", "suffix", "Suffix", "text", ""));
      props.add(MapItemPropItem(
          "", "progress_width", "ProgressWidth", "double", "5"));
      props.add(MapItemPropItem(
          "", "progress_color", "ProgressColor", "color", "0088FF"));

      groups.add(MapItemPropGroup("Gauge", true, props));
    }
    groups.addAll(super.propGroupsOfItem());
    return groups;
  }
}
