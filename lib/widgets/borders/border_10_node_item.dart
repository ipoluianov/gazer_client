import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';

class Border10Painter extends CustomPainter {
  bool hover;
  Border10Painter(this.hover);

  static Widget build(bool hover) {
    return CustomPaint(
      painter: Border10Painter(hover),
      child: Container(),
      key: UniqueKey(),
    );
  }

  Rect buildRect(Rect rectOriginal) {
    return Rect.fromLTWH(rectOriginal.left, rectOriginal.top,
        rectOriginal.width, rectOriginal.height);
  }

  Path buildPath(Rect rectOriginal) {
    Path p = Path();
    p.addPolygon(buildPoints(buildRect(rectOriginal)), true);
    return p;
  }

  double thickness = 1;

  double calcCornerRadius() {
    return 5;
  }

  List<Offset> buildPoints(Rect rect) {
    List<Offset> points = [];
    var cornerRadius = calcCornerRadius();
    var topRegion = rect.width / 3 - cornerRadius / 2;

    points.add(Offset(rect.left, rect.top + cornerRadius));
    points.add(Offset(rect.left + topRegion, rect.top + cornerRadius));
    points.add(Offset(rect.left + topRegion + cornerRadius, rect.top));
    points.add(
        Offset(rect.left + topRegion + cornerRadius + topRegion, rect.top));
    points.add(Offset(
        rect.left + topRegion + cornerRadius + topRegion + cornerRadius,
        rect.top + cornerRadius));

    points.add(Offset(
        rect.left +
            topRegion +
            cornerRadius +
            topRegion +
            cornerRadius +
            topRegion,
        rect.top + cornerRadius));

    points.add(Offset(rect.right, rect.bottom));

    points.add(Offset(rect.left, rect.bottom));
    points.add(Offset(rect.left, rect.top + cornerRadius));
    return points;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    Color backColor = DesignColors.mainBackgroundColor;
    if (hover) {
      backColor = DesignColors.back1();
    }

    canvas.save();
    Path path = Path();
    path.addPolygon(buildPoints(rect), true);
    canvas.clipPath(path);
    canvas.drawRect(
        Rect.fromLTWH(
            -calcCornerRadius(),
            -calcCornerRadius(),
            size.width + calcCornerRadius() * 2,
            size.height + calcCornerRadius() * 2),
        Paint()
          ..style = PaintingStyle.fill
          ..color = backColor);
    canvas.restore();

    /*{
      // Draw border
      canvas.drawPath(
          buildPath(rect),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = DesignColors.fore().withOpacity(0.3)
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = thickness + 1);
    }*/

    {
      // Draw border
      canvas.drawPath(
          buildPath(rect),
          Paint()
            //..isAntiAlias = false
            ..style = PaintingStyle.stroke
            ..color = DesignColors.fore2()
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = thickness);
      canvas.drawPath(
          buildPath(rect),
          Paint()
            //..isAntiAlias = false
            ..style = PaintingStyle.stroke
            ..color = DesignColors.fore2().withOpacity(0.1)
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = thickness * 4);
      canvas.drawPath(
          buildPath(rect),
          Paint()
            //..isAntiAlias = false
            ..style = PaintingStyle.stroke
            ..color = DesignColors.fore2().withOpacity(0.05)
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = thickness * 6);
      canvas.drawPath(
          buildPath(rect),
          Paint()
            //..isAntiAlias = false
            ..style = PaintingStyle.stroke
            ..color = DesignColors.fore2().withOpacity(0.02)
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = thickness * 8);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
