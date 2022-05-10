import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../map_item.dart';
import 'map_item_decoration.dart';

class MapItemDecorationPipe01 extends MapItemDecoration {
  MapItemDecorationPipe01();

  double progress = 0;

  @override
  String type() {
    return "pipe.01";
  }

  @override
  void tick() {
    var speed = getDoubleWithThresholds("speed") / 100;
    if (speed < -1) {
      speed = -1;
    }
    if (speed > 1) {
      speed = 1;
    }
    speed = speed / 10;
    progress += speed;
    if (progress >= 1) {
      progress = 0;
    }
  }

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
  void drawPre(Canvas canvas, Rect rectOriginal, MapItem item) {
    var progressColor1 = getColorWithThresholds("progress_color1");
    var progressColor2 = getColorWithThresholds("progress_color2");

    var rect = buildRect(rectOriginal);

    canvas.save();
    canvas.clipRect(rect);

    if (getWithThresholds("orientation") == "horizontal") {
      double width = rect.width / 10;
      for (int i = -2; i < 12; i++) {
        canvas.drawRect(Rect.fromLTWH(rect.left + i * width + ((width * 2) * progress), rect.top, width, rect.height), Paint()
          ..color = (i % 2) == 0 ? progressColor1 : progressColor2
          ..style = PaintingStyle.fill
        );
      }
    } else {
      double width = rect.height / 10;
      for (int i = -2; i < 12; i++) {
        canvas.drawRect(Rect.fromLTWH(rect.left, rect.top + i * width + ((width * 2) * progress), rect.width, width), Paint()
          ..color = (i % 2) == 0 ? progressColor1 : progressColor2
          ..style = PaintingStyle.fill
        );
      }
    }

    canvas.restore();
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
      props.add(MapItemPropItem("", "orientation", "Orientation", "orientation", "horizontal"));
      props.add(MapItemPropItem("", "border_color", "Border Color", "color", "247176"));
      props.add(MapItemPropItem("", "border_width", "Border Width", "double", "1"));
      props.add(MapItemPropItem("", "speed", "Speed (0-100)", "double", "50"));
      props.add(MapItemPropItem("", "progress_color1", "Color 1", "color", "30247176"));
      props.add(MapItemPropItem("", "progress_color2", "Color 2", "color", "80247176"));
      groups.add(MapItemPropGroup("Rectangle settings", true, props));
    }
    return groups;
  }

  @override
  List<MapItemPropItem> propThresholdOfItem() {
    List<MapItemPropItem> props = [];
    props.add(MapItemPropItem("", "orientation", "Orientation", "orientation", "horizontal"));
    props.add(MapItemPropItem("", "border_color", "Border Color", "color", "247176"));
    props.add(MapItemPropItem("", "border_width", "Border Width", "double", "1"));
    props.add(MapItemPropItem("", "speed", "Speed (0-100)", "double", "50"));
    props.add(MapItemPropItem("", "progress_color1", "Color 1", "color", "30247176"));
    props.add(MapItemPropItem("", "progress_color2", "Color 2", "color", "80247176"));
    return props;
  }
}
