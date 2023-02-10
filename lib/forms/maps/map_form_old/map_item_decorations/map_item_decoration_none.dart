import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../map_item.dart';
import 'map_item_decoration.dart';

class MapItemDecorationNone extends MapItemDecoration {

  MapItemDecorationNone();

  @override
  String type() {
    return "none";
  }


  @override
  void tick() {
  }

  @override
  void drawPre(Canvas canvas, Rect rect, MapItem item) {
  }

  @override
  void drawPost(Canvas canvas, Rect rect, MapItem item) {
  }

  @override
  List<MapItemPropGroup> propGroupsOfDecorator() {
    List<MapItemPropGroup> groups = [];
    return groups;
  }


  @override
  List<MapItemPropItem> propThresholdOfItem() {
    List<MapItemPropItem> props = [];
    return props;
  }
}
