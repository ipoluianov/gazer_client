import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/maps/map_form/map_items/map_item_single/map_item_single.dart';

import '../../../utils/draw_dashes.dart';
import '../../../utils/draw_text.dart';
import '../../../utils/ticker.dart';
import '../../main/map_item.dart';

class MapItemDecorationGauge01 extends MapItemSingle {
  static const String sType = "decoration.gauge.01";
  static const String sName = "Decoration.gauge.01";
  @override
  String type() {
    return sType;
  }

  MapItemDecorationGauge01(Connection connection) : super(connection) {}

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

    drawPre(canvas, size);

    Rect mainRect = Offset(getDoubleZ("x"), getDoubleZ("y")) &
        Size(getDoubleZ("w"), getDoubleZ("h"));

    double minSize = getDoubleZ("w");
    if (getDoubleZ("h") < minSize) minSize = getDoubleZ("h");

    Color decColor = getColor("decor_color");

    drawDashes(
      canvas,
      decColor,
      padding(mainRect, minSize * 0.05 / 2),
      5,
      minSize * 0.05,
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
      z(1),
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
