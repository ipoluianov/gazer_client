import 'package:flutter/material.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import '../../../../utils/draw_text.dart';
import '../../../main/map_item.dart';
import '../map_item_decoration.dart';

class MapItemDecorationBorder01 extends MapItemDecoration {
  static const String sType = "decoration.border.01";
  static const String sName = "Decoration.border.01";
  @override
  String type() {
    return sType;
  }

  //double realValue = 0.0;
  //double targetValue = 0.0;
  //double lastValue = 0.0;
  //double aniCounter = 0.0;

  MapItemDecorationBorder01(Connection connection) : super(connection) {}

  @override
  void setDefaultsForItem() {
    setDouble("w", 200);
    setDouble("h", 200);
  }

  Rect buildRect(Rect rectOriginal) {
    return Rect.fromLTWH(rectOriginal.left, rectOriginal.top,
        rectOriginal.width, rectOriginal.height);
  }

  Path buildPath(Rect rectOriginal, double corner) {
    Path p = Path();
    p.addPolygon(buildPoints(buildRect(rectOriginal), corner), true);
    return p;
  }

  List<Offset> buildPoints(Rect rect, double corner) {
    List<Offset> points = [];
    var cornerRadius = corner;
    points.add(Offset(rect.left + cornerRadius, rect.top));
    points.add(Offset(rect.left + rect.width / 2 - cornerRadius, rect.top));
    points.add(Offset(rect.left + rect.width / 2, rect.top + cornerRadius));
    points.add(Offset(rect.right, rect.top + cornerRadius));
    points.add(Offset(rect.right, rect.bottom));

    points.add(Offset(
        rect.left + rect.width / 2 + cornerRadius - cornerRadius / 2,
        rect.bottom));
    points.add(Offset(rect.left + rect.width / 2 - cornerRadius / 2,
        rect.bottom - cornerRadius));

    points
        .add(Offset(rect.left + cornerRadius / 2, rect.bottom - cornerRadius));
    points
        .add(Offset(rect.left, rect.bottom - cornerRadius - cornerRadius / 2));
    points.add(Offset(rect.left, rect.top + cornerRadius));
    return points;
  }

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    drawPre(canvas, size);

    Rect rect = Rect.fromLTWH(
        getDoubleZ("x"), getDoubleZ("y"), getDoubleZ("w"), getDoubleZ("h"));
    PaintingStyle paintingStyle = PaintingStyle.stroke;
    if (getBool("decor_fill")) paintingStyle = PaintingStyle.fill;
    double strokeWidth = getDouble("decor_width");
    double corner = getDouble("decor_corner");

    canvas.save();
    Path path = Path();
    path.addPolygon(buildPoints(rect, corner), true);
    canvas.clipPath(path);
    canvas.drawPath(
        path,
        Paint()
          ..style = paintingStyle
          ..strokeWidth = z(strokeWidth)
          ..color = getColor("decor_color"));

    canvas.restore();

    drawPost(canvas, size);
  }

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    groups.addAll(super.propGroupsOfItem());
    {
      List<MapItemPropItem> props = [];
      props.add(
          MapItemPropItem("", "decor_color", "Color", "color", "FF00EFFF"));
      props.add(MapItemPropItem("", "decor_fill", "Fill", "bool", "false"));
      props.add(MapItemPropItem("", "decor_width", "Width", "double", "3"));
      props.add(MapItemPropItem("", "decor_corner", "Corner", "double", "10"));
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
