import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import '../../../../utils/draw_text.dart';
import '../../../main/map_item.dart';
import '../map_item_single.dart';

class MapItemProgress01 extends MapItemSingle {
  static const String sType = "progress.01";
  static const String sName = "Progress.01";
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

  MapItemProgress01(Connection connection) : super(connection) {}

  @override
  void setDefaultsForItem() {
    //super.setDefaults();
    setDouble("w", 200);
    setDouble("h", 50);
  }

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    var rRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
            getDoubleZ("x"), getDoubleZ("y"), getDoubleZ("w"), getDoubleZ("h")),
        Radius.circular(getDoubleZ("w")));
    drawPre(canvas, size);

    Color color = getColor("text_color");

    var prefix = get("prefix");
    var suffix = get("suffix");

    bool validValue = updateGaugeState();

    if (!validValue) {
      targetValue = 0;
      lastValue = 0;
    }

    double progressPadding = getDoubleZ("progress_padding");
    Color progressColor = getColor("progress_color");

    drawPre(canvas, size);
    Paint paint = Paint()
      ..style = PaintingStyle.fill
      ..color = progressColor
      ..strokeWidth = z(1);

    if (get("orientation") == "horizontal") {
      double effectiveWidth = getDoubleZ("w") - progressPadding * 2;

      double value = lastValue;
      if (getBool("inverted")) {
        value = 1 - value;
        double realWidth = effectiveWidth * value;
        canvas.drawRect(
            Rect.fromLTRB(
              realWidth + getDoubleZ("x") + progressPadding,
              getDoubleZ("y") + progressPadding,
              getDoubleZ("x") + getDoubleZ("w") - progressPadding,
              getDoubleZ("h") + getDoubleZ("y") - progressPadding,
            ),
            paint);
      } else {
        value = value;
        double realWidth = effectiveWidth * value;
        Rect rect = Rect.fromLTRB(
          getDoubleZ("x") + progressPadding,
          getDoubleZ("y") + progressPadding,
          realWidth + getDoubleZ("x") + progressPadding,
          getDoubleZ("h") + getDoubleZ("y") - progressPadding,
        );
        canvas.drawRect(rect, paint);
      }
    } else {
      double value = lastValue;

      double effectiveHeight = getDoubleZ("h") - progressPadding * 2;

      if (getBool("inverted")) {
        value = value;
        double realHeight = effectiveHeight * value;
        canvas.drawRect(
            Rect.fromLTRB(
              getDoubleZ("x") + progressPadding,
              getDoubleZ("y") + progressPadding,
              getDoubleZ("x") + getDoubleZ("w") - progressPadding,
              realHeight + getDoubleZ("y") + progressPadding,
            ),
            paint);
      } else {
        value = 1 - value;
        double realHeight = effectiveHeight * value;
        Rect rect = Rect.fromLTRB(
          getDoubleZ("x") + progressPadding,
          getDoubleZ("y") + realHeight + progressPadding,
          getDoubleZ("w") + getDoubleZ("x") - progressPadding,
          getDoubleZ("h") + getDoubleZ("y") - progressPadding,
        );
        canvas.drawRect(rect, paint);
      }
    }

    String text = prefix + currentText + suffix;
    text = text.replaceAll("[nl]", "\n");

    var txtProps = getTextAppearance(this);

    drawText(
      canvas,
      getDoubleZ("x"),
      getDoubleZ("y"),
      getDoubleZ("w"),
      getDoubleZ("h"),
      text,
      txtProps.fontSize,
      txtProps.textColor,
      TextVAlign.middle,
      txtProps.hAlign,
      txtProps.fontFamily,
      txtProps.fontWeight,
    );

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

    double readyThreshold = targetValue * 0.01;
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
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    groups.addAll(super.propGroupsOfItem());
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "min", "Min Value", "double", "0"));
      props.add(MapItemPropItem("", "max", "Max Value", "double", "100"));
      props.add(MapItemPropItem(
          "", "orientation", "Orientation", "orientation", "horizontal"));
      props.add(MapItemPropItem("", "inverted", "Inverted", "bool", "false"));
      groups.add(MapItemPropGroup("Main", true, props));
    }
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem(
          "", "progress_padding", "ProgressPadding", "double", "2"));
      props.add(MapItemPropItem(
          "", "progress_color", "ProgressColor", "color", "{fore}"));

      groups.add(MapItemPropGroup("Appearance", false, props));
    }
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "text", "Text", "text", "42"));
      props.add(MapItemPropItem("", "prefix", "Prefix", "text", ""));
      props.add(MapItemPropItem("", "suffix", "Suffix", "text", ""));
      groups.add(MapItemPropGroup("Text", false, props));
    }
    groups.add(textAppearanceGroup(textColorDefault: "#FFFFFFFF"));

    groups.add(borderGroup(borderWidthDefault: "1"));
    groups.add(backgroundGroup());
    return groups;
  }
}
