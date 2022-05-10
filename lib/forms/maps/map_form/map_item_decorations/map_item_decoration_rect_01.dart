import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../map_item.dart';
import 'map_item_decoration.dart';

class MapItemDecorationRect01 extends MapItemDecoration {
  MapItemDecorationRect01();

  @override
  String type() {
    return "rect.01";
  }


  @override
  void tick() {}

  Rect buildRect(Rect rectOriginal) {
    return Rect.fromLTWH(rectOriginal.left + ((rectOriginal.width / 2) * (1-showProgress)), rectOriginal.top + ((rectOriginal.height / 2) * (1-showProgress)), rectOriginal.width * showProgress, rectOriginal.height * showProgress);
  }


  Path buildPath(Rect rect) {
    Path p = Path();
    p.addPolygon(buildPoints(buildRect(rect)), true);
    return p;
  }

  List<Offset> buildPoints(Rect rect) {
    List<Offset> points = [];
    points.add(Offset(rect.left, rect.top));
    points.add(Offset(rect.right, rect.top));
    points.add(Offset(rect.right, rect.bottom));
    points.add(Offset(rect.left, rect.bottom));
    return points;
  }

  @override
  void drawPre(Canvas canvas, Rect rect, MapItem item) {
    drawBack(canvas, buildPoints(buildRect(rect)));
  }

  @override
  void drawPost(Canvas canvas, Rect rect, MapItem item) {
    double width = getDoubleWithThresholds("border_width") * zoom;
    {
      // Draw border
      canvas.drawPath(
          buildPath(rect),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = getColorWithThresholds("border_color")
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = width);
    }
  }

  @override
  List<MapItemPropGroup> propGroupsOfDecorator() {
    List<MapItemPropGroup> groups = [];
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "border_color", "Border Color", "color", "247176"));
      props.add(MapItemPropItem("", "border_width", "Border Width", "double", "1"));
      props.add(MapItemPropItem("", "back_color", "Background Color", "color", "30247176"));
      props.add(MapItemPropItem("", "back_img", "Background Image", "image", ""));
      props.add(MapItemPropItem("", "back_img_scale_fit", "Background Image Scale Fit", "scale_fit", "contain"));
      props.add(MapItemPropItem("", "border_corner_radius", "Border Corner Radius", "double", "0"));
      groups.add(MapItemPropGroup("Rectangle settings", true, props));
    }
    return groups;
  }

  @override
  List<MapItemPropItem> propThresholdOfItem() {
    List<MapItemPropItem> props = [];
    props.add(MapItemPropItem("", "border_color", "Border Color", "color", "247176"));
    props.add(MapItemPropItem("", "border_width", "Border Width", "double", "1"));
    props.add(MapItemPropItem("", "back_color", "Background Color", "color", "30247176"));
    props.add(MapItemPropItem("", "back_img", "Background Image", "image", ""));
    props.add(MapItemPropItem("", "back_img_scale_fit", "Background Image Scale Fit", "scale_fit", "contain"));
    props.add(MapItemPropItem("", "border_corner_radius", "Border Corner Radius", "double", "0"));
    return props;
  }
}
