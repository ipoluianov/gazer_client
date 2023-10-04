import 'dart:ui' as dart_ui;

import 'package:flutter/material.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import '../../../../../core/repository.dart';
import '../../../utils/draw_text.dart';
import '../../main/map_item.dart';

class MapItemButton02 extends MapItem {
  static const String sType = "button.02";
  static const String sName = "Button.02";
  @override
  String type() {
    return sType;
  }

  MapItemButton02(Connection connection) : super(connection) {
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
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(
        getDoubleZ("x"), getDoubleZ("y"), getDoubleZ("w"), getDoubleZ("h")));

    var txtProps = getTextAppearance(this);

    drawText(
      canvas,
      getDoubleZ("x"),
      getDoubleZ("y"),
      getDoubleZ("w"),
      getDoubleZ("h"),
      get("text"),
      txtProps.fontSize,
      txtProps.textColor,
      TextVAlign.middle,
      txtProps.hAlign,
      txtProps.fontFamily,
      txtProps.fontWeight,
    );
    canvas.restore();
    drawPost(canvas, size);
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
        props.add(MapItemPropItem("", "value", "Value", "text", "0"));
        groups
            .add(MapItemPropGroup("Write the Value to the Item", true, props));
      }
    }

    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "text", "Text", "text", "Text"));
      groups.add(MapItemPropGroup("Text", true, props));
    }
    groups.add(textAppearanceGroup());
    groups.add(borderGroup());
    groups.add(backgroundGroup());

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
