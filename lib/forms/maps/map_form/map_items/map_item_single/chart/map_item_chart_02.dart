import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/protocol/dataitem/data_item_history_chart.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import '../../../../utils/draw_text.dart';
import '../../../../utils/material_icons.dart';
import '../../../main/map_item.dart';
import '../map_item_single.dart';

class MapItemChart02 extends MapItemSingle {
  static const String sType = "chart.02";
  static const String sName = "Chart.02";
  @override
  String type() {
    return sType;
  }

  late String lastDataSource = "";

  MapItemChart02(Connection connection) : super(connection) {
    /*settings = TimeChartSettings(connection, []);
    settings.areas.add(TimeChartSettingsArea(
        connection, <TimeChartSettingsSeries>[
      TimeChartSettingsSeries(
          connection, get("data_source"), [], Colors.blueAccent)
    ]));*/
  }

  List<DataItemHistoryChartItemValueResponse> data = [];

  DateTime lastUpdateDataDT = DateTime(0);

  @override
  void tick() {
    double diff = 0;

    diff = currentValueTarget - currentValueLast;
    currentValueLast += diff / 8;

    if (minValueTarget > -double.maxFinite &&
        minValueTarget < double.maxFinite) {
      diff = minValueTarget - minValue;
      minValue += diff / 8;
    } else {
      minValueTarget = 0;
    }

    if (maxValueTarget > -double.maxFinite &&
        maxValueTarget < double.maxFinite) {
      diff = maxValueTarget - maxValue;
      maxValue += diff / 8;
    } else {
      maxValueTarget = 0;
    }

    if (DateTime.now().difference(lastUpdateDataDT) <
        const Duration(milliseconds: 500)) {
      return;
    }

    lastUpdateDataDT = DateTime.now();
  }

  Color chartRegularColor = const Color.fromARGB(255, 130, 133, 139);
  Color chartErrorColor = const Color.fromARGB(255, 255, 0, 0);
  Color chartColor = const Color.fromARGB(255, 130, 133, 139);

  Color candleColorUp = Colors.blueAccent;
  Color candleColorDown = Colors.blueAccent;

  double currentValueTarget = 0;
  double currentValueLast = 0;

  double minValueTarget = 0;
  double minValue = 0;

  double maxValueTarget = 0;
  double maxValue = 0;

  bool isDemo = false;

  TextAppearance txtProps =
      TextAppearance("", 1, 100, Colors.black, TextAlign.center);

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    DateTime now = DateTime.now();
    bool currentValueTargetExists = false;
    try {
      currentValueTarget = double.parse(dataSourceValue().value);
      currentValueTargetExists = true;
    } catch (e) {
      // no action
    }

    String valueType = get("value_type");
    String kind = get("kind");
    bool showLegend = getBool("show_legend");
    txtProps = getTextAppearance(this);

    if (isDemo) {
      showLegend = false;
    }

    chartRegularColor = getColor("chart_color");
    chartErrorColor = getColor("chart_error_color");

    chartColor = chartRegularColor;

    if (kind == "CANDLES") {
      candleColorUp = getColor("candle_up_color");
      candleColorDown = getColor("candle_down_color");
    }

    double padding = txtProps.fontSize + txtProps.fontSize * 0.2;
    if (!showLegend) {
      padding = z(1);
    }

    bool showCurrentValue = showLegend;

    double x = getDoubleZ("x") + padding;
    double y = getDoubleZ("y") + padding;
    double width = getDoubleZ("w") - padding * 2;
    double height = getDoubleZ("h") - padding * 2;

    double lastSeconds = getDouble("span");

    if (lastSeconds < 5) {
      lastSeconds = 5;
    }

    if (lastSeconds > 1800) {
      lastSeconds = 1800;
    }

    int begin = now.microsecondsSinceEpoch - lastSeconds.toInt() * 1000 * 1000;
    int end = now.microsecondsSinceEpoch;
    int timeSlot = getDouble("slot").toInt() * 1000 * 1000;

    if (isDemo) {
      begin = 0;
      end = 10;
      timeSlot = 1;
    }

    int minTimeSlot = 1 * 1000 * 1000; // 1 sec
    int expectedCountOfItem =
        ((end.toDouble() - begin.toDouble()) / minTimeSlot.toDouble()).round();
    while (expectedCountOfItem > width / 10) {
      minTimeSlot += 1 * 1000 * 1000;
      expectedCountOfItem =
          ((end.toDouble() - begin.toDouble()) / minTimeSlot.toDouble())
              .round();
    }
    int maxTimeSlot = (lastSeconds * 1000 * 1000) ~/ 4;

    if (timeSlot < minTimeSlot) {
      timeSlot = minTimeSlot;
    }
    if (timeSlot > maxTimeSlot) {
      timeSlot = maxTimeSlot;
    }

    if (!isDemo) {
      data = Repository()
          .history
          .getNode(connection)
          .getHistory(getDataSource(), begin, end, timeSlot);
    }

    expectedCountOfItem =
        ((end.toDouble() - begin.toDouble()) / timeSlot.toDouble()).round();

    if (isDemo) {
      expectedCountOfItem = 10;
    }

    drawPre(canvas, size);

    double minValueTargetTemp = double.maxFinite;
    double maxValueTargetTemp = -double.maxFinite;

    for (int i = 0; i < data.length; i++) {
      if (data[i].minValue < minValueTargetTemp) {
        minValueTargetTemp = data[i].minValue;
      }
      if (data[i].maxValue > maxValueTargetTemp) {
        maxValueTargetTemp = data[i].maxValue;
      }
    }

    if (showCurrentValue) {
      if (currentValueTargetExists) {
        if (currentValueTarget < minValueTargetTemp) {
          minValueTargetTemp = currentValueTarget;
        }
        if (currentValueTarget > maxValueTargetTemp) {
          maxValueTargetTemp = currentValueTarget;
        }
      }
    }

    minValueTarget = minValueTargetTemp;
    maxValueTarget = maxValueTargetTemp;

    if (maxValueTarget < minValueTarget) {
      minValueTarget = 0;
      maxValueTarget = 1;
    }

    if (minValueTarget == maxValueTarget) {
      minValueTarget = minValueTarget - 1;
      maxValueTarget = maxValueTarget + 1;
    }

    if (getBool("show_zero")) {
      if (minValueTarget > 0) {
        minValueTarget = 0;
      }
    }

    if (isDemo) {
      minValue = 0;
      maxValue = 100;
    }

    double valuesRange = maxValue - minValue;

    double pixelsPerValueX = width / expectedCountOfItem;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(x, y - 1, width, height + 2));

    double barWidth = getDouble("bar_width");
    if (barWidth < 1) {
      barWidth = 1;
    }
    if (barWidth > 100) {
      barWidth = 100;
    }
    barWidth = barWidth / 100.0;

    for (int i = 0; i < data.length; i++) {
      var item = data[i];

      chartColor = chartRegularColor;
      if (item.hasBad) {
        chartColor = chartErrorColor;
      }

      // Calc minMaxRect
      Rect rectMinMax = Rect.zero;
      if (valueType == "MINMAX") {
        double xRange = (end - begin).toDouble();
        double x01 = (item.datetimeFirst - begin) / xRange;
        double left = x + x01 * width;
        double right = left + pixelsPerValueX * barWidth;
        double value1_01 = (item.maxValue - minValue) / valuesRange;
        double value2_01 = (item.minValue - minValue) / valuesRange;
        double top = y + height - value1_01 * height;
        double bottom = y + height - value2_01 * height;
        rectMinMax = Rect.fromLTRB(left, top, right, bottom);
      }

      Rect rectFirstLast = Rect.zero;
      double yLineMinMax1 = 0;
      double yLineMinMax2 = 0;
      if (kind == "CANDLES") {
        double xRange = (end - begin).toDouble();
        double x01 = (item.datetimeFirst - begin) / xRange;
        double left = x + x01 * width;
        double right = left + pixelsPerValueX * barWidth;
        double value1_01 = (item.firstValue - minValue) / valuesRange;
        double value2_01 = (item.lastValue - minValue) / valuesRange;
        double lineY1 = (item.maxValue - minValue) / valuesRange;
        yLineMinMax1 = y + height - lineY1 * height;
        double lineY2 = (item.minValue - minValue) / valuesRange;
        yLineMinMax2 = y + height - lineY2 * height;
        double top = y + height - value1_01 * height;
        double bottom = y + height - value2_01 * height;
        rectFirstLast = Rect.fromLTRB(left, top, right, bottom);
      }

      Rect rectMin = Rect.zero;
      if (valueType == "MIN") {
        double xRange = (end - begin).toDouble();
        double x01 = (item.datetimeFirst - begin) / xRange;
        double left = x + x01 * width;
        double right = left + pixelsPerValueX * barWidth;
        double value01 = (item.minValue - minValue) / valuesRange;
        double top = y + height - value01 * height;
        double bottom = y + height;
        rectMin = Rect.fromLTRB(left, top, right, bottom);
      }

      Rect rectMax = Rect.zero;
      if (valueType == "MAX") {
        double xRange = (end - begin).toDouble();
        double x01 = (item.datetimeFirst - begin) / xRange;
        double left = x + x01 * width;
        double right = left + pixelsPerValueX * barWidth;
        double value01 = (item.maxValue - minValue) / valuesRange;
        double top = y + height - value01 * height;
        double bottom = y + height;
        rectMax = Rect.fromLTRB(left, top, right, bottom);
      }

      Rect rectAvg = Rect.zero;
      if (valueType == "AVG") {
        double xRange = (end - begin).toDouble();
        double x01 = (item.datetimeFirst - begin) / xRange;
        double left = x + x01 * width;
        double right = left + pixelsPerValueX * barWidth;
        double value01 = (item.avgValue - minValue) / valuesRange;
        double top = y + height - value01 * height;
        double bottom = y + height;
        rectAvg = Rect.fromLTRB(left, top, right, bottom);
      }

      if (kind == "CANDLES") {
        drawCandle(canvas, rectFirstLast, yLineMinMax1, yLineMinMax2,
            item.firstValue <= item.lastValue);
      }

      if (kind == "BARS") {
        if (valueType == "MIN") {
          drawBar(canvas, rectMin);
        }
        if (valueType == "MAX") {
          drawBar(canvas, rectMax);
        }
        if (valueType == "AVG") {
          drawBar(canvas, rectAvg);
        }
        if (valueType == "MINMAX") {
          drawBar(canvas, rectMinMax);
        }
      }

      if (kind == "BONES") {
        if (valueType == "MIN") {
          drawBone(canvas, rectMin);
        }
        if (valueType == "MAX") {
          drawBone(canvas, rectMax);
        }
        if (valueType == "AVG") {
          drawBone(canvas, rectAvg);
        }
        if (valueType == "MINMAX") {
          drawBone(canvas, rectMinMax);
        }
      }
    }

    chartColor = chartRegularColor;

    canvas.restore();

    if (showLegend) {
      drawText(
        canvas,
        getDoubleZ("x") + padding * 0.1,
        getDoubleZ("y"),
        getDoubleZ("w"),
        padding,
        maxValueTarget.toString(),
        txtProps.fontSize,
        txtProps.textColor,
        TextVAlign.middle,
        TextAlign.left,
        txtProps.fontFamily,
        txtProps.fontWeight,
      );

      drawText(
        canvas,
        getDoubleZ("x") + padding * 0.1,
        getDoubleZ("y") + getDoubleZ("h") - padding,
        getDoubleZ("w"),
        padding,
        minValueTarget.toString(),
        txtProps.fontSize,
        txtProps.textColor,
        TextVAlign.middle,
        TextAlign.left,
        txtProps.fontFamily,
        txtProps.fontWeight,
      );

      drawText(
        canvas,
        x,
        y - padding,
        width + padding - padding * 0.1,
        padding,
        dataSourceValue().displayName,
        txtProps.fontSize,
        txtProps.textColor,
        TextVAlign.middle,
        TextAlign.right,
        txtProps.fontFamily,
        txtProps.fontWeight,
      );

      drawText(
        canvas,
        x,
        y + height,
        width + padding - padding * 0.1,
        padding,
        "${dataSourceValue().value} ${dataSourceValue().uom}",
        txtProps.fontSize,
        dataSourceValue().uom == "error" ? chartErrorColor : txtProps.textColor,
        TextVAlign.middle,
        TextAlign.right,
        txtProps.fontFamily,
        txtProps.fontWeight,
      );

      try {
        currentValueTarget = double.parse(dataSourceValue().value);
        double value01 = (currentValueLast - minValue) / valuesRange;
        double top = y + height - value01 * height - padding;
        double bottom = top + padding * 2;
        Rect rect = Rect.fromLTRB(x + width, top, x + width + padding, bottom);
        IconData icon = MaterialIconsLib().getIconByName(get("icon_name"));
        drawText(
          canvas,
          rect.left,
          top,
          rect.width,
          rect.height,
          String.fromCharCode(icon.codePoint),
          txtProps.fontSize,
          txtProps.textColor,
          TextVAlign.middle,
          TextAlign.left,
          icon.fontFamily,
          400,
        );
      } catch (e) {
        // no action
      }

      drawScaleLeft(canvas, Rect.fromLTRB(x - padding, y, x, y + height));
      drawScaleRight(
          canvas, Rect.fromLTRB(x + width, y, x + width + padding, y + height));
    }

    if (!hasDataSource()) {
      drawText(
        canvas,
        getDoubleZ("x"),
        getDoubleZ("y"),
        getDoubleZ("w"),
        getDoubleZ("h"),
        "no data source",
        32,
        txtProps.textColor,
        TextVAlign.middle,
        TextAlign.center,
        "Roboto",
        400,
      );
    }

    drawPost(canvas, size);
  }

  void drawBar(Canvas canvas, Rect rect) {
    if (rect.height < 1) {
      rect = Rect.fromLTRB(rect.left, rect.top - 2, rect.right, rect.bottom);
    }
    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.fill
        ..color = getColor("chart_color"),
    );
  }

  void drawBone(Canvas canvas, Rect rect) {
    if (rect.height < 1) {
      rect = Rect.fromLTRB(rect.left, rect.top - 2, rect.right, rect.bottom);
    }
    canvas.drawLine(
      Offset(rect.left + rect.width / 2, rect.top),
      Offset(rect.left + rect.width / 2, rect.bottom),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = chartColor
        ..strokeWidth = z(1),
    );

    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.top),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = chartColor
        ..strokeWidth = z(1),
    );

    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.right, rect.bottom),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = chartColor
        ..strokeWidth = z(1),
    );
  }

  void drawCandle(
      Canvas canvas, Rect rect, double y1, double y2, bool upwards) {
    if (rect.height < 1) {
      rect = Rect.fromLTRB(rect.left, rect.top - 2, rect.right, rect.bottom);
    }

    Color candleColor = upwards ? candleColorUp : candleColorDown;

    canvas.drawRect(
      rect,
      Paint()
        ..style = PaintingStyle.fill
        ..color = candleColor
        ..strokeWidth = z(1),
    );

    canvas.save();
    canvas.clipRect(rect, clipOp: ClipOp.difference);

    canvas.drawLine(
      Offset(rect.left + rect.width / 2, y1),
      Offset(rect.left + rect.width / 2, y2),
      Paint()
        ..color = candleColor
        ..strokeWidth = z(1),
    );
    canvas.restore();
  }

  void drawScaleLeft(Canvas canvas, Rect rect) {
    canvas.drawLine(
      Offset(rect.left + rect.width / 4, rect.top),
      Offset(rect.left + rect.width / 4, rect.bottom),
      Paint()
        ..color = txtProps.textColor
        ..strokeWidth = z(1),
    );
    double step = rect.height / 5;
    for (double y = rect.top; y < rect.bottom + step / 2; y += step) {
      canvas.drawLine(
        Offset(rect.left + rect.width / 4, y),
        Offset(rect.left + rect.width / 4 + rect.width / 4, y),
        Paint()
          ..color = txtProps.textColor
          ..strokeWidth = z(1),
      );
    }

    step = rect.height / 20;
    for (double y = rect.top; y < rect.bottom + step / 2; y += step) {
      canvas.drawLine(
        Offset(rect.left + rect.width / 4, y),
        Offset(rect.left + rect.width / 4 + rect.width / 8, y),
        Paint()
          ..color = txtProps.textColor
          ..strokeWidth = z(0.5),
      );
    }
  }

  void drawScaleRight(Canvas canvas, Rect rect) {
    canvas.drawLine(
      Offset(rect.right - rect.width / 4, rect.top),
      Offset(rect.right - rect.width / 4, rect.bottom),
      Paint()
        ..color = txtProps.textColor
        ..strokeWidth = z(1),
    );
    double step = rect.height / 5;
    for (double y = rect.top; y < rect.bottom + step / 2; y += step) {
      canvas.drawLine(
        Offset(rect.right - rect.width / 4, y),
        Offset(rect.right - rect.width / 4 - rect.width / 5, y),
        Paint()
          ..color = txtProps.textColor
          ..strokeWidth = z(1),
      );
    }

    step = rect.height / 20;
    for (double y = rect.top; y < rect.bottom + step / 2; y += step) {
      canvas.drawLine(
        Offset(rect.right - rect.width / 4, y),
        Offset(rect.right - rect.width / 4 - rect.width / 8, y),
        Paint()
          ..color = txtProps.textColor
          ..strokeWidth = z(0.5),
      );
    }
  }

  @override
  void drawDemo(Canvas canvas, Size size) {
    isDemo = true;
    set("kind", "BARS");
    data = [];
    int index = 0;
    for (double i = 0; i < 6.28; i += 0.5) {
      double v = sin(i) * 40 + 40;
      data.add(DataItemHistoryChartItemValueResponse(
          index, index, v, v, v, v, v, v, 1, [0], true, false, ""));
      index++;
    }
    draw(canvas, size, []);
  }

  @override
  void setDefaultsForItem() {}

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    groups.addAll(super.propGroupsOfItem());
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "span", "Span, sec", "double", "60"));
      props.add(MapItemPropItem("", "slot", "Slot, sec", "double", "1"));
      props.add(
          MapItemPropItem("", "bar_width", "Bar Width, %", "double", "50"));
      props.add(MapItemPropItem(
          "", "value_type", "Value Type", "options:MIN:AVG:MAX:MINMAX", "AVG"));
      props.add(MapItemPropItem(
          "", "kind", "Kind", "options:BARS:CANDLES:BONES", "BONES"));
      props.add(
          MapItemPropItem("", "chart_color", "Chart Color", "color", "{fore}"));
      props.add(MapItemPropItem(
          "", "chart_error_color", "Chart Error Color", "color", "FFF90B1A"));
      props.add(MapItemPropItem(
          "", "candle_up_color", "Candle Up Color", "color", "FF02FC81"));
      props.add(MapItemPropItem(
          "", "candle_down_color", "Candle Down Color", "color", "FFF90B1A"));
      props.add(MapItemPropItem("", "show_zero", "Show Zero", "bool", "0"));
      props.add(MapItemPropItem("", "show_legend", "Show Legend", "bool", "1"));
      props.add(MapItemPropItem("", "icon_name", "Icon Name", "material_icon",
          "keyboard_arrow_left"));
      groups.add(MapItemPropGroup("Chart", true, props));
      groups.add(textAppearanceGroup());
      groups.add(borderGroup());
      groups.add(backgroundGroup());
    }
    return groups;
  }
}
