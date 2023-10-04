import 'dart:ui' as dart_ui;

import 'package:flutter/material.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import '../../../../../core/repository.dart';
import '../../main/map_item.dart';

class MapItemButton01 extends MapItem {
  static const String sType = "button.01";
  static const String sName = "Button.01";
  @override
  String type() {
    return sType;
  }

  MapItemButton01(Connection connection) : super(connection) {
    setDouble("font_size", 20);
  }

  double currentValue = 0;

  @override
  void setDefaultsForItem() {
    setDouble("w", 50);
    setDouble("h", 50);
  }

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    Offset center = Offset(getDoubleZ("x") + getDoubleZ("w") / 2,
        getDoubleZ("y") + getDoubleZ("h") / 2);
    double buttonSize = getDoubleZ("w");
    if (getDoubleZ("h") < buttonSize) {
      buttonSize = getDoubleZ("h");
    }

    buttonSize -= buttonSize / 10;

    var buttonColor = getColor("color");
    var buttonColorPressed = getColor("color_pressed");

    canvas.drawCircle(
        center,
        buttonSize / 2,
        Paint()
          ..style = PaintingStyle.fill
          ..color = buttonColor
          ..strokeWidth = 2);

    {
      double pr1 = 0;
      if (currentValue < 0.5) {
        pr1 = currentValue / 0.5;
      }
      double pr2 = 1;
      if (currentValue > 0.5) {
        pr2 = (currentValue - 0.5) / 0.5;
      }
      pr2 = 1 - pr2;
      canvas.drawCircle(
          center,
          pr1 * buttonSize / 2,
          Paint()
            ..style = PaintingStyle.fill
            ..color = Colors.black54
            ..strokeWidth = 2);
      canvas.drawCircle(
          center,
          pr2 * buttonSize / 2,
          Paint()
            ..style = PaintingStyle.fill
            ..color = Colors.black26
            ..strokeWidth = 2);
    }
  }

  @override
  bool hasAction() {
    return true;
  }

  @override
  void onTapDownForItem() {
    currentValue = 0;
    Repository()
        .client(connection)
        .dataItemWrite(getDataSource(), get("value"));
  }

  @override
  void drawDemo(dart_ui.Canvas canvas, dart_ui.Size size) {
    setDefaultsForItem();
    drawItem(canvas, size, "", []);
  }

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    {
      {
        List<MapItemPropItem> props = [];
        props.add(MapItemPropItem(
            "", "data_source", "Data Source Item", "data_source", ""));
        groups.add(MapItemPropGroup("Data Source", true, props));
      }
    }
    {
      {
        List<MapItemPropItem> props = [];
        props.add(MapItemPropItem("", "value", "Value", "text", "0"));
        groups.add(MapItemPropGroup("Values", true, props));
      }
    }

    {
      List<MapItemPropItem> props = [];
      props
          .add(MapItemPropItem("", "color", "Text Color", "color", "FF00EFFF"));
      groups.add(MapItemPropGroup("Text", true, props));
    }
    return groups;
  }

  @override
  void tick() {
    double target = 1;
    double speed = 0.08;

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
  }

  @override
  void resetToEndOfAnimation() {}
}
