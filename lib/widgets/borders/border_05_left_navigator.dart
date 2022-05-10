import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';

class Border05Painter extends CustomPainter {
  bool hover;
  bool current;
  Border05Painter(this.hover, this.current);

  static Widget build(bool hover, bool current) {
    return CustomPaint(
      painter: Border05Painter(hover, current),
      child: Container(),
      key: UniqueKey(),
    );
  }

  Rect buildRect(Rect rectOriginal) {
    return Rect.fromLTWH(rectOriginal.left, rectOriginal.top, rectOriginal.width, rectOriginal.height);
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
    points.add(Offset(rect.left + cornerRadius, rect.top));
    points.add(Offset(rect.left + rect.width / 2 - cornerRadius, rect.top));
    points.add(Offset(rect.left + rect.width / 2, rect.top + cornerRadius));
    points.add(Offset(rect.right, rect.top + cornerRadius));
    points.add(Offset(rect.right, rect.bottom + cornerRadius));

    points.add(Offset(rect.left + rect.width / 2 + cornerRadius - cornerRadius / 2, rect.bottom + cornerRadius));
    points.add(Offset(rect.left + rect.width / 2 - cornerRadius / 2, rect.bottom));

    points.add(Offset(rect.left + cornerRadius / 2, rect.bottom));
    points.add(Offset(rect.left, rect.bottom - cornerRadius / 2));
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
    if (current) {
      backColor = DesignColors.back2();
    }

    canvas.save();
    Path path = Path();
    path.addPolygon(buildPoints(rect), true);
    canvas.clipPath(path);
    canvas.drawRect(
        Rect.fromLTWH(-calcCornerRadius(), -calcCornerRadius(), size.width + calcCornerRadius() * 2, size.height + calcCornerRadius() * 2),
        Paint()
          ..style = PaintingStyle.fill
          ..color = backColor);
    canvas.restore();

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
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
