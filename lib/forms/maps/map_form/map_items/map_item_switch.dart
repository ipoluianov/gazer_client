import 'dart:ui' as dart_ui;

import 'package:flutter/material.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import '../map_item.dart';

class MapItemSwitch extends MapItem {
  static const String sType = "switch.01";
  static const String sName = "Switch.01";
  @override
  String type() {
    return sType;
  }

  //double target = 0;
  double currentValue = 0;
  bool realValue = false;

  bool checking = false;
  DateTime checkingDT = DateTime.now();

  MapItemSwitch(Connection connection) : super(connection) {
    setDouble("font_size", 20);
  }

  @override
  void onTapDownForItem() {
    checking = true;
    checkingDT = DateTime.now();
    realValue = !realValue;
    Repository()
        .client(connection)
        .dataItemWrite(getDataSource(), realValue ? "1" : "0");
  }

  @override
  bool hasAction() {
    return true;
  }

  @override
  void setDefaultsForItem() {
    setDouble("w", 100);
    setDouble("h", 30);
  }

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    double minSize = getDoubleZ("h");
    if (getDoubleZ("w") < minSize) {
      minSize = getDoubleZ("w");
    }

    Color borderColor = getColor("border_color");
    Color centerOnColor = getColor("center_color_on");
    Color centerOffColor = getColor("center_color_off");
    Color topColor = getColor("top_color");

    double corner = minSize / 2;
    double paddingLeftRight = minSize / 2;
    double paddingInner = (minSize - paddingLeftRight) / 2;

    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(getDoubleZ("x"), getDoubleZ("y"), getDoubleZ("w"),
                getDoubleZ("h")),
            Radius.circular(corner)),
        Paint()..color = borderColor);

    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(
                getDoubleZ("x") + paddingInner,
                getDoubleZ("y") + paddingInner,
                getDoubleZ("w") - paddingInner * 2,
                getDoubleZ("h") - paddingInner * 2),
            Radius.circular(corner)),
        Paint()..color = realValue ? centerOnColor : centerOffColor);

    double pos1 = getDoubleZ("x") + paddingLeftRight;
    double pos2 = getDoubleZ("x") + getDoubleZ("w") - paddingLeftRight;
    double eWidth = pos2 - pos1;

    Offset c = Offset(
        pos1 + (eWidth * currentValue), getDoubleZ("y") + getDoubleZ("h") / 2);
    canvas.drawCircle(c, minSize / 3, Paint()..color = topColor);
  }

  @override
  void drawDemo(dart_ui.Canvas canvas, dart_ui.Size size) {
    setDouble("w", 100);
    setDouble("h", 40);
    draw(canvas, size, []);
  }

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem(
          "", "border_color", "Border Color", "color", "FF00EFFF"));
      props.add(MapItemPropItem(
          "", "center_color_on", "Center Color (OFF)", "color", "80555555"));
      props.add(MapItemPropItem(
          "", "center_color_off", "Center Color (ON)", "color", "E0555555"));
      props.add(
          MapItemPropItem("", "top_color", "Top Color", "color", "FFFFFFFF"));

      groups.add(MapItemPropGroup("Colors", true, props));
    }
    return groups;
  }

  double speed = 0.1;

  @override
  void tick() {
    var dsValue = dataSourceValue();
    if (!checking) {
      realValue = (dsValue.value == "1");
    }

    if (checking &&
        DateTime.now().difference(checkingDT).inMilliseconds > 2000) {
      checking = false;
    }

    double target = 0;
    if (realValue) {
      target = 1;
    }

    if (currentValue < target) {
      currentValue += speed;
      if (currentValue > target) {
        currentValue = target;
        speed = 0.1;
      }
    } else {
      currentValue -= speed;
      if (currentValue < target) {
        currentValue = target;
        speed = 0.1;
      }
    }

    speed *= 1.4;
  }
}
