import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import '../../../../utils/draw_text.dart';
import '../../../main/map_item.dart';
import '../map_item_decoration.dart';

class MapItemDecorationBorder02 extends MapItemDecoration {
  static const String sType = "decoration.border.02";
  static const String sName = "Decoration.border.02";
  @override
  String type() {
    return sType;
  }

  MapItemDecorationBorder02(Connection connection) : super(connection) {}

  @override
  void setDefaultsForItem() {
    setDouble("w", 200);
    setDouble("h", 50);
  }

  List<Offset> buildPointsRT(Rect rect, double padding) {
    List<Offset> points = [];
    points.add(Offset(rect.left + padding, rect.top + padding));
    points.add(Offset(rect.left + rect.width - padding, rect.top + padding));
    points.add(Offset(
        rect.left + rect.width - padding, rect.top + rect.height - padding));
    return points;
  }

  List<Offset> buildPointsLT(Rect rect, double padding) {
    List<Offset> points = [];
    points.add(Offset(rect.left + padding, rect.top + rect.height - padding));
    points.add(Offset(rect.left + padding, rect.top + padding));
    points.add(Offset(rect.left + rect.width - padding, rect.top + padding));
    return points;
  }

  List<Offset> buildPointsRB(Rect rect, double padding) {
    List<Offset> points = [];
    points.add(Offset(rect.left + rect.width - padding, rect.top + padding));
    points.add(Offset(
        rect.left + rect.width - padding, rect.top + rect.height - padding));
    points.add(Offset(rect.left + padding, rect.top + rect.height - padding));
    return points;
  }

  List<Offset> buildPointsLB(Rect rect, double padding) {
    List<Offset> points = [];
    points.add(Offset(rect.left + padding, rect.top + padding));
    points.add(Offset(rect.left + padding, rect.top + rect.height - padding));
    points.add(Offset(
        rect.left + rect.width - padding, rect.top + rect.height - padding));
    return points;
  }

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    drawPre(canvas, size);

    Rect rect = Rect.fromLTWH(
        getDoubleZ("x"), getDoubleZ("y"), getDoubleZ("w"), getDoubleZ("h"));

    canvas.save();
    List<Offset> points = [];
    switch (get("kind")) {
      case "LT":
        points = buildPointsLT(rect, getDoubleZ("padding"));
        break;
      case "RT":
        points = buildPointsRT(rect, getDoubleZ("padding"));
        break;
      case "LB":
        points = buildPointsLB(rect, getDoubleZ("padding"));
        break;
      case "RB":
        points = buildPointsRB(rect, getDoubleZ("padding"));
        break;
    }
    if (points.length > 2) {
      Path path = Path();
      path.addPolygon(points, false);
      canvas.drawPath(
          path,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = getDoubleZ("line_width")
            ..color = getColor("line_color"));

      canvas.drawCircle(
        points.first,
        getDoubleZ("points_radius"),
        Paint()
          ..color = getColor("points_color")
          ..style = PaintingStyle.fill,
      );

      canvas.drawCircle(
        points.last,
        getDoubleZ("points_radius"),
        Paint()
          ..color = getColor("points_color")
          ..style = PaintingStyle.fill,
      );
    }

    canvas.restore();

    drawPost(canvas, size);
  }

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    groups.addAll(super.propGroupsOfItem());

    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "padding", "Padding", "double", "10"));
      props.add(
          MapItemPropItem("", "kind", "Kind", "options:LT:RT:LB:RB", "LT"));
      props.add(
          MapItemPropItem("", "line_color", "Line Color", "color", "FF00EFFF"));
      props.add(
          MapItemPropItem("", "line_width", "Line Width", "double", "0.7"));
      props.add(MapItemPropItem(
          "", "points_color", "Points Color", "color", "FF00EFFF"));
      props.add(
          MapItemPropItem("", "points_radius", "Points Radius", "double", "2"));
      groups.add(MapItemPropGroup("Decoration", true, props));
    }
    groups.add(borderGroup(borderWidthDefault: "0"));
    groups.add(backgroundGroup());
    return groups;
  }

  @override
  void tick() {}

  @override
  void resetToEndOfAnimation() {}
}
