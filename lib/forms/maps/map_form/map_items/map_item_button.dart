import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as dart_ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gazer_client/core/tools/calc_preffered_scale.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_decorations/map_item_decoration_rect_01.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_decorations/map_item_decoration_set.dart';

import '../map_item.dart';

class MapItemButton extends MapItem {
  static const String sType = "button.01";
  static const String sName = "Button.01";
  @override
  String type() {
    return sType;
  }


  MapItemButton(Connection connection) : super(connection) {
    setDouble("font_size", 20);
  }

  double currentValue = 0;

  @override
  void setDefaultsForItem() {
    postDecorations = MapItemDecorationList([]);

    setDouble("w", 50);
    setDouble("h", 50);
  }

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    Offset center = Offset(getDoubleZ("x") + getDoubleZ("w") / 2, getDoubleZ("y") + getDoubleZ("h") / 2);
    double buttonSize = getDoubleZ("w");
    if (getDoubleZ("h") < buttonSize) {
      buttonSize = getDoubleZ("h");
    }

    buttonSize -= buttonSize / 10;

    var buttonColor = getColorWithThresholds("color");
    var buttonColorPressed = getColorWithThresholds("color_pressed");

    canvas.drawCircle(center, buttonSize / 2, Paint()
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
      canvas.drawCircle(center, pr1 * buttonSize / 2, Paint()
        ..style = PaintingStyle.fill
        ..color = Colors.black54
        ..strokeWidth = 2);
      canvas.drawCircle(center, pr2 * buttonSize / 2, Paint()
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
  }

  @override
  void drawDemo(dart_ui.Canvas canvas, dart_ui.Size size) {
    setDefaultsForItem();
    for (var d in postDecorations.items) {
      d.showProgress = 1;
      d.drawDecoratorPre(canvas, backgroundRect(), this, 1);
    }
    drawItem(canvas, size, "", []);
  }

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "color", "Text Color", "color", "FF00EFFF"));
      groups.add(MapItemPropGroup("Text", true, props));
    }
    return groups;
  }

  @override
  List<MapItemPropItem> propThresholdOfItem() {
    List<MapItemPropItem> props = [];
    props.add(MapItemPropItem("", "color", "Text Color", "color", "FF00EFFF"));
    return props;
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
  void resetToEndOfAnimation() {
  }
}
