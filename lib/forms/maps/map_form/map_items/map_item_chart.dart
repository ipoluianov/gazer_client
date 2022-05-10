import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gazer_client/core/protocol/dataitem/data_item_history_chart.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_decorations/map_item_decoration_rect_01.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_decorations/map_item_decoration_set.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_settings.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_settings_area.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_settings_series.dart';

import '../map_item.dart';

class MapItemChart extends MapItem {
  static const String sType = "chart.01";
  static const String sName = "Chart.01";
  @override
  String type() {
    return sType;
  }

  late String lastDataSource = "";

  MapItemChart(Connection connection) : super(connection) {

    settings = TimeChartSettings(connection, []);
    settings.areas.add(TimeChartSettingsArea(connection, <TimeChartSettingsSeries>[TimeChartSettingsSeries(connection, get("data_source"), [], Colors.blueAccent)]));
  }

  late TimeChartSettings settings;

  int tickCounter = 0;
  double lastSeconds = 30;

  @override
  void tick() {
    super.tick();

    tickCounter++;

    if (tickCounter > 20) {
      settings.setDisplayRangeLast(lastSeconds);

      double w = settings.horScale.width;
      double r = settings.horScale.displayMax - settings.horScale.displayMin;
      int timePerPixel = (r / getDouble("w")).round();

      for (int areaIndex = 0; areaIndex < settings.areas.length; areaIndex++) {
        var area = settings.areas[areaIndex];
        for (int seriesIndex = 0; seriesIndex < area.series.length; seriesIndex++) {
          var series = area.series[seriesIndex];
          if (series.itemName() != "") {
            var data = Repository()
                .history
                .getHistory(connection, series.itemName(), settings.horScale.displayMin.round(), settings.horScale.displayMax.round(), timePerPixel);

            series.itemHistory = data;
            series.displayName = Repository().history.value(connection, series.itemName()).displayName;
            series.loadingTasks = Repository()
                .history.getLoadingTasks(connection, series.itemName());
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

    Color chartColor = getColorWithThresholds("chart_color");

    var ds = getDataSource();

    if (lastDataSource != ds || currentChartColor != chartColor) {
      lastDataSource = ds;
      settings = TimeChartSettings(connection, []);
      if (ds.isNotEmpty && !ds.startsWith("~")) {
        settings.areas.add(TimeChartSettingsArea(connection, <TimeChartSettingsSeries>[TimeChartSettingsSeries(connection, lastDataSource, [], chartColor)]));
      }
    }

    bool showTimeScale = getBoolWithThresholds("show_time_scale");
    settings.showTimeScale = showTimeScale;

    currentChartColor = chartColor;

    lastSeconds = getDoubleWithThresholds("period");
    if (lastSeconds < 1) {
      lastSeconds = 1;
    }
    if (lastSeconds > 86400 * 365) {
      lastSeconds > 86400 * 365;
    }

    canvas.save();
    canvas.translate(getDoubleZ("x"), getDoubleZ("y"));
    Size chartAreaSize = Size(getDoubleZ("w"), getDoubleZ("h"));
    settings.draw(canvas, chartAreaSize);
    canvas.restore();

    /*canvas.drawRect(Rect.fromLTWH(getDoubleZ("x"), getDoubleZ("y"), getDoubleZ("w"), z(25)), Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill
    );*/
    /*drawText(
        canvas,
        getDoubleZ("x") + z(30),
        getDoubleZ("y"),
        getDoubleZ("w"),
        z(25),
        getDataSource(),
        z(14),
        Colors.yellow,
        TextAlign.left);*/

    drawPost(canvas, size);
  }

  @override
  void drawDemo(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.teal
      ..strokeWidth = 2
    );

    List<Offset> points = [
      Offset(0.3 * size.width / 4, size.height- (size.height / 8)),
      Offset(1.3 * size.width / 4, size.height - (size.height / 2)),
      Offset(2.3 * size.width / 4, size.height - (size.height / 3)),
      Offset(3.3 * size.width / 4, size.height - (size.height / 1.5)),
    ];

    Path path = Path();
    path.addPolygon(points, false);

    canvas.drawPath(path, Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.teal.withOpacity(0.5)
      ..strokeWidth = 5);
  }

  @override
  void setDefaultsForItem() {
    postDecorations = MapItemDecorationList([]);
    {
      var decoration = MapItemDecorationRect01();
      decoration.initDefaultProperties();
      postDecorations.items.add(decoration);
    }
  }

  void drawText(Canvas canvas, double x, double y, double width, double height, String text, double size, Color color, TextAlign align) {
    var textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
      ),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: align);
    textPainter.layout(
      minWidth: width,
      maxWidth: width,
    );
    textPainter.paint(canvas, Offset(x, y + (height / 2) - (textPainter.height / 2)));
  }

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "period", "Period, sec", "double", "300"));
      props.add(MapItemPropItem("", "chart_color", "Chart Color", "color", "FF0EC35E"));
      props.add(MapItemPropItem("", "show_time_scale", "Show Time Scale", "bool", "0"));
      groups.add(MapItemPropGroup("Text", true, props));
    }
    return groups;
  }

  @override
  List<MapItemPropItem> propThresholdOfItem() {
    List<MapItemPropItem> props = [];
    props.add(MapItemPropItem("", "period", "Period, sec", "double", "300"));
    props.add(MapItemPropItem("", "chart_color", "Chart Color", "color", "FF0EC35E"));
    props.add(MapItemPropItem("", "show_time_scale", "Show Time Scale", "bool", "0"));
    return props;
  }

}
