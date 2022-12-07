import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/protocol/dataitem/data_item_history_chart.dart';
import 'package:intl/intl.dart' as international;

class TimeChartVerticalScale {
  static const double defaultVerticalScaleWidth = 0;
  static const double defaultVerticalScaleWidthInline = 50;

  double xOffset = 0;
  double yOffset = 0;
  double width = 0;
  double height = 0;
  //double verticalScaleWidth = 0;

  double verticalValuePadding01 = 0.2;

  double targetDisplayedMinY = double.maxFinite;
  double targetDisplayedMaxY = -double.maxFinite;

  double displayedMinY = 0;
  double displayedMaxY = 0;

  void animation() {
    var diff = displayedMinY = targetDisplayedMinY;
    //print("diff: $diff");
    displayedMinY = targetDisplayedMinY;
    displayedMaxY = targetDisplayedMaxY;
  }

  void calc(double x, double y, double w, double h) {
    xOffset = x;
    yOffset = y;
    width = w;
    height = h;
  }

  void draw(Canvas canvas, Size size, Color color, int index, bool showLegend,
      int totalCount) {
    canvas.save();
    if (showLegend && totalCount > 1) {
      canvas.clipRect(Rect.fromLTWH(xOffset, (index + 1) * 22, width, height));
    }
    canvas.drawRect(
        Rect.fromLTWH(xOffset, 0, width, height),
        Paint()
          ..style = PaintingStyle.fill
          ..strokeWidth = 1
          ..color = color.withOpacity(0.3));

    /*canvas.drawRect(
        Rect.fromLTWH(xOffset, 0, width, height),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = color);*/

    var vertScalePointsCount = (height / 70).round();

    var verticalScale =
        getBeautifulScale(displayedMinY, displayedMaxY, vertScalePointsCount);
    for (var vertScaleItem in verticalScale) {
      var posY = verValueToPixel(vertScaleItem);
      if (posY.isNaN) {
        continue;
      }
      canvas.drawRect(
          Rect.fromLTWH(xOffset, posY - 8, width, 20),
          Paint()
            ..style = PaintingStyle.fill
            ..strokeWidth = 1
            ..color = Colors.black.withOpacity(0.5));

      drawText(canvas, xOffset, posY - 8, width - 5, 20,
          formatValue(vertScaleItem), 12, color, TextAlign.right);
      canvas.drawLine(
          Offset(xOffset + width - 3, posY),
          Offset(xOffset + width, posY),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
            ..color = color);

      canvas.drawLine(
          Offset(xOffset + width - 3, posY),
          Offset(xOffset + width + size.width, posY),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = color.withOpacity(0.2));
    }

    /*canvas.drawLine(
        Offset(xOffset + width, 0),
        Offset(xOffset + width, height),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.redAccent);*/

    canvas.restore();
  }

  void updateVerticalScaleValues(
      List<DataItemHistoryChartItemValueResponse> history, bool united) {
    if (!united) {
      targetDisplayedMinY = double.maxFinite;
      targetDisplayedMaxY = -double.maxFinite;
    }
    for (int i = 0; i < history.length; i++) {
      var value = history[i];
      if (value.minValue < targetDisplayedMinY) {
        targetDisplayedMinY = value.minValue;
      }
      if (value.maxValue > targetDisplayedMaxY) {
        targetDisplayedMaxY = value.maxValue;
      }
    }
    if (targetDisplayedMinY != targetDisplayedMaxY) {
      targetDisplayedMinY = targetDisplayedMinY -
          (targetDisplayedMaxY - targetDisplayedMinY) * verticalValuePadding01;
      targetDisplayedMaxY = targetDisplayedMaxY +
          (targetDisplayedMaxY - targetDisplayedMinY) * verticalValuePadding01;
    } else {
      targetDisplayedMinY = targetDisplayedMinY - 1;
      targetDisplayedMaxY = targetDisplayedMaxY + 1;
    }
  }

  void expandToZero() {
    if (targetDisplayedMinY == double.maxFinite ||
        targetDisplayedMaxY == -double.maxFinite) {
      return;
    }

    if (targetDisplayedMinY > 0) {
      targetDisplayedMinY = 0;
    }
    if (targetDisplayedMaxY < 0) {
      targetDisplayedMaxY = 0;
    }
  }

  final f = international.NumberFormat("#.##########");
  String formatValue(num n) {
    return f.format(n);
  }

  List<double> getBeautifulScale(double min, double max, int countOfPoints) {
    List<double> scale = [];

    if (max < min) {
      return scale;
    }

    if (max == min) {
      scale.add(min);
      return scale;
    }

    var diapason = max - min;
    var step = diapason / countOfPoints;

    double log10(num x) => log(x) / ln10;
    var log1 = log10(step).roundToDouble();
    var step10 = pow(10, log1);

    while (diapason / step10 < countOfPoints) {
      step10 = step10 / 2;
    }

    for (var newMin = min - (min % step10); newMin < max; newMin += step10) {
      scale.add(newMin);
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
        overflow: TextOverflow.fade,
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

  double verValueToPixel(double value) {
    var diapason = displayedMaxY - displayedMinY;
    var offsetOfValueFromMin = value - displayedMinY;
    var onePixelValue = height / diapason;
    return height - onePixelValue * offsetOfValueFromMin;
  }

  double verPixelToValue(double pixels) {
    var diapason = displayedMaxY - displayedMinY;
    var onePixelValue = height / diapason;
    return pixels / onePixelValue + displayedMinY;
  }
}
