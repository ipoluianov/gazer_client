import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../map_item.dart';
import 'map_item_decoration.dart';

class MapItemDecorationCircles01 extends MapItemDecoration {
  double aniCounter1 = 1.0;
  double aniCounter2 = 2.0;

  MapItemDecorationCircles01() {
    showProgress = 0;
    var rnd = Random(DateTime.now().microsecondsSinceEpoch);
    aniCounter1 = rnd.nextDouble();
    aniCounter2 = aniCounter1 + 1;
  }

  @override
  String type() {
    return "circles.01";
  }

  @override
  void tick() {
    aniCounter1 += getDoubleWithThresholds("speed1");
    if (aniCounter1 > 2 * pi) {
      aniCounter1 = 0;
    }

    aniCounter2 += getDoubleWithThresholds("speed2");
    if (aniCounter2 > 2 * pi) {
      aniCounter2 = 0;
    }
  }

  @override
  void drawPost(Canvas canvas, Rect rect, MapItem item) {
    Color color1 = getColorWithThresholds("color1");
    double width1 = getDoubleWithThresholds("width1");

    Color color2 = getColorWithThresholds("color2");
    double width2 = getDoubleWithThresholds("width2");

    Rect r1 = Rect.fromLTWH(
        rect.left +
            (rect.width / 2 -
                rect.width / 2 * getDoubleWithThresholds("radius1")),
        rect.top +
            (rect.height / 2 -
                rect.height / 2 * getDoubleWithThresholds("radius1")),
        rect.width * getDoubleWithThresholds("radius1"),
        rect.height * getDoubleWithThresholds("radius1"));
    Rect r2 = Rect.fromLTWH(
        rect.left +
            (rect.width / 2 -
                rect.width / 2 * getDoubleWithThresholds("radius2")),
        rect.top +
            (rect.height / 2 -
                rect.height / 2 * getDoubleWithThresholds("radius2")),
        rect.width * getDoubleWithThresholds("radius2"),
        rect.height * getDoubleWithThresholds("radius2"));

    canvas.drawArc(
        r1,
        aniCounter1,
        3 * showProgress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color1.withOpacity(0.3)
          ..strokeCap = StrokeCap.round
          ..strokeWidth = item.z(width1));

    canvas.drawArc(
        r2,
        aniCounter2,
        5 * showProgress,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = color2
          ..strokeCap = StrokeCap.round
          ..strokeWidth = item.z(width2));
  }

  @override
  List<MapItemPropGroup> propGroupsOfDecorator() {
    List<MapItemPropGroup> groups = [];
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "color1", "Color1", "color", "247176"));
      props.add(MapItemPropItem("", "width1", "Width1", "double", "5"));
      props.add(
          MapItemPropItem("", "speed1", "Speed (cycles/sec)", "double", "0.2"));
      props.add(MapItemPropItem("", "radius1", "Radius", "double", "0.5"));
      groups.add(MapItemPropGroup("Line1", true, props));
    }
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "color2", "Color2", "color", "247176"));
      props.add(MapItemPropItem("", "width2", "Width2", "double", "1"));
      props.add(
          MapItemPropItem("", "speed2", "Speed (cycles/sec)", "double", "0.1"));
      props.add(MapItemPropItem("", "radius2", "Radius", "double", "0.5"));
      groups.add(MapItemPropGroup("Line2", true, props));
    }
    return groups;
  }

  @override
  List<MapItemPropItem> propThresholdOfItem() {
    List<MapItemPropItem> props = [];
    props.add(
        MapItemPropItem("", "color1", "Background Color", "color", "00FF00"));
    props.add(MapItemPropItem("", "width1", "Width", "double", "5"));
    props.add(
        MapItemPropItem("", "speed1", "Speed (cycles/sec)", "double", "0.2"));
    props.add(MapItemPropItem("", "radius1", "Radius", "double", "0.5"));
    props.add(
        MapItemPropItem("", "color2", "Background Color", "color", "00FF00"));
    props.add(MapItemPropItem("", "width2", "Width", "double", "1"));
    props.add(
        MapItemPropItem("", "speed2", "Speed (cycles/sec)", "double", "0.1"));
    props.add(MapItemPropItem("", "radius2", "Radius", "double", "0.5"));
    return props;
  }
}
