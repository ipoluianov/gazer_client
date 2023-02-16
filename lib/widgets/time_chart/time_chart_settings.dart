import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/tools/color_by_index.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/chart_groups/chart_group_form/chart_group_data_items.dart';
import 'package:gazer_client/forms/maps/map_form/main/map_item.dart';
import 'package:gazer_client/widgets/time_chart/time_chart.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_horizontal_scale.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_prop_container.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_settings_area.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_settings_series.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_vertical_scale.dart';

class TimeChartSettings extends TimeChartPropContainer {
  List<TimeChartSettingsArea> areas;
  TimeChartHorizontalScale horScale = TimeChartHorizontalScale();

  bool selectionIsStarted = false;
  double selectionMin = 0;
  double selectionMax = 0;
  bool selectionIsFinished = false;

  bool selectionMovingIsStarted = false;
  double selectionMovingStartPositionPixels = 0;
  double selectionMovingOriginalMin = 0;
  double selectionMovingOriginalMax = 0;
  bool selectionMovingIsFinished = false;

  bool selectionResizingLeftIsStarted = false;
  double selectionResizingLeftStartPositionPixels = 0;
  bool selectionResizingLeftIsFinished = false;
  bool selectionResizingRightIsStarted = false;
  double selectionResizingRightStartPositionPixels = 0;
  bool selectionResizingRightIsFinished = false;

  bool selectionForZoomIsStarted = false;
  double selectionForZoomMin = 0;
  double selectionForZoomMax = 0;
  bool selectionIsForZoomFinished = false;

  bool movingIsStarted = false;
  double movingStartPositionPixels = 0;
  double movingOriginalDisplayMin = 0;
  double movingOriginalDisplayMax = 0;

  bool scalingIsStarted = false;
  double scalingStartPositionPixels = 0;
  double scalingOriginalDisplayMin = 0;
  double scalingOriginalDisplayMax = 0;

  Offset hoverPos = const Offset(0, 0);

  bool _editing = false;
  void setEditing(bool editing) {
    _editing = editing;
    resetSelection();
  }

  bool editing() {
    return _editing;
  }

  // public properties
  bool showTimeScale = true;
  bool showVerticalScale = true;
  Color backColor = Colors.transparent;

  TimeChartSettings(Connection conn, this.areas) : super(conn);

  bool keyControl = false;
  bool keyAlt = false;
  bool keyShift = false;

  void setKeys(control, alt, shift) {
    keyControl = control;
    keyAlt = alt;
    keyShift = shift;
  }

  void setFixedHorScale(bool fixed) {
    horScale.setFixedHorScale(fixed);
  }

  void resetToDefaultDisplayRange() {
    horScale.resetToDefaultDisplayRange();
  }

  void setDisplayRangeLast(double seconds) {
    int now = DateTime.now().microsecondsSinceEpoch;
    double min = (now - seconds * 1000000);
    double max = now.toDouble();

    if (min < max) {
      min -= (max - min) / 20;
      max += (max - min) / 20;
    }

    horScale.setDefaultDisplayRange(min, max);
  }

  void startSelectingForZoom(double x) {
    selectionForZoomIsStarted = true;
    selectionForZoomMin = horScale.horPixelToValue(x);
    selectionForZoomMax = horScale.horPixelToValue(x);
  }

  void updateSelectingForZoom(double x) {
    selectionForZoomMax = horScale.horPixelToValue(x);
  }

  void finishSelectingForZoom() {
    selectionForZoomIsStarted = false;
    if (selectionForZoomMax < selectionForZoomMin) {
      horScale.setFixedHorScale(false);
    } else {
      horScale.setFixedHorScale(true);
      horScale.setDisplayRange(selectionForZoomMin, selectionForZoomMax);
    }
  }

  void startSelecting(double x) {
    selectionIsStarted = true;
    selectionMin = horScale.horPixelToValue(x);
    selectionMax = horScale.horPixelToValue(x);
  }

  void finishSelecting() {
    selectionIsStarted = false;
  }

  void startMoving(double x) {
    if (keyControl) {
      startSelectingForZoom(x);
      return;
    }

    if (keyShift) {
      startSelecting(x);
      return;
    }

    if (pointIsInsideSelectionResizeLeft(Offset(x, 0))) {
      selectionResizingLeftIsStarted = true;
      selectionResizingLeftStartPositionPixels =
          horScale.horValueToPixel(selectionMin) - x;
      return;
    }

    if (pointIsInsideSelectionResizeRight(Offset(x, 0))) {
      selectionResizingRightIsStarted = true;
      selectionResizingRightStartPositionPixels =
          horScale.horValueToPixel(selectionMax) - x;
      return;
    }

    if (pointIsInsideSelection(Offset(x, 0))) {
      selectionMovingIsStarted = true;
      selectionMovingStartPositionPixels = x;
      selectionMovingOriginalMin = selectionMin;
      selectionMovingOriginalMax = selectionMax;
      return;
    }

    movingIsStarted = true;
    horScale.setFixedHorScale(true);

    movingStartPositionPixels = x;
    movingOriginalDisplayMin = horScale.displayMin;
    movingOriginalDisplayMax = horScale.displayMax;
  }

  void startMovingY(double y) {
    scalingIsStarted = true;
    horScale.setFixedHorScale(true);

    scalingStartPositionPixels = y;
    scalingOriginalDisplayMin = horScale.displayMin;
    scalingOriginalDisplayMax = horScale.displayMax;
  }

  void updateMoving(double x) {
    if (selectionForZoomIsStarted) {
      updateSelectingForZoom(x);
    }
    if (selectionIsStarted) {
      selectionMax = horScale.horPixelToValue(x);

      if (selectionMin > selectionMax) {
        var m = selectionMin;
        selectionMin = selectionMax;
        selectionMax = m;
      }
    }

    if (selectionResizingLeftIsStarted) {
      selectionMin = horScale
          .horPixelToValue(x + selectionResizingLeftStartPositionPixels);
      if (selectionMin > selectionMax - pixelsToTime(1)) {
        selectionMin = selectionMax - pixelsToTime(1);
      }
    }

    if (selectionResizingRightIsStarted) {
      selectionMax = horScale
          .horPixelToValue(x + selectionResizingRightStartPositionPixels);
      if (selectionMax < selectionMin + pixelsToTime(1)) {
        selectionMax = selectionMin + pixelsToTime(1);
      }
    }

    if (selectionMovingIsStarted) {
      double shiftTime = pixelsToTime(x - selectionMovingStartPositionPixels);
      selectionMin = selectionMovingOriginalMin + shiftTime;
      selectionMax = selectionMovingOriginalMax + shiftTime;
    }

    if (movingIsStarted) {
      double shiftTime = pixelsToTime(x - movingStartPositionPixels);
      horScale.setDisplayRange(movingOriginalDisplayMin - shiftTime,
          movingOriginalDisplayMax - shiftTime);
    }
  }

  double pixelsToTime(double pixels) {
    var point1 = horScale.horPixelToValue(1);
    var point2 = horScale.horPixelToValue(2);
    double timePerPixel = point2 - point1;
    return pixels * timePerPixel;
  }

  double timeToPixels(double time) {
    var point1 = horScale.horPixelToValue(1);
    var point2 = horScale.horPixelToValue(2);
    double timePerPixel = point2 - point1;
    if (timePerPixel > 0) {
      return time / timePerPixel;
    }
    return 0;
  }

  void updateMovingY(double y) {
    if (scalingIsStarted) {
      var point1 = horScale.horPixelToValue(1);
      var point2 = horScale.horPixelToValue(2);
      double timePerPixel = point2 - point1;
      double shiftTime = (y - scalingStartPositionPixels) * timePerPixel;
      shiftTime *= 2;
      horScale.setDisplayRange(scalingOriginalDisplayMin - shiftTime,
          scalingOriginalDisplayMax + shiftTime);
    }
  }

  void finishMoving() {
    if (selectionForZoomIsStarted) {
      finishSelectingForZoom();
    }
    if (selectionIsStarted) {
      finishSelecting();
    }
    if (selectionMovingIsStarted) {
      selectionMovingIsStarted = false;
    }

    if (selectionResizingLeftIsStarted) {
      selectionResizingLeftIsStarted = false;
    }
    if (selectionResizingRightIsStarted) {
      selectionResizingRightIsStarted = false;
    }
    movingIsStarted = false;
  }

  void finishMovingY() {
    scalingIsStarted = false;
  }

  void removeSelected() {
    int areaIndexToRemove = -1;
    int seriesIndexToRemove = -1;

    for (int areaIndex = 0; areaIndex < areas.length; areaIndex++) {
      if (areas[areaIndex].selected) {
        areaIndexToRemove = areaIndex;
        break;
      }
      for (int serIndex = 0;
          serIndex < areas[areaIndex].series.length;
          serIndex++) {
        if (areas[areaIndex].series[serIndex].selected) {
          areaIndexToRemove = areaIndex;
          seriesIndexToRemove = serIndex;
          break;
        }
      }
    }

    if (areaIndexToRemove > -1) {
      if (seriesIndexToRemove > -1) {
        areas[areaIndexToRemove].series.removeAt(seriesIndexToRemove);
      } else {
        areas.removeAt(areaIndexToRemove);
      }
    }
  }

  void doubleTap() {
    double y = 0;
    scalingIsStarted = true;
    horScale.setFixedHorScale(true);

    scalingStartPositionPixels = y;
    scalingOriginalDisplayMin = horScale.displayMin;
    scalingOriginalDisplayMax = horScale.displayMax;

    y = -300;

    var point1 = horScale.horPixelToValue(1);
    var point2 = horScale.horPixelToValue(2);
    double timePerPixel = point2 - point1;
    double shiftTime = (y - scalingStartPositionPixels) * timePerPixel;
    shiftTime *= 2;
    horScale.setDisplayRange(scalingOriginalDisplayMin - shiftTime,
        scalingOriginalDisplayMax + shiftTime);
    scalingIsStarted = false;
  }

  TimeChartPropContainer selectedObject() {
    for (int areaIndex = 0; areaIndex < areas.length; areaIndex++) {
      if (areas[areaIndex].selected) {
        return areas[areaIndex];
      }
      for (int serIndex = 0;
          serIndex < areas[areaIndex].series.length;
          serIndex++) {
        if (areas[areaIndex].series[serIndex].selected) {
          return areas[areaIndex].series[serIndex];
        }
      }
    }
    return this;
  }

  void resetChartSelection() {
    selectionMin = 0;
    selectionMax = 0;
  }

  void resetSelection() {
    for (int areaIndex = 0; areaIndex < areas.length; areaIndex++) {
      areas[areaIndex].selected = false;
      for (int serIndex = 0;
          serIndex < areas[areaIndex].series.length;
          serIndex++) {
        areas[areaIndex].series[serIndex].selected = false;
      }
    }
  }

  bool pointIsInsideSelection(Offset offset) {
    var val = horScale.horPixelToValue(offset.dx);
    if (val > selectionMin && val < selectionMax) {
      return true;
    }
    return false;
  }

  bool pointIsInsideSelectionAndResizeSections(Offset offset) {
    var val = horScale.horPixelToValue(offset.dx);
    if (val > selectionMin - pixelsToTime(selectionResizingPadding) &&
        val < selectionMax + pixelsToTime(selectionResizingPadding)) {
      return true;
    }
    return false;
  }

  double selectionResizingPadding = 30;

  bool pointIsInsideSelectionResizeLeft(Offset offset) {
    if (selectionMin == selectionMax) {
      return false;
    }
    double borderOfSelection = horScale.horValueToPixel(selectionMin);
    if (offset.dx > borderOfSelection - selectionResizingPadding &&
        offset.dx < borderOfSelection) {
      return true;
    }
    return false;
  }

  bool pointIsInsideSelectionResizeRight(Offset offset) {
    if (selectionMin == selectionMax) {
      return false;
    }
    double borderOfSelection = horScale.horValueToPixel(selectionMax);
    if (offset.dx > borderOfSelection &&
        offset.dx < borderOfSelection + selectionResizingPadding) {
      return true;
    }
    return false;
  }

  void onHover(Offset offset) {
    hoverPos = offset;
  }

  void onEnter(PointerEnterEvent ev) {
    //hoverPos = offset;
  }

  void onLeave(PointerExitEvent ev) {
    hoverPos = const Offset(0, 0);
  }

  void onTapDown(Offset offset) {
    //print("down .. ${offset}");
    if (_editing) {
      int areaIndexAtOffset = findAreaIndexByXY(offset.dx, offset.dy);
      if (areaIndexAtOffset >= 0 && areaIndexAtOffset < areas.length) {
        var area = areas[areaIndexAtOffset];
        double y = offset.dy - area.yOffset;
        if (offset.dx < btnWidth) {
          int index = y ~/ btnHeight;
          if (index >= 0 && index < (area.series.length + 1)) {
            resetSelection();
            if (index > 0) {
              var serIndex = index - 1;
              area.series[serIndex].selected = true;
            } else {
              area.selected = true;
            }
          } else {
            resetSelection();
          }
        } else {
          resetSelection();
        }
      }
    }
    if (!pointIsInsideSelectionAndResizeSections(offset)) {
      resetChartSelection();
    }
  }

  int findAreaIndexByXY(double x, double y) {
    for (int areaIndex = 0; areaIndex < areas.length; areaIndex++) {
      double topOfArea = areas[areaIndex].yOffset;
      double bottomOfArea = areas[areaIndex].yOffset + areas[areaIndex].height;
      if (y > topOfArea && y < bottomOfArea) {
        return areaIndex;
      }
    }
    return -1;
  }

  void scroll(double d) {
    double y = 0;
    scalingIsStarted = true;
    horScale.setFixedHorScale(true);

    scalingStartPositionPixels = y;
    scalingOriginalDisplayMin = horScale.displayMin;
    scalingOriginalDisplayMax = horScale.displayMax;

    y = d;

    var point1 = horScale.horPixelToValue(1);
    var point2 = horScale.horPixelToValue(2);
    double timePerPixel = point2 - point1;
    double shiftTime = (y - scalingStartPositionPixels) * timePerPixel;
    shiftTime *= 2;
    horScale.setDisplayRange(scalingOriginalDisplayMin - shiftTime,
        scalingOriginalDisplayMax + shiftTime);
    scalingIsStarted = false;
  }

  void draw(Canvas canvas, Size size) {
    double verticalScalesWidth = 0;
    double areaHeight = (size.height - horScale.height) / areas.length;

    canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..style = PaintingStyle.fill
          ..color = backColor);

    for (int areaIndex = 0; areaIndex < areas.length; areaIndex++) {
      areas[areaIndex].calc(this, 0, areaHeight * areaIndex.toDouble(),
          size.width, areaHeight, verticalScalesWidth);
    }

    horScale.calc(verticalScalesWidth, areaHeight * areas.length,
        size.width - verticalScalesWidth, showTimeScale ? 30 : 0);

    for (int areaIndex = 0; areaIndex < areas.length; areaIndex++) {
      var area = areas[areaIndex];
      area.draw(canvas, size, horScale, this, areaIndex == areas.length - 1);

      if (_editing) {
        canvas.save();
        canvas
            .clipRect(Rect.fromLTWH(0, area.yOffset, size.width, area.height));
        canvas.translate(0, area.yOffset);
        if (area.selected) {
          drawEditButton(
              canvas, 0, "Area #${areaIndex + 1}", Colors.white, true);
        } else {
          drawEditButton(
              canvas, 0, "Area #${areaIndex + 1}", Colors.white, false);
        }
        int index = 1;
        for (var s in area.series) {
          if (s.selected) {
            drawEditButton(canvas, index, s.getDisplayName(),
                s.getColor("stroke_color"), true);
          } else {
            drawEditButton(canvas, index, s.getDisplayName(),
                s.getColor("stroke_color"), false);
          }
          index++;
        }

        canvas.restore();
      } else {
        if (area.getBool("show_legend")) {
          int index = 0;
          canvas.save();
          canvas.clipRect(
              Rect.fromLTWH(0, area.yOffset, size.width, area.height));
          canvas.translate(0, area.yOffset);
          for (var s in area.series) {
            if (s.selected) {
              drawLegendItem(
                  canvas,
                  index,
                  s.getDisplayName(),
                  s.getColor("stroke_color"),
                  area.series.length,
                  area.unitedVerticalScale() || area.series.length == 1);
            } else {
              drawLegendItem(
                  canvas,
                  index,
                  s.getDisplayName(),
                  s.getColor("stroke_color"),
                  area.series.length,
                  area.unitedVerticalScale() || area.series.length == 1);
            }
            index++;
          }
          canvas.restore();
        }
      }
    }

    horScale.draw(canvas, size);

    if (selectionForZoomIsStarted) {
      canvas.drawRect(
          Rect.fromLTRB(horScale.horValueToPixel(selectionForZoomMin), 0,
              horScale.horValueToPixel(selectionForZoomMax), size.height),
          Paint()
            ..style = PaintingStyle.fill
            ..color = Colors.white30
            ..strokeWidth = 1);
    }

    if (selectionMin != selectionMax) {
      canvas.save();
      canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawRect(
          Rect.fromLTRB(horScale.horValueToPixel(selectionMin), 0,
              horScale.horValueToPixel(selectionMax), size.height),
          Paint()
            ..style = PaintingStyle.fill
            ..color = Colors.yellow.withOpacity(0.1)
            ..strokeWidth = 1);

      Duration duration =
          DateTime.fromMicrosecondsSinceEpoch(selectionMax.toInt()).difference(
              DateTime.fromMicrosecondsSinceEpoch(selectionMin.toInt()));

      String durationStringCommon = duration.toString();
      String durationStringSeconds = "In Seconds: ${duration.inSeconds}";
      String durationStringMinutes =
          "In Minutes: ${(duration.inSeconds / 60).toStringAsFixed(1)}";
      String durationStringHours =
          "In Hours: ${(duration.inSeconds / 3600).toStringAsFixed(2)}";

      drawSelectionResizeArea(
          canvas,
          horScale.horValueToPixel(selectionMin) - selectionResizingPadding,
          size.height,
          selectionResizingPadding,
          true);
      drawSelectionResizeArea(canvas, horScale.horValueToPixel(selectionMax),
          size.height, selectionResizingPadding, false);

      double leftPadding = 10;
      drawText(
          canvas,
          leftPadding + horScale.horValueToPixel(selectionMin),
          0,
          timeToPixels(selectionMax - selectionMin),
          size.height,
          durationStringCommon,
          14,
          Colors.yellow,
          TextAlign.left,
          false);
      drawText(
          canvas,
          leftPadding + horScale.horValueToPixel(selectionMin),
          20,
          timeToPixels(selectionMax - selectionMin),
          size.height,
          durationStringSeconds,
          14,
          Colors.yellow,
          TextAlign.left,
          false);
      drawText(
          canvas,
          leftPadding + horScale.horValueToPixel(selectionMin),
          40,
          timeToPixels(selectionMax - selectionMin),
          size.height,
          durationStringMinutes,
          14,
          Colors.yellow,
          TextAlign.left,
          false);
      drawText(
          canvas,
          leftPadding + horScale.horValueToPixel(selectionMin),
          60,
          timeToPixels(selectionMax - selectionMin),
          size.height,
          durationStringHours,
          14,
          Colors.yellow,
          TextAlign.left,
          false);

      canvas.restore();
    }

    if (hoverPos.dy > 0 &&
        hoverPos.dx > 0 &&
        !selectionMovingIsStarted &&
        !selectionForZoomIsStarted &&
        !movingIsStarted) {
      canvas.drawLine(
          Offset(0, hoverPos.dy),
          Offset(size.width, hoverPos.dy),
          Paint()
            ..color = Colors.white38
            ..strokeWidth = 0.3);
      canvas.drawLine(
          Offset(hoverPos.dx, 0),
          Offset(hoverPos.dx, size.height),
          Paint()
            ..color = Colors.white38
            ..strokeWidth = 0.3);
    }

    canvas.drawRect(
        const Offset(0, 0) & Size(size.width, size.height),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = DesignColors.fore1()
          ..strokeWidth = 1);
  }

  void drawSelectionResizeArea(
      Canvas canvas, double x, double height, double width, bool left) {
    double step = 20;
    double lineWidth = 5;
    for (double y = -step; y < height; y += step) {
      Path p = Path();
      p.addPolygon([
        Offset(x, y),
        Offset(x + width, y + width),
        Offset(x + width, y + width + lineWidth),
        Offset(x, y + lineWidth),
      ], true);

      canvas.drawPath(
          p,
          Paint()
            ..color = Colors.yellow.withOpacity(0.1)
            ..style = PaintingStyle.fill);
    }

    canvas.drawRect(
        Rect.fromLTWH(x, 0, width, height),
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.yellow.withOpacity(0.05)
          ..strokeWidth = 1);

    {
      Path p = Path();
      if (left) {
        p.addPolygon([
          Offset(x, 0),
          Offset(x + width, width),
          Offset(x + width, height - width),
          Offset(x, height),
        ], false);
      } else {
        p.addPolygon([
          Offset(x + width, 0),
          Offset(x + width - width, width),
          Offset(x + width - width, height - width),
          Offset(x + width, height),
        ], false);
      }

      canvas.drawPath(
          p,
          Paint()
            ..color = Colors.yellow
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke);
    }
  }

  double btnHeight = 40;
  double btnWidth = 300;

  void drawEditButton(
      Canvas canvas, int index, String text, Color color, bool active) {
    double borderWidth = 2;
    double bottomPadding = 1;
    canvas.drawRect(
        Rect.fromLTWH(0, index * btnHeight, btnWidth, btnHeight),
        Paint()
          ..color = active ? Colors.black : Colors.black.withOpacity(0.75)
          ..style = PaintingStyle.fill);
    if (active) {
      double indWidth = 20;
      double indHeight = 20;
      double indY = btnHeight * index;

      double indRightMargin = 6;
      var indRect = Rect.fromLTWH(btnWidth - indWidth - indRightMargin,
          indY + btnHeight / 2 - indHeight / 2, indWidth, indHeight);
      Path p = Path();
      p.addPolygon([
        Offset(indRect.left, indRect.top),
        Offset(indRect.right, indRect.top + indRect.height / 2),
        Offset(indRect.left, indRect.bottom),
      ], true);

      canvas.drawPath(
          p,
          Paint()
            ..color = color
            ..style = PaintingStyle.fill
            ..strokeWidth = borderWidth);
    }
    canvas.drawLine(
        Offset(
            0, btnHeight * index + btnHeight - borderWidth / 2 - bottomPadding),
        Offset(btnWidth,
            btnHeight * index + btnHeight - borderWidth / 2 - bottomPadding),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth);
    drawText(canvas, 5, index * btnHeight, btnWidth - 10, btnHeight,
        "select [" + text + "]", 14, color, TextAlign.left, true);
  }

  double legendItemWidth = 250;
  double legendItemHeight = 22;
  double legendItemXOffset = 0;
  double legendItemYOffset = 0;

  void drawLegendItem(Canvas canvas, int index, String text, Color color,
      int totalCount, bool oneVScale) {
    //double borderWidth = 0;
    double bottomPadding = 0;
    double fullWidth = legendItemWidth +
        ((totalCount - index - 1) *
            TimeChartVerticalScale.defaultVerticalScaleWidthInline);

    double posOffset =
        index * TimeChartVerticalScale.defaultVerticalScaleWidthInline;
    if (oneVScale) {
      posOffset = TimeChartVerticalScale.defaultVerticalScaleWidthInline;
      fullWidth = legendItemWidth;
    }

    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(
                legendItemXOffset + posOffset,
                index * legendItemHeight + legendItemYOffset,
                fullWidth,
                legendItemHeight - bottomPadding),
            const Radius.circular(0)),
        Paint()
          ..color = color.withOpacity(0.3)
          ..style = PaintingStyle.fill);
    /*canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(legendItemXOffset, index * legendItemHeight + legendItemYOffset, legendItemWidth, legendItemHeight - bottomPadding), const Radius.circular(5)),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke);*/

    drawText(
        canvas,
        legendItemXOffset + 5 + posOffset,
        index * legendItemHeight + legendItemYOffset,
        fullWidth - 10,
        legendItemHeight - bottomPadding,
        text,
        14,
        color,
        TextAlign.right,
        true);
  }

  void drawText(
      Canvas canvas,
      double x,
      double y,
      double width,
      double height,
      String text,
      double size,
      Color color,
      TextAlign align,
      bool verticalCenter) {
    var textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
      ),
    );
    final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: align,
        ellipsis: "   ...");
    textPainter.layout(
      minWidth: width,
      maxWidth: width,
    );
    //textPainter.paint(canvas, Offset(x, y));
    if (verticalCenter) {
      textPainter.paint(
          canvas, Offset(x, y + (height / 2) - (textPainter.height / 2)));
    } else {
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {};
    for (var propKey in props.keys) {
      result[propKey] = props[propKey];
    }

    List<Map<String, dynamic>> areasToSave = [];
    for (var area in areas) {
      var chRes = area.toJson();
      areasToSave.add(chRes);
    }
    result["areas"] = areasToSave;

    return result;
  }

  factory TimeChartSettings.fromJson(
      Connection conn, Map<String, dynamic> json) {
    print("loading settings ${json['areas']}");
    var settings = TimeChartSettings(
        conn,
        json['areas']
            .map<TimeChartSettingsArea>(
                (model) => TimeChartSettingsArea.fromJson(conn, model))
            .toList());
    for (var propKey in json.keys) {
      if (propKey == "areas") {
        continue;
      }
      settings.props[propKey] = json[propKey];
    }
    return settings;
  }

  @override
  List<MapItemPropPage> propList() {
    //MapItemPropPage pageMain = MapItemPropPage("Chart Group", const Icon(Icons.domain), []);
    MapItemPropPage pageDataItems =
        MapItemPropPage("Data Items", const Icon(Icons.data_usage), []);
    pageDataItems.widget = ChartGroupDataItems(connection);
    {
      List<MapItemPropItem> props = [];
      //props.add(MapItemPropItem("", "update_period", "Data Source", "data_source", ""));
      //pageMain.groups.add(MapItemPropGroup("Data Source", true, props));
    }
    return [pageDataItems];
  }

  void addSeries(String dataItemName) {
    int areaIndex = -1;
    for (int ai = 0; ai < areas.length; ai++) {
      var a = areas[ai];
      if (a.selected) {
        areaIndex = ai;
        break;
      }
      for (int si = 0; si < a.series.length; si++) {
        var s = a.series[si];
        if (s.selected) {
          areaIndex = ai;
          break;
        }
      }
      if (areaIndex > -1) {
        break;
      }
    }

    if (areaIndex >= 0) {
      areas[areaIndex].series.add(TimeChartSettingsSeries(connection,
          dataItemName, [], colorByIndex(areas[areaIndex].series.length)));
    } else {
      areas.add(TimeChartSettingsArea(connection, <TimeChartSettingsSeries>[
        TimeChartSettingsSeries(connection, dataItemName, [], colorByIndex(0))
      ]));
    }
  }

  MouseCursor mouseCursor() {
    if (_editing) {
      bool overButton = false;
      int areaIndexAtOffset = findAreaIndexByXY(hoverPos.dx, hoverPos.dy);
      if (areaIndexAtOffset >= 0 && areaIndexAtOffset < areas.length) {
        var area = areas[areaIndexAtOffset];
        double y = hoverPos.dy - area.yOffset;
        if (hoverPos.dx < btnWidth) {
          int index = y ~/ btnHeight;
          if (index >= 0 && index < (area.series.length + 1)) {
            overButton = true;
          }
        }
      }
      if (overButton) {
        return SystemMouseCursors.click;
      }
    }

    return SystemMouseCursors.basic;
  }
}
