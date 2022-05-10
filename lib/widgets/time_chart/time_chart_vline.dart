
class VLine {
  int X = 0;
  bool hasValues = false;
  double minYValue = 0.0;
  double maxYValue = 0.0;
  double minY = 0.0;
  double maxY = 0.0;
  double firstY = 0.0;
  double lastY = 0.0;

  int minYp = 0;
  int maxYp = 0;

  bool hasY = false;
  bool hasBegin = false;
  bool hasEnd = false;
  bool hasBadQuality = false;
}

/*
  void fillVLine(VLine? vLineWithNull, DataItemHistoryChartItemResponse value, int x) {
    if (vLineWithNull == null) {
      return;
    }
    VLine vLine = vLineWithNull;
    vLine.X = x;
    bool good = value.hasGood;

    if (good) {
      if (!vLine.hasY) {
        vLine.hasY = true;
        if (!vLine.hasBadQuality) {
          vLine.hasBegin = true;
        }
        vLine.hasEnd = true;
        vLine.hasValues = true;
        vLine.firstY = value.firstValue;
        vLine.lastY = value.lastValue;
        vLine.minY = value.minValue;
        vLine.maxY = value.maxValue;
        vLine.minYValue = value.minValue;
        vLine.maxYValue = value.maxValue;
      } else {
        vLine.hasEnd = true;
        vLine.hasValues = true;
        vLine.lastY = value.minValue;
        if (value.minValue < vLine.minY) {
          vLine.minY = value.minValue;
        }
        if (value.maxValue > vLine.maxY) {
          vLine.maxY = value.maxValue;
        }
      }
    } else {
      vLine.hasBadQuality = true;
      vLine.hasEnd = false;
      if (!vLine.hasValues) {
        vLine.hasBegin = false;
      }
      vLine.hasValues = true;
    }
  }

  void drawVLine(Canvas canvas, VLine? vLineWithNull, double xOffset) {
    //print("XOffset: $xOffset");
    xOffset = 0;

    if (vLineWithNull == null) {
      return;
    }
    VLine vLine = vLineWithNull;
    if (!vLine.hasValues) {
      return;
    }

    int lineWidth = 1;

    if (vLine.hasY) {
      //print("MINVAL: ${settings.displayedMaxY}");
      vLine.minYp = settings.verValueToPixel(vLine.minY).round();
      vLine.maxYp = settings.verValueToPixel(vLine.maxY).round();

      if (vl_previousHasEnd && vLine.hasBegin) {
        var firstYp = settings.verValueToPixel(vLine.firstY);
        bool needToDraw = true;
        if (vLine.X - vl_lastPointX < 2) {
          if ((vLine.minYp < vl_lastPointYMin && vLine.minYp > vl_lastPointXMax) || (vLine.maxYp < vl_lastPointYMin && vLine.maxYp > vl_lastPointXMax)) {
            needToDraw = false;
          }
        }
        if (needToDraw) {
          canvas.drawLine(
              Offset(vl_lastPointX + xOffset, vl_lastPointY.toDouble()),
              Offset(vLine.X.toDouble() + xOffset, firstYp),
              Paint()
                ..strokeWidth = 1
                ..color = Colors.blue);
        }
      }

      if (vLine.minY != vLine.maxY) {
        canvas.drawLine(
            Offset(vLine.X.toDouble() + xOffset, vLine.minYp.toDouble()),
            Offset(vLine.X.toDouble() + xOffset, vLine.maxYp.toDouble()),
            Paint()
              ..strokeWidth = 1
              ..color = Colors.blue);
      }
    }

    if (vLine.hasEnd) {
      vl_previousHasEnd = true;
      vl_lastPointX = vLine.X;
    } else {
      vl_previousHasEnd = false;
    }

    vl_lastPointY = settings.verValueToPixel(vLine.lastY).toInt();
    vl_lastPointYMin = vLine.minYp;
    vl_lastPointXMax = vLine.maxYp;
  }

    double widthOfWorkspace = width;
    var diapason = 1;
    if (diapason > 0) {
      VLine? vLineFirst;
      VLine? vLineLast;

      int firstPoint = -1;
      int lastPoint = -1;

      List<VLine> vLines = List<VLine>.filled(widthOfWorkspace.round(), VLine());

      bool hasLastPoint = false;
      int countPointsWithValue = 0;
      for (int i = 0; i < widthOfWorkspace.round(); i++) {
        vLines[i] = VLine();
        vLines[i].X = i;
      }

      settings.displayedMinY = double.maxFinite;
      settings.displayedMaxY = -double.maxFinite;

      for (int index = 0; index < history.length; index++) {
        var value = history[index];
        int valueX = value.datetimeFirst;
        var x = settings.horValueToPixel(valueX.toDouble()).round();

        if (x >= 0 && x < vLines.length) {
          if (firstPoint == -1) {
            firstPoint = index;
          }
          lastPoint = index;

          fillVLine(vLines[x], value, x);

          if (value.minValue < settings.displayedMinY) {
            settings.displayedMinY = value.minValue;
          }
          if (value.maxValue > settings.displayedMaxY) {
            settings.displayedMaxY = value.maxValue;
          }
        }
      }

      if (settings.displayedMinY != settings.displayedMaxY) {
        settings.displayedMinY = settings.displayedMinY - (settings.displayedMaxY - settings.displayedMinY) / 20;
        settings.displayedMaxY = settings.displayedMaxY + (settings.displayedMaxY - settings.displayedMinY) / 20;
      }

      if (firstPoint > 0) {
        fillVLine(vLineFirst, history[firstPoint-1], settings.horValueToPixel(history[firstPoint-1].datetimeFirst.toDouble()).round());
      }

      if (lastPoint < history.length - 1) {
        fillVLine(vLineLast, history[lastPoint+1], settings.horValueToPixel(history[lastPoint + 1].datetimeFirst.toDouble()).round());
      }

      vl_lastPointX = 0;
      vl_lastPointY = 0;
      vl_lastPointYMin = 0;
      vl_lastPointXMax = 0;
      vl_previousHasEnd = false;

      if (firstPoint > 0) {
        drawVLine(canvas, vLineFirst, xOffset);
      }

      VLine firstVLine; // For single point

      for (int i = 0; i < vLines.length; i++) {
        drawVLine(canvas, vLines[i], xOffset);
        if (vLines[i].hasValues) {
          countPointsWithValue++;
          if (countPointsWithValue == 1) {
            firstVLine = vLines[i];
          }
        }
      }

      if (lastPoint < history.length - 1) {
        drawVLine(canvas, vLineLast, xOffset);
      }

  int vl_lastPointX = 0;
  int vl_lastPointY = 0;
  int vl_lastPointYMin = 0;
  int vl_lastPointXMax = 0;
  bool vl_previousHasEnd = false;

* */