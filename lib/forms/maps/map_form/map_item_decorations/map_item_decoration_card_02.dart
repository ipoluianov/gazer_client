import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../map_item.dart';
import 'map_item_decoration.dart';

class MapItemDecorationCard02 extends MapItemDecoration {

  MapItemDecorationCard02() {
    showProgress = 0;
  }

  @override
  String type() {
    return "card.02";
  }

  @override
  void tick() {
  }

  double corner(Rect rect) {
    return rect.height / 10;
  }

  Rect buildRect(Rect rectOriginal) {
    return Rect.fromLTWH(rectOriginal.left + ((rectOriginal.width / 2) * (1-showProgress)), rectOriginal.top + ((rectOriginal.height / 2) * (1-showProgress)), rectOriginal.width * showProgress, rectOriginal.height * showProgress);
  }


  Path buildPath(Rect rectOriginal) {
    Path p = Path();
    p.addPolygon(buildPoints(buildRect(rectOriginal)), true);
    return p;
  }

  List<Offset> buildPoints(Rect rect) {
    var cornerRadius = corner(rect);
    List<Offset> points = [];
    points.add(Offset(rect.left, rect.top));
    points.add(Offset(rect.left + cornerRadius, rect.top - cornerRadius));
    points.add(Offset(rect.right, rect.top - cornerRadius));
    points.add(Offset(rect.right, rect.bottom));
    points.add(Offset(rect.right - cornerRadius, rect.bottom + cornerRadius));
    points.add(Offset(rect.left, rect.bottom + cornerRadius));
    return points;
  }

  @override
  void drawPre(Canvas canvas, Rect rect, MapItem item) {
    if (showProgress < 0.001) {
      return;
    }
    drawBack(canvas, buildPoints(buildRect(rect)));
  }

  @override
  void drawPost(Canvas canvas, Rect rect, MapItem item) {

    if (showProgress < 0.001) {
      return;
    }

    var backColor = getColorWithThresholds("back_color");

    double width = getDoubleWithThresholds("width") * zoom;
    {
      // Draw border
      canvas.drawPath(buildPath(rect), Paint()
        ..style = PaintingStyle.stroke
        ..color = getColorWithThresholds("color")
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = width);
    }

    if (showProgress > 0.5) {
      // Draw top/right corner
      {
        var cornerRadius = corner(rect);
        List<Offset> points = [];
        points.add(Offset(rect.left, rect.top - cornerRadius));
        points.add(Offset(rect.left + cornerRadius / 2, rect.top - cornerRadius));
        points.add(Offset(rect.left, rect.top - cornerRadius / 2));
        Path p = Path();
        p.addPolygon(points, true);

        canvas.drawPath(p, Paint()
          ..style = PaintingStyle.fill
          ..color = backColor
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = width);

        canvas.drawPath(p, Paint()
          ..style = PaintingStyle.stroke
          ..color = getColorWithThresholds("color")
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = width);
      }

      {
        var cornerRadius = corner(rect);
        List<Offset> points = [];
        points.add(Offset(rect.right, rect.bottom + cornerRadius));
        points.add(Offset(rect.right - cornerRadius / 2, rect.bottom + cornerRadius));
        points.add(Offset(rect.right, rect.bottom + cornerRadius / 2));
        Path p = Path();
        p.addPolygon(points, true);

        canvas.drawPath(p, Paint()
          ..style = PaintingStyle.fill
          ..color = backColor
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = width);

        canvas.drawPath(p, Paint()
          ..style = PaintingStyle.stroke
          ..color = getColorWithThresholds("color")
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = width);
      }
    }
    {
      var cornerRadius = corner(rect);
      canvas.save();
      Rect textRect = Rect.fromLTWH(rect.left + cornerRadius, rect.top - cornerRadius, rect.width - cornerRadius * 2, cornerRadius);
      canvas.clipRect(textRect);
      drawText(canvas, textRect.left, textRect.top, textRect.width, textRect.height, get("title"), cornerRadius / 2.3, getColorWithThresholds("color"), TextAlign.center);
      canvas.restore();
    }

  }

  void drawText(Canvas canvas, double x, double y, double width, double height, String text, double size, Color color, TextAlign align) {
    var textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
      ),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: align);
    textPainter.layout(
      minWidth: width,
      maxWidth: width,
    );
    textPainter.paint(canvas, Offset(x, y + (height / 2) - (textPainter.height / 2)));
  }


  @override
  List<MapItemPropGroup> propGroupsOfDecorator() {
    List<MapItemPropGroup> groups = [];
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "color", "Color", "color", "247176"));
      props.add(MapItemPropItem("", "back_color", "Background Color", "color", "30247176"));
      props.add(MapItemPropItem("", "back_img", "Background Image", "image", ""));
      props.add(MapItemPropItem("", "back_img_scale_fit", "Background Image Scale Fit", "scale_fit", "contain"));
      props.add(MapItemPropItem("", "width", "Width", "double", "1"));
      props.add(MapItemPropItem("", "title", "Title", "text", ""));
      groups.add(MapItemPropGroup("Line2", true, props));
    }
    return groups;
  }

  @override
  List<MapItemPropItem> propThresholdOfItem() {
    List<MapItemPropItem> props = [];
    props.add(MapItemPropItem("", "color", "Color", "color", "247176"));
    props.add(MapItemPropItem("", "back_color", "Background Color", "color", "30247176"));
    props.add(MapItemPropItem("", "back_img", "Background Image", "image", ""));
    props.add(MapItemPropItem("", "back_img_scale_fit", "Background Image Scale Fit", "scale_fit", "contain"));
    props.add(MapItemPropItem("", "width", "Width", "double", "1"));
    return props;
  }
}
