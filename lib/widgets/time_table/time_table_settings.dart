import 'dart:math';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/chart_groups/chart_group_form/chart_group_data_items.dart';
import 'package:gazer_client/forms/maps/map_form/map_item.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_prop_container.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_vertical_scale.dart';

class TimeTableSettings extends TimeChartPropContainer {
  TimeTableSettings(Connection conn) : super(conn) {
    currentItems = buildItems();
  }

  double scrollOffset = 0;
  int currentHeight = 0;
  double itemHeight = 30;

  bool keyControl = false;
  bool keyAlt = false;
  bool keyShift = false;

  void setKeys(control, alt, shift) {
    keyControl = control;
    keyAlt = alt;
    keyShift = shift;
  }

  double displayMin = 0;
  double displayMax = 0;

  void setDisplayRangeLast(double seconds) {
    int now = DateTime.now().microsecondsSinceEpoch;
    double min = (now - seconds * 1000000);
    double max = now.toDouble();

    displayMin = min;
    displayMax = max;
  }

  double calcHeight() {
    return currentItems.length * itemHeight;
  }

  void draw(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..style = PaintingStyle.fill
          ..color = Colors.black38);

    int startVisibleIndex = scrollOffset ~/ itemHeight;
    for (int i = startVisibleIndex; i < startVisibleIndex + currentHeight / itemHeight; i++) {
      if (i < 0 || i >= currentItems.length) {
        continue;
      }
      drawText(
          canvas,
          0,
          i * itemHeight,
          300,
          itemHeight,
          currentItems[i],
          12,
          Colors.white,
          TextAlign.start,
          false);
    }

    canvas.drawRect(
        const Offset(0, 0) & Size(size.width, size.height),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.white30
          ..strokeWidth = 1);
  }

  void drawText(Canvas canvas, double x, double y, double width, double height, String text, double size, Color color, TextAlign align, bool verticalCenter) {
    var textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
      ),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: align, ellipsis: "   ...");
    textPainter.layout(
      minWidth: width,
      maxWidth: width,
    );
    //textPainter.paint(canvas, Offset(x, y));
    if (verticalCenter) {
      textPainter.paint(canvas, Offset(x, y + (height / 2) - (textPainter.height / 2)));
    } else {
      textPainter.paint(canvas, Offset(x, y));
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {};
    for (var propKey in props.keys) {
      result[propKey] = props[propKey];
    }

    return result;
  }

  factory TimeTableSettings.fromJson(Connection conn, Map<String, dynamic> json) {
    print("loading settings ${json['areas']}");
    var settings = TimeTableSettings(conn);
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
    MapItemPropPage pageDataItems = MapItemPropPage("Data Items", const Icon(Icons.data_usage), []);
    pageDataItems.widget = ChartGroupDataItems(connection);
    {
      List<MapItemPropItem> props = [];
      //props.add(MapItemPropItem("", "update_period", "Data Source", "data_source", ""));
      //pageMain.groups.add(MapItemPropGroup("Data Source", true, props));
    }
    return [pageDataItems];
  }

  List<String> buildItems() {
    List<String> items = [];
    for (int i = 0; i < 100; i++) {
      items.add("item_" + i.toString());
    }
    return items;
  }

  List<String> currentItems = [];
}
