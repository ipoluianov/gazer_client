import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as international;

class TimeChartHorizontalScale {
  double xOffset = 0;
  double yOffset = 0;
  double width = 0;
  double height = 30;

  double displayMin = 0;
  double displayMax = 0;

  double defaultDisplayMin = 0;
  double defaultDisplayMax = 0;

  bool fixedHorScale = false;

  void resetToDefaultDisplayRange() {
    displayMin = defaultDisplayMin;
    displayMax = defaultDisplayMax;
  }

  void setDefaultDisplayRange(double min, double max) {
    defaultDisplayMin = min;
    defaultDisplayMax = max;
    if (!fixedHorScale) {
      resetToDefaultDisplayRange();
    }
  }

  void setDisplayRange(double min, double max) {
    displayMin = min;
    displayMax = max;
    if (!fixedHorScale) {
      resetToDefaultDisplayRange();
    }
  }

  void setFixedHorScale(bool fixed) {
    fixedHorScale = fixed;
    if (!fixedHorScale) {
      resetToDefaultDisplayRange();
    }
  }

  void calc(double x, double y, double w, double h) {
    xOffset = x;
    yOffset = y;
    width = w;
    height = h;
  }

  void draw(Canvas canvas, Size size) {
    if (height < 1) {
      return;
    }

    if (xOffset.isInfinite ||
        xOffset.isNaN ||
        yOffset.isInfinite ||
        yOffset.isNaN ||
        width.isInfinite ||
        width.isNaN ||
        height.isInfinite ||
        height.isNaN) {
      return;
    }

    international.DateFormat timeFormat = international.DateFormat("HH:mm:ss");
    international.DateFormat timeShortFormat =
        international.DateFormat("HH:mm");
    international.DateFormat dateFormat =
        international.DateFormat("yyyy-MM-dd");

    var countOfValues = width / 50;
    double diapasonX = (displayMax - displayMin).toDouble();

    double dateTextWidth = 100;
    var displayDatesBlocks = true;
    var countOfDays = diapasonX / (24 * 3600 * 1000000);
    var maxCountOfDaysForDisplay = width / dateTextWidth;
    if (countOfDays > maxCountOfDaysForDisplay) {
      displayDatesBlocks = false;
    }

    List<int> beautifulScale =
        getHorBeautifulScale(displayMin, displayMax, countOfValues.toInt(), 0);

    for (int t in beautifulScale) {
      DateTime dt = DateTime.fromMicrosecondsSinceEpoch(t);

      var dateStr = dateFormat.format(dt);
      var timeStr = timeFormat.format(dt);
      var ms = dt.millisecond;
      var msStr = "";

      if (beautifulScale.length > 1) {
        if (beautifulScale[1] - beautifulScale[0] >= 60 * 1000000) {
          timeStr = timeShortFormat.format(dt);
        }
        if (beautifulScale[1] - beautifulScale[0] < 1000000) {
          msStr = '${ms} ms';
        }
      }

      if (diapasonX > 0) {
        double xPos = ((t - displayMin) / diapasonX) * width;
        double yPos = 0;

        canvas.save();
        canvas.clipRect(Rect.fromLTWH(xOffset, yOffset, width, height));

        canvas.drawLine(
            Offset(xOffset + xPos, yOffset + yPos),
            Offset(xOffset + xPos, yOffset + yPos + 5),
            Paint()
              ..style = PaintingStyle.stroke
              ..color = Colors.yellow
              ..strokeWidth = 3);

        var yOffsetInScale = yOffset + 3;

        double timeWidth = 150;

        /*if (msStr.isNotEmpty) {
          drawText(canvas, xPos + xOffset - timeWidth / 2, yPos + yOffsetInScale, timeWidth, 100, msStr, 12, Colors.blueAccent, TextAlign.center);
          yOffsetInScale += 12;
        }*/

        drawText(canvas, xPos + xOffset - timeWidth / 2, yPos + yOffsetInScale,
            timeWidth, 100, timeStr, 10, Colors.blueAccent, TextAlign.center);
        yOffsetInScale += 12;

        if (!displayDatesBlocks) {
          drawText(
              canvas,
              xPos + xOffset - timeWidth / 2,
              yPos + yOffsetInScale,
              timeWidth,
              100,
              dateStr,
              12,
              Colors.blueAccent,
              TextAlign.center);
        }
        canvas.restore();
      }
    }

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(xOffset, yOffset, width, height));

    if (displayDatesBlocks && diapasonX > 0) {
      var beautifulScaleForDates =
          getBeautifulScaleForDates(displayMin.toInt(), displayMax.toInt());
      var off = yOffset + 14;
      for (int d in beautifulScaleForDates) {
        DateTime dt = DateTime.fromMicrosecondsSinceEpoch(d);

        Color currentColor = Colors.white38;

        var isToday = false;
        var dateNow = DateTime.now();
        if (dateNow.year == dt.year &&
            dateNow.month == dt.month &&
            dateNow.day == dt.day) {
          isToday = true;
        }

        if (isToday) {
          currentColor = Colors.green;
        }

        var dateStr = dateFormat.format(dt);
        var xPos1 = horValueToPixel(d.toDouble());
        var xPos2 = horValueToPixel(d + 24 * 3600 * 1000000);
        var xPos1Visible = xPos1;
        if (xPos1Visible < 0) {
          xPos1Visible = 0;
        }
        var xPos2Visible = xPos2;
        if (xPos2Visible > width) {
          xPos2Visible = width;
        }
        canvas.drawLine(
            Offset(xPos1 + 2, off + 5),
            Offset(xPos1 + 2, off + 20),
            Paint()
              ..style = PaintingStyle.stroke
              ..color = currentColor
              ..strokeWidth = 1);
        canvas.drawLine(
            Offset(xPos2 - 2, off + 5),
            Offset(xPos2 - 2, off + 20),
            Paint()
              ..style = PaintingStyle.stroke
              ..color = currentColor
              ..strokeWidth = 1);
        canvas.drawLine(
            Offset(xPos1 + 5, off + 10),
            Offset(xPos2 - 5, off + 10),
            Paint()
              ..style = PaintingStyle.stroke
              ..color = currentColor
              ..strokeWidth = 1);

        double dateTextHeight = 12;
        var dateTextPosX = xPos1Visible +
            (xPos2Visible - xPos1Visible) / 2 -
            (dateTextWidth / 2);
        var dateTextPosY = off + 3;

        if (dateTextPosX + dateTextWidth > width) {
          dateTextPosX = width - dateTextWidth;
        }

        if (dateTextPosX < xPos1) {
          dateTextPosX = xPos1;
        }

        if (dateTextPosX < 0) {
          dateTextPosX = 0;
        }
        if (dateTextPosX + dateTextWidth > xPos2) {
          dateTextPosX = xPos2 - dateTextWidth;
        }
        //(this.left, this.top, this.right, this.bottom
        canvas.drawRect(
            Rect.fromLTWH(
                dateTextPosX, dateTextPosY, dateTextWidth, dateTextHeight),
            Paint()
              ..style = PaintingStyle.fill
              ..color = Colors.green);
        canvas.drawRect(
            Rect.fromLTWH(
                dateTextPosX, dateTextPosY, dateTextWidth, dateTextHeight),
            Paint()
              ..style = PaintingStyle.stroke
              ..color = Colors.green);

        drawText(canvas, dateTextPosX, dateTextPosY - 1, dateTextWidth,
            dateTextHeight, dateStr, 10, Colors.white, TextAlign.center);
      }
    }

    canvas.drawLine(
        Offset(xOffset, yOffset),
        Offset(xOffset + width, yOffset),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.yellow
          ..strokeWidth = 1);

    canvas.restore();
  }

  List<int> getHorBeautifulScale(
      double min, double max, int countOfPoints, int minStep) {
    List<int> scale = [];

    if (max < min) {
      return scale;
    }

    if (max == min) {
      scale.add(min.toInt());
      return scale;
    }

    var diapason = max - min;
    int step = 1;
    if (countOfPoints != 0) {
      step = (diapason / countOfPoints).round();
    }
    var newMin = min;
    for (int i = 0; i < allowedSteps.length; i++) {
      var st = allowedSteps[i];
      if (st < minStep) {
        continue;
      }
      if (step < st) {
        step = st;
        break;
      }
    }
    newMin = newMin - (newMin % step);

    for (int i = 0; i < countOfPoints; i++) {
      if (newMin > min && newMin < max) {
        scale.add(newMin.toInt());
      }
      newMin += step;
    }

    return scale;
  }

  List<int> allowedSteps = [
    1,
    5,
    10,
    50,
    100,
    500,
    1000,
    5000,
    10000,
    50000,
    100000,
    500000,
    1 * 1000000,
    2 * 1000000,
    5 * 1000000,
    10 * 1000000,
    15 * 1000000,
    30 * 1000000,
    1 * 60 * 1000000,
    2 * 60 * 1000000,
    5 * 60 * 1000000,
    10 * 60 * 1000000,
    15 * 60 * 1000000,
    30 * 60 * 1000000,
    1 * 60 * 60 * 1000000,
    3 * 60 * 60 * 1000000,
    6 * 60 * 60 * 1000000,
    12 * 60 * 60 * 1000000,
    1 * 24 * 3600 * 1000000,
    2 * 24 * 3600 * 1000000,
    7 * 24 * 3600 * 1000000,
    15 * 24 * 3600 * 1000000,
    1 * 30 * 24 * 3600 * 1000000,
    2 * 30 * 24 * 3600 * 1000000,
    3 * 30 * 24 * 3600 * 1000000,
    4 * 30 * 24 * 3600 * 1000000,
    365 * 24 * 3600 * 1000000,
  ];

  List<int> getBeautifulScaleForDates(int min, int max) {
    List<int> scale = [];

    DateTime dt = DateTime.fromMicrosecondsSinceEpoch(min);
    dt = DateTime(dt.year, dt.month, dt.day, 0, 0, 0, 0, 0);
    DateTime dtEnd = DateTime.fromMicrosecondsSinceEpoch(max);
    dtEnd = DateTime(dtEnd.year, dtEnd.month, dtEnd.day, 0, 0, 0, 0, 0);
    dtEnd = dtEnd.add(const Duration(hours: 25));
    for (; dt.isBefore(dtEnd); dt = dt.add(const Duration(hours: 24))) {
      scale.add(dt.microsecondsSinceEpoch);
    }

    return scale;
  }

  void drawText(Canvas canvas, double x, double y, double width, double height,
      String text, double size, Color color, TextAlign align) {
    var textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
      ),
    );
    final textPainter = TextPainter(
        text: textSpan, textDirection: TextDirection.ltr, textAlign: align);
    textPainter.layout(
      minWidth: width,
      maxWidth: width,
    );
    textPainter.paint(canvas, Offset(x, y));
  }

  double horValueToPixel(double time) {
    var diapason = displayMax - displayMin;
    var offsetOfValueFromMin = time - displayMin;
    var onePixelValue = width / diapason;
    return onePixelValue * offsetOfValueFromMin + xOffset;
  }

  double horPixelToValue(double pixels) {
    pixels -= xOffset;
    var diapason = displayMax - displayMin;
    var onePixelValue = width / diapason;
    return pixels / onePixelValue + displayMin;
  }
}
