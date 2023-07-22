import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/maps/map_form/map_items/map_item_single/map_item_single.dart';

import '../../../utils/draw_dashes.dart';
import '../../../utils/draw_text.dart';
import '../../../utils/ticker.dart';
import '../../main/map_item.dart';

class MapItemDecorationGauge02 extends MapItemSingle {
  static const String sType = "decoration.gauge.02";
  static const String sName = "Decoration.gauge.02";
  @override
  String type() {
    return sType;
  }

  MapItemDecorationGauge02(Connection connection) : super(connection) {}

  @override
  void setDefaultsForItem() {
    //super.setDefaults();
    setDouble("w", 200);
    setDouble("h", 200);
  }

  Rect padding(Rect rect, double padding) {
    return Rect.fromLTRB(rect.left + padding, rect.top + padding,
        rect.right - padding, rect.bottom - padding);
  }

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    Ticker tick1 = Ticker(0, 2 * pi, getDouble("decor_period_1").toInt());
    Ticker tick2 = Ticker(0, 2 * pi, getDouble("decor_period_2").toInt());
    Ticker tick3 = Ticker(0, 1, 1000);

    drawPre(canvas, size);

    Rect mainRect = Offset(getDoubleZ("x"), getDoubleZ("y")) &
        Size(getDoubleZ("w"), getDoubleZ("h"));

    double minSize = getDoubleZ("w");
    if (getDoubleZ("h") < minSize) minSize = getDoubleZ("h");

    Color decColor = getColor("decor_color");

    drawDashes(
      canvas,
      decColor,
      padding(mainRect, minSize * 0.08 / 2),
      10,
      minSize * 0.08,
      tick1.value(),
    );

    drawDashes(
      canvas,
      decColor,
      padding(mainRect, minSize * 0.15),
      7,
      minSize * 0.02,
      tick2.value(reverse: true),
    );

    drawDashes(
      canvas,
      decColor,
      padding(mainRect, minSize / 5),
      0,
      z(0.5),
      0,
    );

    drawDashes(
      canvas,
      decColor,
      padding(mainRect, minSize / 3),
      50,
      z(5),
      tick1.value(),
    );

    drawDashes(
      canvas,
      decColor,
      padding(mainRect, minSize / 2),
      50,
      z(1),
      0,
    );

    canvas.drawPath(
      Path()
        ..moveTo(mainRect.left + mainRect.width / 2,
            mainRect.top + mainRect.height / 4)
        ..lineTo(mainRect.left + mainRect.width / 2,
            mainRect.top + mainRect.height - mainRect.height / 4),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = decColor
        ..strokeWidth = 2
        ..imageFilter =
            ImageFilter.blur(sigmaX: 2, sigmaY: mainRect.height / 10),
    );

    canvas.drawPath(
      Path()
        ..moveTo(mainRect.left + mainRect.width / 4,
            mainRect.top + mainRect.height / 2)
        ..lineTo(mainRect.left + mainRect.width - mainRect.width / 4,
            mainRect.top + mainRect.height / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = decColor
        ..strokeWidth = 2
        ..imageFilter =
            ImageFilter.blur(sigmaX: mainRect.width / 10, sigmaY: 2),
    );

    drawPost(canvas, size);
  }

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    groups.addAll(super.propGroupsOfItem());
    {
      List<MapItemPropItem> props = [];
      props.add(
          MapItemPropItem("", "decor_color", "Color", "color", "FF00EFFF"));
      props.add(
          MapItemPropItem("", "decor_period_1", "Period 1", "double", "20000"));
      props.add(
          MapItemPropItem("", "decor_period_2", "Period 2", "double", "10000"));
      groups.add(MapItemPropGroup("Decoration", true, props));
    }
    groups.add(borderGroup(borderWidthDefault: "0"));
    groups.add(backgroundGroup());
    return groups;
  }

  @override
  void tick() {}

  @override
  void resetToEndOfAnimation() {}
}
