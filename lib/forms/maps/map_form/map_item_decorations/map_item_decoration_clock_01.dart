import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../map_item.dart';
import 'map_item_decoration.dart';

class MapItemDecorationClock01 extends MapItemDecoration {
  MapItemDecorationClock01() {
    showProgress = 0;
  }

  @override
  String type() {
    return "clock.01";
  }


  @override
  void tick() {
  }

  void drawRadius(Canvas canvas, Offset center, double angle, double startPosition, double endPosition, double width, Color color) {
    angle = angle - pi / 2; // beginning from right to top
    Offset offset1 = Offset(center.dx + startPosition * cos(angle), center.dy + startPosition * sin(angle));
    Offset offset2 = Offset(center.dx + endPosition * cos(angle), center.dy + endPosition * sin(angle));
    canvas.drawLine(offset1, offset2, Paint()
      ..style = PaintingStyle.stroke
      ..color = color
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = width);
  }

  @override
  void drawPre(Canvas canvas, Rect rect, MapItem item) {
    Color borderColor = getColorWithThresholds("border_color");
    Color scaleColor = getColorWithThresholds("scale_color");
    Color hoursColor = getColorWithThresholds("hours_color");
    Color minutesColor = getColorWithThresholds("minutes_color");
    Color secondsColor = getColorWithThresholds("seconds_color");
    Color centerColor = getColorWithThresholds("center_color");

    double hoursWidth = getDoubleWithThresholds("hours_width") * zoom;
    double minutesWidth = getDoubleWithThresholds("minutes_width") * zoom;
    double secondsWidth = getDoubleWithThresholds("seconds_width") * zoom;
    double scaleWidth = getDoubleWithThresholds("scale_width") * zoom;
    double borderWidth = getDoubleWithThresholds("border_width") * zoom;

    var dt = DateTime.now();

    Offset centerOffset = Offset(rect.left + rect.width / 2, rect.top + rect.height / 2);

    double radius = rect.width;
    if (rect.width > rect.height) {
      radius = rect.height;
    }
    radius = radius / 2;
    double radiusWithMargin = radius - borderWidth / 2;

    // Border
    canvas.drawCircle(centerOffset, radiusWithMargin, Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
    );

    // Draw scale
    for (double a = 0; a < 2 * pi; a += ((2 * pi) / 12)) {
      drawRadius(canvas, centerOffset, a, radiusWithMargin - radiusWithMargin / 8, radiusWithMargin - borderWidth / 2, scaleWidth, scaleColor);
    }

    double secondsInDay = (dt.millisecondsSinceEpoch / 1000) % 86400 + (dt.timeZoneOffset.inMilliseconds / 1000);



    double hours01 = (secondsInDay % 43200) / 43200;
    drawRadius(canvas, centerOffset, (hours01) * pi * 2 * showProgress, 0, radiusWithMargin / 1.75, hoursWidth, hoursColor);

    double minutes01 = (secondsInDay % 3600) / 3600;
    drawRadius(canvas, centerOffset, (minutes01) * pi * 2 * showProgress, 0, radiusWithMargin / 1.2, minutesWidth, minutesColor);

    double seconds01 = (secondsInDay % 60) / 60;
    drawRadius(canvas, centerOffset, (seconds01) * pi * 2 * showProgress, 0, radiusWithMargin / 1.1, secondsWidth, secondsColor);

    // Center circle
    canvas.drawCircle(centerOffset, rect.width / 15, Paint()
      ..style = PaintingStyle.fill
      ..color = centerColor);
  }

  @override
  List<MapItemPropGroup> propGroupsOfDecorator() {
    List<MapItemPropGroup> groups = [];
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "border_color", "Border Color", "color", "247176"));
      props.add(MapItemPropItem("", "scale_color", "Scale Color", "color", "247176"));
      props.add(MapItemPropItem("", "hours_color", "Hours Color", "color", "FF00EFFF"));
      props.add(MapItemPropItem("", "minutes_color", "Minutes Color", "color", "8000EFFF"));
      props.add(MapItemPropItem("", "seconds_color", "Seconds Color", "color", "247176"));
      props.add(MapItemPropItem("", "center_color", "Center Color", "color", "247176"));
      groups.add(MapItemPropGroup("Colors", true, props));
    }
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "hours_width", "Hours Width", "double", "15"));
      props.add(MapItemPropItem("", "minutes_width", "Minutes Width", "double", "8"));
      props.add(MapItemPropItem("", "seconds_width", "Seconds Width", "double", "3"));
      props.add(MapItemPropItem("", "scale_width", "Scale Width", "double", "3"));
      props.add(MapItemPropItem("", "border_width", "Border Width", "double", "5"));
      groups.add(MapItemPropGroup("Colors", true, props));
    }
    return groups;
  }

  @override
  List<MapItemPropItem> propThresholdOfItem() {
    List<MapItemPropItem> props = [];
    props.add(MapItemPropItem("", "border_color", "Border Color", "color", "247176"));
    props.add(MapItemPropItem("", "scale_color", "Scale Color", "color", "247176"));
    props.add(MapItemPropItem("", "hours_color", "Hours Color", "color", "FF00EFFF"));
    props.add(MapItemPropItem("", "minutes_color", "Minutes Color", "color", "8000EFFF"));
    props.add(MapItemPropItem("", "seconds_color", "Seconds Color", "color", "247176"));
    props.add(MapItemPropItem("", "center_color", "Center Color", "color", "247176"));
    return props;
  }
}
