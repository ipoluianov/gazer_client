import "dart:math";

import "dart:ui";

void drawDashes(Canvas canvas, Color color, Rect rect, int count, double width,
    double offsetAngle,
    {imageFilter}) {
  double angle = 0;
  double step = 1;
  if (count > 0) {
    step = 2 * pi / count;
  } else {
    step = 2 * 2 * pi;
  }
  for (angle = 0; angle < 2 * pi; angle += step) {
    canvas.drawArc(
      rect,
      offsetAngle + angle,
      step / 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..color = color
        ..strokeWidth = width
        ..imageFilter = imageFilter,
    );
  }
}
