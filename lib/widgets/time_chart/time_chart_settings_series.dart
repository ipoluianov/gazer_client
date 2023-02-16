import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/history/history.dart';
import 'package:gazer_client/core/protocol/dataitem/data_item_history_chart.dart';
import 'package:gazer_client/core/tools/hex_colors.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/chart_groups/chart_group_form/chart_group_data_items.dart';
import 'package:gazer_client/forms/maps/map_form/main/map_item.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_horizontal_scale.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_prop_container.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_settings.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_vertical_scale.dart';
import 'package:intl/intl.dart' as international;

import '../../core/history/history_loading_task.dart';

class TimeChartSettingsSeries extends TimeChartPropContainer {
  double xOffset = 0;
  double yOffset = 0;
  double yOffsetOfHeader = 0;
  double width = 0;
  double height = 0;
  double verticalScaleWidth111 = 0;
  bool selected = false;
  String displayName = "";

  TimeChartVerticalScale vScale = TimeChartVerticalScale();
  List<DataItemHistoryChartItemValueResponse> itemHistory = [];
  List<HistoryLoadingTask> loadingTasks = [];

  TimeChartSettingsSeries(
      Connection conn, String itemName, this.itemHistory, Color color)
      : super(conn) {
    props = {};
    initDefaultProperties();
    set("item_name", itemName);
    set("stroke_color", colorToHex(color));
    generateAndSetNewId();
  }

  void calc(double x, double y, double w, double h, double vsWidth,
      TimeChartVerticalScale vSc, double yHeaderOffset) {
    //verticalScaleWidth = vsWidth;
    xOffset = x;
    yOffset = y;
    width = w;
    height = h;
    yOffsetOfHeader = yHeaderOffset;
    List<DataItemHistoryChartItemValueResponse> history = itemHistory;
    vScale = vSc;
  }

  void drawPoint(DataItemHistoryChartItemValueResponse item) {}

  String itemName() {
    return get("item_name");
  }

  String getDisplayName() {
    if (displayName.isEmpty) {
      return itemName();
    }
    return displayName;
  }

  void draw(
      Canvas canvas,
      Size s,
      TimeChartHorizontalScale hScale,
      TimeChartSettings settings,
      bool smooth,
      int index,
      int totalSeriesCount) {
    List<DataItemHistoryChartItemValueResponse> history = itemHistory;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(xOffset + verticalScaleWidth111, 0,
        width - verticalScaleWidth111, height));

    {
      vScale.animation();

      var paint = Paint()
        ..style = PaintingStyle.stroke
        ..color = getColor("stroke_color")
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = getDouble("stroke_width");

      var paintQualityGood = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.green
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 0.2;

      var paintQualityBad = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.red
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 5;

      var paintLoading = Paint()
        ..style = PaintingStyle.stroke
        ..color = Colors.lightBlue
        ..strokeJoin = StrokeJoin.round
        ..strokeWidth = 1;

      List<Offset> points = [];
      List<Offset> pointsQuality = [];
      bool lastHasGood = false;
      bool lastHasBad = false;

      void funcDrawPoints() {
        //print("points: ${points.length} hislen: ${history.length}");
        if (points.length == 1) {
          canvas.drawCircle(points[0], 1, paint..style = PaintingStyle.fill);
          //canvas.drawPoints(PointMode.points, points, paint);
        } else {
          if (smooth) {
            canvas.drawPoints(PointMode.polygon, points,
                paint..color = paint.color.withOpacity(0.2));
          } else {
            canvas.drawPoints(PointMode.polygon, points, paint);
          }
          /*if (selected) {
            canvas.drawPoints(PointMode.polygon, points, paint
              ..strokeWidth = paint.strokeWidth + 4
              ..strokeCap = StrokeCap.round
                ..color = paint.color.withOpacity(0.2)
            );
          }*/
        }
        points = [];
      }

      void funcDrawPointsQuality() {
        var currentPaint = paintQualityGood;
        if (lastHasBad) {
          currentPaint = paintQualityBad;
        }

        canvas.drawPoints(PointMode.polygon, pointsQuality, currentPaint);
        pointsQuality = [];
      }

      for (int i = 0; i < history.length; i++) {
        bool firstPoint = i == 0;
        var item = history[i];

        var posX = hScale.horValueToPixel(item.datetimeFirst.toDouble());
        if (item.hasGood) {
          if (lastHasGood || firstPoint) {
            points.add(Offset(posX, vScale.verValueToPixel(item.firstValue)));
          }
          if (item.minValue != item.firstValue) {
            points.add(Offset(posX, vScale.verValueToPixel(item.minValue)));
          }
          if (item.maxValue != item.minValue) {
            points.add(Offset(posX, vScale.verValueToPixel(item.maxValue)));
          }
          if (item.lastValue != item.maxValue) {
            points.add(Offset(posX, vScale.verValueToPixel(item.lastValue)));
          }
        } else {
          funcDrawPoints();
        }

        if (!item.hasBad) {
          if (pointsQuality.isEmpty ||
              (item.hasBad != lastHasBad || i == history.length - 1)) {
            pointsQuality.add(Offset(posX, yOffsetOfHeader));
          }
        } else {
          if (pointsQuality.isEmpty ||
              (item.hasBad != lastHasBad) ||
              i == history.length - 1) {
            pointsQuality.add(Offset(posX, yOffsetOfHeader));
          }
        }

        if (item.hasBad != lastHasBad) {
          funcDrawPointsQuality();
        }

        lastHasGood = item.hasGood;
        lastHasBad = item.hasBad;
      }

      funcDrawPoints();
      funcDrawPointsQuality();

      if (loadingTasks.isNotEmpty) {
        // draw loading
        for (var loadingTask in loadingTasks) {
          List<Offset> pointsLoadingTasks = [];
          var posX1 = hScale.horValueToPixel(loadingTask.minTime.toDouble());
          var posX2 = hScale.horValueToPixel(loadingTask.maxTime.toDouble());
          pointsLoadingTasks.add(Offset(posX1, height - 5));
          pointsLoadingTasks.add(Offset(posX2, height - 5));
          canvas.drawPoints(
              PointMode.polygon, pointsLoadingTasks, paintLoading);
        }
      }
    }

    //drawText(canvas, 0, 0, width - verticalScaleWidth - 10, 20, itemName, 14, Colors.yellowAccent, TextAlign.right);

    canvas.restore();

    final f = international.NumberFormat("#.##########");
    String formatValue(num n) {
      return f.format(n);
    }
  }

  void drawDetails(
      Canvas canvas,
      Size s,
      TimeChartHorizontalScale hScale,
      TimeChartSettings settings,
      bool smooth,
      int index,
      int totalSeriesCount) {
    List<DataItemHistoryChartItemValueResponse> history = itemHistory;

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(xOffset + verticalScaleWidth111, 0,
        width - verticalScaleWidth111, height));

    if (settings.selectionMin != settings.selectionMax) {
      Color color = getColor("stroke_color");

      double detailsWidth = 150;
      //double detailsHeight = 200;
      double detailsOffsetX =
          width - detailsWidth - (totalSeriesCount - index - 1) * detailsWidth;
      double detailsOffsetY = 0;
      double detailsItemHeight = 20;
      canvas.drawRect(
          Rect.fromLTWH(detailsOffsetX, 0, detailsWidth, height),
          Paint()
            ..color = Colors.black.withOpacity(0.6)
            ..style = PaintingStyle.fill);

      canvas.drawRect(
          Rect.fromLTWH(detailsOffsetX, 0, detailsWidth, height),
          Paint()
            ..color = color.withOpacity(0.2)
            ..style = PaintingStyle.fill);

      double statSum = 0;
      double statAVG = 0;
      int statAVGCount = 0;
      double statMin = double.maxFinite;
      double statMax = -double.maxFinite;
      double statNum = 0;
      {
        for (int i = 0; i < history.length; i++) {
          var item = history[i];
          if (item.datetimeFirst > settings.selectionMin &&
              item.datetimeLast < settings.selectionMax) {
            if (item.hasGood) {
              //statAVG += item.avgValue * item.countOfValues;
              statNum += item.countOfValues;
              //statAVGCount += item.countOfValues;
              statSum += item.sumValue;
              if (item.minValue < statMin) {
                statMin = item.minValue;
              }
              if (item.maxValue > statMax) {
                statMax = item.maxValue;
              }
            }
          }
        }

        if (statNum > 0) {
          statAVG = statSum / statNum;
        }
      }

      drawText(canvas, detailsOffsetX, detailsOffsetY, width, detailsItemHeight,
          "Min: $statMin", 12, color, TextAlign.start);
      detailsOffsetY += detailsItemHeight;

      drawText(canvas, detailsOffsetX, detailsOffsetY, width, detailsItemHeight,
          "Avg: $statAVG", 12, color, TextAlign.start);
      detailsOffsetY += detailsItemHeight;

      drawText(canvas, detailsOffsetX, detailsOffsetY, width, detailsItemHeight,
          "Max: $statMax", 12, color, TextAlign.start);
      detailsOffsetY += detailsItemHeight;

      /*drawText(canvas, detailsOffsetX, detailsOffsetY, width, detailsItemHeight, "Num: $statNum", 10, color, TextAlign.start);
      detailsOffsetY += detailsItemHeight;

      drawText(canvas, detailsOffsetX, detailsOffsetY, width, detailsItemHeight, "Sum: $statSum", 10, color, TextAlign.start);
      detailsOffsetY += detailsItemHeight;*/
    }

    canvas.restore();
  }

  String dataItem() {
    return get("item_name");
  }

  bool showZero() {
    return getBool("show_zero");
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

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {};
    for (var propKey in props.keys) {
      result[propKey] = props[propKey];
    }
    return result;
  }

  factory TimeChartSettingsSeries.fromJson(
      Connection conn, Map<String, dynamic> json) {
    var settings =
        TimeChartSettingsSeries(conn, json['item_name'], [], Colors.amber);
    for (var propKey in json.keys) {
      settings.props[propKey] = json[propKey];
    }
    return settings;
  }

  @override
  List<MapItemPropPage> propList() {
    MapItemPropPage pageMain =
        MapItemPropPage("Series", const Icon(Icons.domain), []);
    MapItemPropPage pageDataItems =
        MapItemPropPage("Data Items", const Icon(Icons.data_usage), []);
    pageDataItems.widget = ChartGroupDataItems(connection);
    {
      List<MapItemPropItem> props = [];
      props.add(
          MapItemPropItem("", "stroke_color", "Color", "color", "FF00EFFF"));
      props.add(
          MapItemPropItem("", "stroke_width", "Stroke Width", "double", "1.5"));
      props.add(MapItemPropItem("", "show_zero", "Show Zero", "bool", "0"));
      pageMain.groups.add(MapItemPropGroup("View", true, props));
    }
    {
      List<MapItemPropItem> props = [];
      props.add(
          MapItemPropItem("", "item_name", "Data Source", "data_source", ""));
      pageMain.groups.add(MapItemPropGroup("Data Source", true, props));
    }
    return [pageMain, pageDataItems];
  }
}
