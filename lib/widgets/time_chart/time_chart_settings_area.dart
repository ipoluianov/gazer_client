import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/chart_groups/chart_group_form/chart_group_data_items.dart';
import 'package:gazer_client/forms/maps/map_form/main/map_item.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_horizontal_scale.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_prop_container.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_settings.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_settings_series.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_vertical_scale.dart';

class TimeChartSettingsArea extends TimeChartPropContainer {
  //bool unitedVerticalScale = false;
  double verticalScalesWidth = 0;
  double xOffset = 0;
  double yOffset = 0;
  double width = 0;
  double height = 0;
  bool selected = false;

  List<TimeChartSettingsSeries> series = [];
  TimeChartSettingsArea(Connection conn, this.series) : super(conn) {
    props = {};
    initDefaultProperties();
    generateAndSetNewId();
  }

  TimeChartVerticalScale unitedVScale = TimeChartVerticalScale();

  void calc(TimeChartSettings settings, double x, double y, double w, double h,
      double vsWidth) {
    xOffset = x;
    yOffset = y;
    width = w;
    height = h;
    if (unitedVerticalScale()) {
      var vScale = TimeChartVerticalScale();
      for (int seriesIndex = 0; seriesIndex < series.length; seriesIndex++) {
        var s = series[seriesIndex];
        vScale.updateVerticalScaleValues(s.itemHistory, true);
        s.calc(
            x,
            y,
            w,
            h,
            vsWidth,
            vScale,
            seriesIndex * settings.legendItemHeight +
                settings.legendItemHeight / 2 +
                settings.legendItemYOffset);
        s.vScale.calc(
            0, y, TimeChartVerticalScale.defaultVerticalScaleWidthInline, h);
      }
      if (showZero()) {
        vScale.expandToZero();
      }
    } else {
      for (int seriesIndex = 0; seriesIndex < series.length; seriesIndex++) {
        var s = series[seriesIndex];
        var vScale = TimeChartVerticalScale();
        vScale.updateVerticalScaleValues(s.itemHistory, false);
        s.calc(
            x,
            y,
            w,
            h,
            vsWidth,
            vScale,
            seriesIndex * settings.legendItemHeight +
                settings.legendItemHeight / 2 +
                settings.legendItemYOffset);
        s.vScale.calc(
            seriesIndex *
                TimeChartVerticalScale.defaultVerticalScaleWidthInline,
            y,
            50,
            h);
        if (showZero() || s.showZero()) {
          s.vScale.expandToZero();
        }
      }
    }
  }

  bool unitedVerticalScale() {
    return getBool("united_scale");
  }

  bool showZero() {
    return getBool("show_zero");
  }

  double calcWidth11() {
    if (unitedVerticalScale()) {
      if (series.isNotEmpty) {
        return TimeChartVerticalScale.defaultVerticalScaleWidth;
      }
    } else {
      return series.length.toDouble() *
          TimeChartVerticalScale.defaultVerticalScaleWidth;
    }
    return 0;
  }

  void draw(Canvas canvas, Size size, TimeChartHorizontalScale hScale,
      TimeChartSettings settings, bool last) {
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, yOffset, size.width, height));
    canvas.translate(0, yOffset);
    bool someSeriesSelected = false;
    for (int seriesIndex = 0; seriesIndex < series.length; seriesIndex++) {
      var s = series[seriesIndex];
      if (s.selected) {
        someSeriesSelected = true;
        break;
      }
    }

    for (int seriesIndex = 0; seriesIndex < series.length; seriesIndex++) {
      var s = series[seriesIndex];
      bool smooth = false;
      if (settings.editing() && someSeriesSelected) {
        if (!s.selected) {
          smooth = true;
        }
      }
      s.draw(
          canvas, size, hScale, settings, smooth, seriesIndex, series.length);
    }

    for (int seriesIndex = 0; seriesIndex < series.length; seriesIndex++) {
      var s = series[seriesIndex];
      s.drawDetails(
          canvas, size, hScale, settings, false, seriesIndex, series.length);
    }

    if (settings.showVerticalScale && series.isNotEmpty) {
      if (unitedVerticalScale()) {
        var s = series[0];
        var vScaleColor = DesignColors.fore();
        if (series.length == 1) {
          vScaleColor = s.getColor("stroke_color");
        }

        s.vScale.draw(canvas, size, vScaleColor, 0, getBool("show_legend"), 1);
      } else {
        for (int seriesIndex = 0; seriesIndex < series.length; seriesIndex++) {
          var s = series[seriesIndex];
          s.vScale.draw(canvas, size, s.getColor("stroke_color"), seriesIndex,
              getBool("show_legend"), series.length);
        }
      }
    }

    if (!last) {
      canvas.drawLine(
          Offset(xOffset, height - 1),
          Offset(xOffset + width, height - 1),
          Paint()
            ..color = Colors.blueGrey
            ..strokeWidth = 2);
    }

    bool seriesInAreaSelected = false;

    for (var s in series) {
      if (s.selected) {
        seriesInAreaSelected = true;
      }
    }

    if (selected || seriesInAreaSelected) {
      canvas.drawRect(
          Rect.fromLTWH(10, 10, width - 20, height - 20),
          Paint()
            ..color = Colors.yellowAccent.withOpacity(0.2)
            ..strokeWidth = 5
            ..style = PaintingStyle.stroke);
    }

    canvas.restore();
  }

  @override
  List<MapItemPropPage> propList() {
    MapItemPropPage pageMain =
        MapItemPropPage("Chart Area", const Icon(Icons.domain), []);
    MapItemPropPage pageDataItems =
        MapItemPropPage("Data Items", const Icon(Icons.data_usage), []);
    pageDataItems.widget = ChartGroupDataItems(connection);
    {
      List<MapItemPropItem> props = [];
      props.add(
          MapItemPropItem("", "united_scale", "United Scale", "bool", "1"));
      props.add(MapItemPropItem("", "show_zero", "Show Zero", "bool", "0"));
      props.add(MapItemPropItem("", "show_legend", "Show Legend", "bool", "1"));
      pageMain.groups.add(MapItemPropGroup("Settings", true, props));
    }
    return [pageMain, pageDataItems];
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {};
    for (var propKey in props.keys) {
      result[propKey] = props[propKey];
    }

    List<Map<String, dynamic>> ss = [];
    for (var s in series) {
      var chRes = s.toJson();
      ss.add(chRes);
    }
    result["series"] = ss;

    return result;
  }

  factory TimeChartSettingsArea.fromJson(
      Connection conn, Map<String, dynamic> json) {
    var settings = TimeChartSettingsArea(
        conn,
        json['series']
            .map<TimeChartSettingsSeries>(
                (model) => TimeChartSettingsSeries.fromJson(conn, model))
            .toList());
    for (var propKey in json.keys) {
      if (propKey == "series") {
        continue;
      }
      settings.props[propKey] = json[propKey];
    }
    return settings;
  }
}
