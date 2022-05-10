import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';

class Border04Painter extends CustomPainter {
  bool hover;
  Border04Painter(this.hover);

  static Widget build(bool hover) {
    return Container(
      padding: const EdgeInsets.all(3),
      child: CustomPaint(
        painter: Border04Painter(hover),
        child: Container(),
        key: UniqueKey(),
      ),);
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
    return 6;
  }

  List<Offset> buildPoints(Rect rect) {
    List<Offset> points = [];
    var cornerRadius1 = 0;
    var cornerRadius2 = 6;

    points.add(Offset(rect.left, rect.top));
    points.add(Offset(rect.right, rect.top));
    points.add(Offset(rect.right, rect.bottom));
    points.add(Offset(rect.left, rect.bottom));

    return points;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    Color backColor = DesignColors.mainBackgroundColor;
    if (hover) {
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

    /*{
      // Draw border
      canvas.drawPath(
          buildPath(rect),
          Paint()
            ..isAntiAlias = false
            ..style = PaintingStyle.stroke
            ..color = DesignColors.back1()
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = thickness);
    }*/

    {
      // Draw border
      canvas.drawLine(
          Offset(0, size.height), Offset(size.width, size.height),
          Paint()
            //..isAntiAlias = false
            ..style = PaintingStyle.stroke
            ..color = DesignColors.fore1()
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..strokeWidth = thickness);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
