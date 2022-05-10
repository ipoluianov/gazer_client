import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';

class Border08Painter extends CustomPainter {
  bool hover;
  bool current;
  Border08Painter(this.hover, this.current);

  static Widget build(bool hover, bool current) {
    return CustomPaint(
      painter: Border08Painter(hover, current),
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

  Path buildPathBorder(Rect rectOriginal) {
    Path p = Path();
    p.addPolygon(buildPointsBorder(buildRect(rectOriginal)), false);
    return p;
  }
  double thickness = 5;

  double calcCornerRadius() {
    return 5;
  }

  List<Offset> buildPoints(Rect rect) {
    List<Offset> points = [];
    var cornerRadius = calcCornerRadius();
    points.add(Offset(rect.left, rect.top));
    points.add(Offset(rect.right, rect.top));
    points.add(Offset(rect.right, rect.bottom));
    points.add(Offset(rect.left, rect.bottom));
    return points;
  }

  List<Offset> buildPointsBorder(Rect rect) {
    List<Offset> points = [];
    var cornerRadius = calcCornerRadius();
    //points.add(Offset(rect.left, rect.top));
    //points.add(Offset(rect.right, rect.top));
    points.add(Offset(rect.right, rect.bottom));
    points.add(Offset(rect.left, rect.bottom));
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

      canvas.drawLine(Offset(0, size.height - 1), Offset(size.width - 0, size.height - 1), Paint()
        //..isAntiAlias = false
        ..style = PaintingStyle.stroke
        ..color = DesignColors.fore2()
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 1);

      // Draw border
      /*canvas.drawPath(
          buildPathBorder(rect),
          );*/
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
