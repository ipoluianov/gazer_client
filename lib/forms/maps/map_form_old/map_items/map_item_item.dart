import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as dart_ui;

import 'package:flutter/material.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_decorations/map_item_decoration_rect_01.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_decorations/map_item_decoration_set.dart';

import '../map_item.dart';

class MapItemItem extends MapItem {
  static const String sType = "item";
  static const String sName = "item";
  @override
  String type() {
    return sType;
  }

  MapItemItem(Connection connection) : super(connection) {
    setDouble("font_size", 20);
  }

  @override
  void setDefaultsForItem() {
    postDecorations = MapItemDecorationList([]);
  }

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
  }

  @override
  void drawDemo(dart_ui.Canvas canvas, dart_ui.Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.purple.withOpacity(0.5)
      ..strokeWidth = 2
    );
  }

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    return groups;
  }

  @override
  List<MapItemPropItem> propThresholdOfItem() {
    List<MapItemPropItem> props = [];
    return props;
  }

  @override
  void tick() {
  }

  @override
  void resetToEndOfAnimation() {
  }
}
