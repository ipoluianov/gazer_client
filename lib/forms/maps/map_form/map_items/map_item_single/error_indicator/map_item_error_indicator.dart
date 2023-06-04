import 'package:flutter/material.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import '../../../../utils/draw_text.dart';
import '../../../main/map_item.dart';

class MapItemErrorIndicator extends MapItem {
  static const String sType = "error_indicator.01";
  static const String sName = "Error Indicator.01";
  @override
  String type() {
    return sType;
  }

  MapItemErrorIndicator(Connection connection) : super(connection) {
    setDouble("font_size", 20);
  }

  @override
  void setDefaultsForItem() {
    setDouble("w", 200);
    setDouble("h", 40);
  }

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    drawPre(canvas, size);
    Color color = Colors.green;

    var text = get("text");

    bool isError = false;

    if (hasDataSource()) {
      var value = dataSourceValue();
      if (value.uom == "error") {
        isError = true;
      }
    }

    var fontSizeGood = getDoubleZ("font_regular_size");
    var fontSizeBad = getDoubleZ("font_error_size");

    text = text.replaceAll("[nl]", "\n");

    double widthZ = getDoubleZ("w");
    double heightZ = getDoubleZ("h");

    double indicatorWidth = heightZ;
    double indicatorRadius = indicatorWidth / 2.5;

    var textColor = Colors.white;
    var fontSize = fontSizeGood;
    if (isError) {
      textColor = getColor("text_error_color");
      fontSize = fontSizeBad;
    } else {
      textColor = getColor("text_regular_color");
    }

    drawText(
      canvas,
      getDoubleZ("x") + indicatorWidth,
      getDoubleZ("y"),
      getDoubleZ("w") - indicatorWidth,
      getDoubleZ("h"),
      text,
      fontSize,
      textColor,
      TextVAlign.middle,
      TextAlign.left,
      null,
      0,
    );

    var indicatorColor = getColor("regular_color");
    if (isError) {
      indicatorColor = getColor("error_color");
    }
    canvas.drawCircle(
        Offset(getDoubleZ("x") + indicatorWidth / 2,
            (getDoubleZ("y") + getDoubleZ("h") / 2)),
        indicatorRadius,
        Paint()..color = indicatorColor);

    drawPost(canvas, size);
  }

  @override
  void drawDemo(Canvas canvas, Size size) {
    setDouble("w", 100);
    setDouble("h", 40);
    draw(canvas, size, []);
  }

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "text", "Text", "text", "Text"));

      props.add(MapItemPropItem(
          "", "regular_color", "Regular Color", "color", "{good}"));
      props.add(MapItemPropItem(
          "", "text_regular_color", "Text Regular Color", "color", "{good}"));
      props.add(MapItemPropItem(
          "", "font_regular_size", "Font Regular Size", "font_size", "20"));

      props.add(
          MapItemPropItem("", "error_color", "Error Color", "color", "{bad}"));
      props.add(MapItemPropItem(
          "", "text_error_color", "Text Error Color", "color", "{bad}"));
      props.add(MapItemPropItem(
          "", "font_error_size", "Font Error Size", "font_size", "20"));
      groups.add(MapItemPropGroup("Text", true, props));
    }
    return groups;
  }

  @override
  void tick() {}

  @override
  void resetToEndOfAnimation() {}
}
