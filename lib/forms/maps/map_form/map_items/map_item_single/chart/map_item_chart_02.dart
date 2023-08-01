import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gazer_client/core/protocol/dataitem/data_item_history_chart.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import '../../../../utils/draw_text.dart';
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
    if (DateTime.now().difference(lastUpdateDataDT) <
        const Duration(milliseconds: 500)) {
      return;
    }

    lastUpdateDataDT = DateTime.now();
  }

  Color currentChartColor = Colors.blueAccent;

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    DateTime now = DateTime.now();

    double padding = z(10);

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

    data = Repository()
        .history
        .getNode(connection)
        .getHistory(getDataSource(), begin, end, timeSlot);

    expectedCountOfItem =
        ((end.toDouble() - begin.toDouble()) / timeSlot.toDouble()).round();

    drawPre(canvas, size);

    double minValue = double.maxFinite;
    double maxValue = -double.maxFinite;

    for (int i = 0; i < data.length; i++) {
      if (data[i].minValue < minValue) {
        minValue = data[i].minValue;
      }
      if (data[i].maxValue > maxValue) {
        maxValue = data[i].maxValue;
      }
    }

    if (maxValue < minValue) {
      return;
    }

    double valuesRange = maxValue - minValue;

    double pixelsPerValueX = width / expectedCountOfItem;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(x, y, width, height));

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

      if (get("value_type") == "CANDLES") {
        double xRange = (end - begin).toDouble();
        double x01 = (item.datetimeFirst - begin) / xRange;
        double left = x + x01 * width;
        double right = left + pixelsPerValueX * barWidth;
        double value1_01 = (item.firstValue - minValue) / valuesRange;
        double value2_01 = (item.lastValue - minValue) / valuesRange;
        double lineY1 = (item.maxValue - minValue) / valuesRange;
        lineY1 = y + height - lineY1 * height;
        double lineY2 = (item.minValue - minValue) / valuesRange;
        lineY2 = y + height - lineY2 * height;
        double top = y + height - value1_01 * height;
        double bottom = y + height - value2_01 * height;
        Rect rect = Rect.fromLTRB(left, top, right, bottom);
        drawCandle(
            canvas, rect, lineY1, lineY2, item.firstValue < item.lastValue);
      }

      if (get("value_type") == "MINMAX") {
        double xRange = (end - begin).toDouble();
        double x01 = (item.datetimeFirst - begin) / xRange;
        double left = x + x01 * width;
        double right = left + pixelsPerValueX * barWidth;
        double value1_01 = (item.maxValue - minValue) / valuesRange;
        double value2_01 = (item.minValue - minValue) / valuesRange;
        double top = y + height - value1_01 * height;
        double bottom = y + height - value2_01 * height;
        Rect rect = Rect.fromLTRB(left, top, right, bottom);
        drawBar(canvas, rect);
      }
      if (get("value_type") == "MIN" ||
          get("value_type") == "MAX" ||
          get("value_type") == "AVG") {
        double value = item.minValue;
        switch (get("value_type")) {
          case "MIN":
            value = item.minValue;
            break;
          case "AVG":
            value = item.avgValue;
            break;
          case "MAX":
            value = item.maxValue;
            break;
        }

        double xRange = (end - begin).toDouble();
        double x01 = (item.datetimeFirst - begin) / xRange;
        double left = x + x01 * width;
        double right = left + pixelsPerValueX * barWidth;
        double value01 = (value - minValue) / valuesRange;
        double top = y + height - value01 * height;
        double bottom = y + height;
        Rect rect = Rect.fromLTRB(left, top, right, bottom);
        drawBar(canvas, rect);
      }
    }

    canvas.restore();

    drawText(
      canvas,
      getDoubleZ("x") + padding,
      getDoubleZ("y"),
      getDoubleZ("w"),
      padding,
      maxValue.toString(),
      padding * 0.7,
      getColor("chart_color"),
      TextVAlign.top,
      TextAlign.left,
      null,
      400,
    );

    drawText(
      canvas,
      getDoubleZ("x") + padding,
      getDoubleZ("y") + getDoubleZ("h") - padding,
      getDoubleZ("w"),
      padding,
      minValue.toString(),
      padding * 0.7,
      getColor("chart_color"),
      TextVAlign.top,
      TextAlign.left,
      null,
      400,
    );

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

  void drawCandle(
      Canvas canvas, Rect rect, double y1, double y2, bool upwards) {
    if (rect.height < 1) {
      rect = Rect.fromLTRB(rect.left, rect.top - 2, rect.right, rect.bottom);
    }

    Color candleColor =
        upwards ? getColor("candle_up_color") : getColor("candle_down_color");

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

  @override
  void drawDemo(Canvas canvas, Size size) {}

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
      props.add(MapItemPropItem("", "value_type", "Value Type, sec",
          "options:MIN:AVG:MAX:MINMAX:CANDLES", "AVG"));
      props.add(
          MapItemPropItem("", "chart_color", "Chart Color", "color", "{fore}"));
      props.add(MapItemPropItem(
          "", "candle_up_color", "Candle Up Color", "color", "FF02FC81"));
      props.add(MapItemPropItem(
          "", "candle_down_color", "Candle Down Color", "color", "FFF90B1A"));
      groups.add(MapItemPropGroup("Chart", true, props));
      groups.add(borderGroup());
      groups.add(backgroundGroup());
    }
    return groups;
  }
}
