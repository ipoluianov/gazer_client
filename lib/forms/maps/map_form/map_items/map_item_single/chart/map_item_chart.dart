import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gazer_client/core/protocol/dataitem/data_item_history_chart.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_settings.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_settings_area.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_settings_series.dart';

import '../../../../utils/draw_text.dart';
import '../../../main/map_item.dart';
import '../map_item_single.dart';

class MapItemChart extends MapItemSingle {
  static const String sType = "chart.01";
  static const String sName = "Chart.01";
  @override
  String type() {
    return sType;
  }

  late String lastDataSource = "";

  MapItemChart(Connection connection) : super(connection) {
    settings = TimeChartSettings(connection, []);
    settings.areas.add(TimeChartSettingsArea(
        connection, <TimeChartSettingsSeries>[
      TimeChartSettingsSeries(
          connection, get("data_source"), [], Colors.blueAccent)
    ]));
  }

  late TimeChartSettings settings;

  int tickCounter = 0;
  double lastSeconds = 30;

  @override
  void tick() {
    tickCounter++;

    if (tickCounter > 20) {
      settings.setDisplayRangeLast(lastSeconds);

      double w = settings.horScale.width;
      double r = settings.horScale.displayMax - settings.horScale.displayMin;
      int timePerPixel = (r / getDouble("w")).round();

      for (int areaIndex = 0; areaIndex < settings.areas.length; areaIndex++) {
        var area = settings.areas[areaIndex];
        for (int seriesIndex = 0;
            seriesIndex < area.series.length;
            seriesIndex++) {
          var series = area.series[seriesIndex];
          if (series.itemName() != "") {
            var data = Repository().history.getNode(connection).getHistory(
                series.itemName(),
                settings.horScale.displayMin.round(),
                settings.horScale.displayMax.round(),
                timePerPixel);

            series.itemHistory = data;
            series.displayName = Repository()
                .history
                .getNode(connection)
                .value(series.itemName())
                .displayName;
            series.loadingTasks = Repository()
                .history
                .getNode(connection)
                .getLoadingTasks(series.itemName());
          }
        }
      }
    }
  }

  Color currentChartColor = Colors.blueAccent;

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    drawPre(canvas, size);
    //Color color = Colors.purpleAccent;

    Color chartColor = getColor("chart_color");

    var ds = getDataSource();

    if (lastDataSource != ds || currentChartColor != chartColor) {
      lastDataSource = ds;
      settings = TimeChartSettings(connection, []);
      if (ds.isNotEmpty && !ds.startsWith("~")) {
        settings.areas.add(TimeChartSettingsArea(
            connection, <TimeChartSettingsSeries>[
          TimeChartSettingsSeries(connection, lastDataSource, [], chartColor)
        ]));
      }
    }

    bool showTimeScale = getBool("show_time_scale");
    settings.showTimeScale = showTimeScale;

    currentChartColor = chartColor;

    lastSeconds = getDouble("span");
    if (lastSeconds < 5) {
      lastSeconds = 5;
    }
    if (lastSeconds > 86400 * 365) {
      lastSeconds > 86400 * 365;
    }

    canvas.save();
    canvas.translate(getDoubleZ("x"), getDoubleZ("y"));
    Size chartAreaSize = Size(getDoubleZ("w"), getDoubleZ("h"));
    settings.draw(canvas, chartAreaSize);
    canvas.restore();

    if (lastDataSource.isEmpty) {
      drawText(
        canvas,
        getDoubleZ("x"),
        getDoubleZ("y"),
        getDoubleZ("w"),
        getDoubleZ("h"),
        "no data source",
        32,
        currentChartColor,
        TextVAlign.top,
        TextAlign.left,
        "Roboto",
        400,
      );
    }

    /*canvas.drawRect(Rect.fromLTWH(getDoubleZ("x"), getDoubleZ("y"), getDoubleZ("w"), z(25)), Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill
    );*/
    drawPost(canvas, size);
  }

  @override
  void drawDemo(Canvas canvas, Size size) {
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.teal
          ..strokeWidth = 2);

    List<Offset> points = [
      Offset(0.3 * size.width / 4, size.height - (size.height / 8)),
      Offset(1.3 * size.width / 4, size.height - (size.height / 2)),
      Offset(2.3 * size.width / 4, size.height - (size.height / 3)),
      Offset(3.3 * size.width / 4, size.height - (size.height / 1.5)),
    ];

    Path path = Path();
    path.addPolygon(points, false);

    canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.teal.withOpacity(0.5)
          ..strokeWidth = 5);
  }

  @override
  void setDefaultsForItem() {}

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    groups.addAll(super.propGroupsOfItem());
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "span", "Span, sec", "double", "300"));
      props.add(
          MapItemPropItem("", "chart_color", "Chart Color", "color", "{fore}"));
      props.add(MapItemPropItem(
          "", "show_time_scale", "Show Time Scale", "bool", "0"));
      groups.add(MapItemPropGroup("Chart", true, props));
    }
    return groups;
  }
}
