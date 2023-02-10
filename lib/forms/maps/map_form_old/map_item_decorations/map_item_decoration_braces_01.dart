import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../map_item.dart';
import 'map_item_decoration.dart';

class MapItemDecorationBraces01 extends MapItemDecoration {
  MapItemDecorationBraces01() {
    showProgress = 0;
  }

  @override
  String type() {
    return "braces.01";
  }

  bool innerAnimation = true;
  double innerProgress = 0;
  double innerProgressMax = pi * 2 * 2;

  @override
  void tick() {
    if (innerAnimation && displayed()) {
      innerProgress += 0.2;
      if (innerProgress >= innerProgressMax) {
        innerProgress = innerProgressMax;
        innerAnimation = false;
      }
    }
  }

  double calcCorner(Rect rect) {
    return rect.height / 20;
  }

  void drawBrace(Canvas canvas, Rect rect, bool left) {

    double width = getDoubleWithThresholds("border_width") * zoom;
    var corner = calcCorner(rect);
    List<Offset> points = [];
    List<Offset> circlePoints = [];

    var targetMargin = width * 10;
    var beginMargin = -rect.width / 4;
    var diffMargins = targetMargin - beginMargin;
    var margin = beginMargin + (diffMargins * showProgress);

    if (innerAnimation) {
      margin = margin - (targetMargin / 2) * sin(innerProgress);
    }

    if (left) {
      circlePoints.add(Offset(rect.left - margin - corner, rect.top - corner));
      points.add(Offset(rect.left - margin - corner, rect.top - corner));
      points.add(Offset(rect.left - margin, rect.top));
      points.add(Offset(rect.left - margin, rect.bottom));
      points.add(Offset(rect.left - margin - corner, rect.bottom + corner));
      circlePoints.add(Offset(rect.left - margin - corner, rect.bottom + corner));
    } else {
      circlePoints.add(Offset(rect.right + margin + corner, rect.top - corner));
      points.add(Offset(rect.right + margin + corner, rect.top - corner));
      points.add(Offset(rect.right + margin, rect.top));
      points.add(Offset(rect.right + margin, rect.bottom));
      points.add(Offset(rect.right + margin + corner, rect.bottom + corner));
      circlePoints.add(Offset(rect.right + margin + corner, rect.bottom + corner));
    }
    Path p = Path();
    p.addPolygon(points, false);
    // Draw border
    canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = getColorWithThresholds("border_color")
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = width);

    for (var circlePoint in circlePoints) {
      canvas.drawCircle(circlePoint, width * 2, Paint()
        ..color = getColorWithThresholds("border_color")
          ..style = PaintingStyle.fill
      );
    }
  }

  @override
  void drawPost(Canvas canvas, Rect rect, MapItem item) {
    drawBrace(canvas, rect, true);
    drawBrace(canvas, rect, false);
  }

  @override
  List<MapItemPropGroup> propGroupsOfDecorator() {
    List<MapItemPropGroup> groups = [];
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "border_color", "Border Color", "color", "247176"));
      props.add(MapItemPropItem("", "border_width", "Border Width", "double", "1"));
      props.add(MapItemPropItem("", "back_color", "Background Color", "color", "000000"));
      groups.add(MapItemPropGroup("Line2", true, props));
    }
    return groups;
  }

  @override
  List<MapItemPropItem> propThresholdOfItem() {
    List<MapItemPropItem> props = [];
    props.add(MapItemPropItem("", "border_color", "Border Color", "color", "247176"));
    props.add(MapItemPropItem("", "border_width", "Border Width", "double", "1"));
    props.add(MapItemPropItem("", "back_color", "Background Color", "color", "000000"));
    return props;
  }
}
