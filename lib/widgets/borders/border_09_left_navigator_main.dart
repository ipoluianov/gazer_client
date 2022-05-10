import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';

class Border09Painter extends CustomPainter {
  bool hover;
  Border09Painter(this.hover);

  static Widget build(bool hover) {
    return Container(
      padding: const EdgeInsets.all(3),
      child: CustomPaint(
        painter: Border09Painter(hover),
        child: Container(),
        key: UniqueKey(),
      ),);
  }

  Rect buildRect(Rect rectOriginal) {
    return Rect.fromLTWH(rectOriginal.left, rectOriginal.top, rectOriginal.width, rectOriginal.height);
  }


  double thickness = 2;

  double calcCornerRadius() {
    return 12;
  }

  Path buildPathBorder(Rect rect) {
    List<Offset> points = [];
    points.add(Offset(rect.right, rect.top + 10));
    points.add(Offset(rect.right, rect.bottom - 10));
    Path p = Path();
    p.addPolygon(points, false);
    return p;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    Color backColor = DesignColors.back();

    {
      // Draw border
      canvas.drawPath(
          buildPathBorder(rect),
          Paint()
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
