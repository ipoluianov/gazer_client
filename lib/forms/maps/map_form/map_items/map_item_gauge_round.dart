import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import '../map_item.dart';

class MapItemGaugeRound extends MapItem {
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
    Color color = getColorWithThresholds("text_color");

    var prefix = getWithThresholds("prefix");
    var suffix = getWithThresholds("suffix");
    var borderColor = getColorWithThresholds("border_color");
    var borderWidth = getDoubleWithThresholds("border_width");
    var backColor = getColorWithThresholds("back_color");

    bool validValue = updateGaugeState();

    if (!validValue) {
      targetValue = 0;
      lastValue = 0;
    }

    double progressWidth = getDoubleWithThresholds("progress_width");
    Color progressColor = getColorWithThresholds("progress_color");

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

    /*canvas.drawArc(Offset(getDoubleZ("x") + getDoubleZ("w") / 8, getDoubleZ("y") + getDoubleZ("h") / 8) & Size(getDoubleZ("w") - getDoubleZ("w") / 4, getDoubleZ("h") - getDoubleZ("h") / 4), aniCounter1, 3, false, Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.lightBlueAccent.withOpacity(0.3)
      ..strokeCap = StrokeCap.round
        ..strokeWidth = z(5));

    canvas.drawArc(Offset(getDoubleZ("x") + getDoubleZ("w") / 8, getDoubleZ("y") + getDoubleZ("h") / 8) & Size(getDoubleZ("w") - getDoubleZ("w") / 4, getDoubleZ("h") - getDoubleZ("h") / 4), aniCounter2, 5, false, Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.lightBlueAccent
      ..strokeCap = StrokeCap.round
      ..strokeWidth = z(0.5));

    canvas.drawArc(Offset(getDoubleZ("x") + getDoubleZ("w") / 8, getDoubleZ("y") + getDoubleZ("h") / 8) & Size(getDoubleZ("w") - getDoubleZ("w") / 4, getDoubleZ("h") - getDoubleZ("h") / 4), aniCounter2, 5, false, Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.lightBlueAccent.withOpacity(0.5)
      ..strokeCap = StrokeCap.round
      ..strokeWidth = z(2));*/

    String text = prefix + currentText + suffix;
    text = text.replaceAll("[nl]", "\n");

    drawText(
        canvas,
        getDoubleZ("x"),
        getDoubleZ("y"),
        getDoubleZ("w"),
        getDoubleZ("h"),
        text,
        getDoubleZWithThresholds("font_size"),
        color,
        TextAlign.center);

    drawPost(canvas, size);
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

  void drawText(Canvas canvas, double x, double y, double width, double height,
      String text, double size, Color color, TextAlign align) {
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
    return groups;
  }

  @override
  List<MapItemPropItem> propThresholdOfItem() {
    List<MapItemPropItem> props = [];
    props.add(
        MapItemPropItem("", "text_color", "Text Color", "color", "FFFFFF"));
    props.add(MapItemPropItem("", "font_size", "Font Size", "double", "20"));
    props.add(MapItemPropItem("", "prefix", "Prefix", "text", ""));
    props.add(MapItemPropItem("", "suffix", "Suffix", "text", ""));
    props.add(
        MapItemPropItem("", "progress_width", "ProgressWidth", "double", "5"));
    props.add(MapItemPropItem(
        "", "progress_color", "ProgressColor", "color", "0088FF"));
    return props;
  }
}
