import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/maps/map_form/map_items/map_item_single/map_item_single.dart';

import '../../../../utils/draw_dashes.dart';
import '../../../../utils/draw_text.dart';
import '../../../../utils/ticker.dart';
import '../../../main/map_item.dart';

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
    setDouble("w", 100);
    setDouble("h", 100);
  }

  Rect padding(Rect rect, double padding) {
    return Rect.fromLTRB(rect.left + padding, rect.top + padding,
        rect.right - padding, rect.bottom - padding);
  }

  Ticker tick1 = Ticker();
  Ticker tick2 = Ticker();

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    tick1.min = 0;
    tick1.max = 2 * pi;
    tick1.periodMs = getDouble("decor_period_1").toInt();

    tick2.min = 0;
    tick2.max = 2 * pi;
    tick2.periodMs = getDouble("decor_period_2").toInt();

    String activityCondition = get("activity_condition");
    String activityValue = get("activity_value");
    bool activityEnabled = false;
    String value = dataSourceValue().value;
    String uom = dataSourceValue().uom;
    if (activityCondition == "") {
      activityEnabled = true;
    }
    if (activityCondition == "==" && activityValue == dataSourceValue().value) {
      activityEnabled = true;
    }

    if (activityCondition == ">" ||
        activityCondition == ">=" ||
        activityCondition == "<" ||
        activityCondition == "<=") {
      double? valueAsDouble = double.tryParse(value);
      double? activityValueAsDouble = double.tryParse(activityValue);
      if (valueAsDouble != null && activityValueAsDouble != null) {
        if (activityCondition == ">") {
          if (valueAsDouble > activityValueAsDouble) {
            activityEnabled = true;
          }
        }
        if (activityCondition == ">=") {
          if (valueAsDouble >= activityValueAsDouble) {
            activityEnabled = true;
          }
        }
        if (activityCondition == "<") {
          if (valueAsDouble < activityValueAsDouble) {
            activityEnabled = true;
          }
        }
        if (activityCondition == "<=") {
          if (valueAsDouble <= activityValueAsDouble) {
            activityEnabled = true;
          }
        }
      }
    }

    if (activityCondition == "valid" && uom != "error") {
      activityEnabled = true;
    }

    tick1.setEnabled(activityEnabled);
    tick2.setEnabled(activityEnabled);

    drawPre(canvas, size);

    Rect mainRect = Offset(getDoubleZ("x"), getDoubleZ("y")) &
        Size(getDoubleZ("w"), getDoubleZ("h"));

    double minSize = getDoubleZ("w");
    if (getDoubleZ("h") < minSize) minSize = getDoubleZ("h");

    Color decColor = getColor("decor_color");
    if (!activityEnabled) {
      decColor = getColor("decor_color_disabled");
    }

    drawDashes(
      canvas,
      decColor,
      padding(mainRect, minSize * 0.1 / 2),
      5,
      minSize * 0.1,
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
      padding(mainRect, minSize / 4),
      50,
      z(1),
      tick1.value(),
    );

    drawDashes(
      canvas,
      decColor,
      padding(mainRect, minSize / 2.5),
      0,
      z(0.5),
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
      props.add(MapItemPropItem("", "activity_condition", "Activity Condition",
          "options:==:<:<=:>:>=:valid", "=="));
      props.add(MapItemPropItem("", "activity_value", "Value", "text", "0"));
      groups.add(MapItemPropGroup("State", true, props));
    }
    {
      List<MapItemPropItem> props = [];
      props.add(
          MapItemPropItem("", "decor_color", "Color", "color", "FF00EFFF"));
      props.add(MapItemPropItem(
          "", "decor_color_disabled", "Color", "color", "FF555555"));
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
  void tick() {
    tick1.tick();
    tick2.tick();
  }

  @override
  void resetToEndOfAnimation() {}
}
