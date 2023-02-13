import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';

class Border02Painter extends CustomPainter {
  bool hover;
  Border02Painter(this.hover);

  static Widget build(bool hover) {
    return Container(
      padding: const EdgeInsets.all(3),
      child: CustomPaint(
        painter: Border02Painter(hover),
        child: Container(),
        key: UniqueKey(),
      ),
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

  double thickness = 2;

  double calcCornerRadius() {
    return 12;
  }

  List<Offset> buildPoints(Rect rect) {
    List<Offset> points = [];
    var cornerRadius = calcCornerRadius();
    points.add(Offset(rect.left, rect.top));
    points.add(Offset(rect.right, rect.top));
    points.add(Offset(rect.right, rect.bottom));

    double plateWidth = rect.width / 3;

    if (plateWidth > 200) {
      points.add(Offset(rect.width / 2 + plateWidth / 2, rect.bottom));
      points.add(Offset(rect.width / 2 + plateWidth / 2 - cornerRadius,
          rect.bottom - cornerRadius));
      points.add(Offset(rect.width / 2 - plateWidth / 2 + cornerRadius,
          rect.bottom - cornerRadius));
      points.add(Offset(rect.width / 2 - plateWidth / 2, rect.bottom));
    }

    points.add(Offset(rect.left, rect.bottom));
    points.add(Offset(rect.left, rect.bottom - cornerRadius));
    return points;
  }

  Path buildPathBorder(Rect rect) {
    List<Offset> points = [];
    var cornerRadius = calcCornerRadius();
    points.add(Offset(rect.right, rect.bottom));

    double plateWidth = rect.width / 3;

    if (plateWidth > 200) {
      points.add(Offset(rect.width / 2 + plateWidth / 2, rect.bottom));
      points.add(Offset(rect.width / 2 + plateWidth / 2 - cornerRadius,
          rect.bottom - cornerRadius));
      points.add(Offset(rect.width / 2 - plateWidth / 2 + cornerRadius,
          rect.bottom - cornerRadius));
      points.add(Offset(rect.width / 2 - plateWidth / 2, rect.bottom));
    }

    points.add(Offset(rect.left, rect.bottom));
    Path p = Path();
    p.addPolygon(points, false);
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    Color backColor = DesignColors.back();

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

    {
      // Draw border
      canvas.drawPath(
          buildPathBorder(rect),
          Paint()
            //..isAntiAlias = false
            ..style = PaintingStyle.stroke
            ..color = DesignColors.fore2().withOpacity(0.02)
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = 8);
      canvas.drawPath(
          buildPathBorder(rect),
          Paint()
            //..isAntiAlias = false
            ..style = PaintingStyle.stroke
            ..color = DesignColors.fore2().withOpacity(0.05)
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = 6);
      canvas.drawPath(
          buildPathBorder(rect),
          Paint()
            //..isAntiAlias = false
            ..style = PaintingStyle.stroke
            ..color = DesignColors.fore2().withOpacity(0.1)
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = 4);
      canvas.drawPath(
          buildPathBorder(rect),
          Paint()
            //..isAntiAlias = false
            ..style = PaintingStyle.stroke
            ..color = DesignColors.fore2()
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
