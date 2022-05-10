import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as dart_ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gazer_client/core/protocol/dataitem/data_item_list.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/tools/calc_preffered_scale.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_decorations/map_item_decoration_rect_01.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_decorations/map_item_decoration_set.dart';

import '../map_item.dart';

class MapItemUnitTable01 extends MapItem {
  static const String sType = "unit.table.01";
  static const String sName = "Unit.Table.01";
  @override
  String type() {
    return sType;
  }

  double targetValue = 0.0;
  double lastValue = 0.0;
  double aniCounter = 0.0;

  MapItemUnitTable01(Connection connection) : super(connection) {
    setDouble("font_size", 20);
  }

  @override
  void setDefaultsForItem() {
    postDecorations = MapItemDecorationList([]);
    {
      var decoration = MapItemDecorationRect01();
      decoration.initDefaultProperties();
      postDecorations.items.add(decoration);
    }
    setDouble("w", 200);
    setDouble("h", 200);
  }

  bool isDemo = false;

  // Data Items
  bool dataItemsLoaded = false;
  bool dataItemsLoading = false;
  List<String> dataItems = [];

  String unitDisplayName = "";

  void loadDataItems() {
    if (dataItemsLoading) {
      return;
    }
    dataItemsLoaded = true;
    dataItemsLoading = true;
    Repository().client(connection).unitItemsValues(getDataSource()).then((value) {
      for (var di in value.items) {
        if (di.name.contains("/.service")) {
          continue;
        }
        dataItems.add(di.name);
      }
      dataItemsLoaded = true;
      dataItemsLoading = false;
    }).catchError((e) {
      dataItemsLoading = false;
    });
  }

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    if (!dataItemsLoaded) {
      loadDataItems();
    }

    drawPre(canvas, size);

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(getDoubleZ("x"), getDoubleZ("y"), getDoubleZ("w"), getDoubleZ("h") * aniCounter));

    Map<String, DataItemInfo> values = {};
    for (var itemName in dataItems) {
      var val = Repository().history.value(connection, itemName);
      values[itemName] = val;

      if (unitDisplayName.isEmpty) {
        int indexOfSlash = val.displayName.indexOf("/");
        if (indexOfSlash > -1) {
          unitDisplayName = val.displayName.substring(0, indexOfSlash);
        }
      }
    }

    targetValue = getDoubleZWithThresholds("font_size");
    var fontSizeScaled = targetValue;
    var fontSize = getDoubleWithThresholds("font_size");

    if (isDemo) {}

    var padding = z(10);

    double yOffset = padding;
    Size textSize = const Size(0, 0);

    textSize = drawText(canvas, getDoubleZ("x") + padding, getDoubleZ("y") + yOffset, getDoubleZ("w") - padding * 2, getDoubleZ("h"), unitDisplayName,
        fontSizeScaled * 2, getColorWithThresholds("name_color"), TextAlign.left);
    yOffset += textSize.height;

    var lineHeight = z(2);

    yOffset += lineHeight;
    yOffset += lineHeight;

    canvas.drawLine(Offset(getDoubleZ("x") + padding, getDoubleZ("y") + yOffset), Offset(getDoubleZ("x") + getDoubleZ("w") - padding, getDoubleZ("y") + yOffset), Paint()
        ..strokeWidth = lineHeight
        ..color = getColorWithThresholds("name_color")
    );

    yOffset += lineHeight;
    yOffset += lineHeight;

    for (var di in dataItems) {
      if (values.containsKey(di)) {
        var value = values[di];
        if (value != null) {
          var itemName = "";

          int indexOfSlash = value.displayName.indexOf("/");
          if (indexOfSlash > -1) {
            itemName = value.displayName.substring(indexOfSlash + 1);
          }

          textSize = measureText(canvas, getDoubleZ("x") + padding, getDoubleZ("y") + yOffset, getDoubleZ("w") - padding * 2, getDoubleZ("h"), itemName,
              fontSize, getColorWithThresholds("name_color"), TextAlign.left);

          drawText(canvas, getDoubleZ("x") + padding, getDoubleZ("y") + yOffset, getDoubleZ("w") - padding * 2, getDoubleZ("h"), itemName,
              fontSizeScaled, getColorWithThresholds("name_color"), TextAlign.left);


          var uomSize = drawValueAndUOM(canvas, getDoubleZ("x") + padding, getDoubleZ("y") + yOffset, getDoubleZ("w") - padding * 2, getDoubleZ("h"), value.value, value.uom,
              fontSizeScaled, getColorWithThresholds("text_color"), getColorWithThresholds("uom_color"), TextAlign.right);

          var valLineOffsetY = z(textSize.height) / 2;
          /*canvas.drawLine(Offset(getDoubleZ("x") + padding * 2 + textSize.width, getDoubleZ("y") + yOffset + valLineOffsetY), Offset(getDoubleZ("x") + getDoubleZ("w") - padding * 2 - uomSize.width, getDoubleZ("y") + yOffset + valLineOffsetY), Paint()
            ..strokeWidth = z(0.3)
            ..color = getColorWithThresholds("name_color")
          );*/
          valLineOffsetY = z(textSize.height);
          canvas.drawLine(Offset(getDoubleZ("x") + padding , getDoubleZ("y") + yOffset + valLineOffsetY), Offset(getDoubleZ("x") + getDoubleZ("w") - padding, getDoubleZ("y") + yOffset + valLineOffsetY), Paint()
            ..strokeWidth = z(0.3)
            ..color = getColorWithThresholds("name_color")
          );
        }
      }

      yOffset += z(textSize.height);
    }

    canvas.restore();

    drawPost(canvas, size);
  }

  Size drawValueAndUOM(Canvas canvas, double x, double y, double width, double height, String value, String uom, double size, Color colorValue, Color colorUOM,
      TextAlign align) {
    var textSpan = TextSpan(children: [
      TextSpan(
        text: value + " ",
        style: TextStyle(
          color: colorValue,
          fontSize: size,
          height: 1.1,
        ),
      ),
      TextSpan(
        text: uom,
        style: TextStyle(
          color: colorUOM,
          fontSize: size,
          height: 1.1,
        ),
      ),
    ]);
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: align);
    textPainter.layout(
      minWidth: width,
      maxWidth: width,
    );
    textPainter.paint(canvas, Offset(x, y));
    return Size(textPainter.maxIntrinsicWidth, textPainter.height);
  }

  Size drawText(Canvas canvas, double x, double y, double width, double height, String text, double size, Color color, TextAlign align) {
    canvas.save();

    //Size res = const Size(0, 0);
    var textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
        height: 1.2,
      ),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: align);
    textPainter.layout(
      minWidth: width,
      maxWidth: width,
    );
    textPainter.paint(canvas, Offset(x, y));
    canvas.restore();

    return Size(textPainter.maxIntrinsicWidth, textPainter.height);
  }

  Size measureText(Canvas canvas, double x, double y, double width, double height, String text, double size, Color color, TextAlign align) {
    var textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
        height: 1.2,
      ),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: align, maxLines: 1);
    textPainter.layout(
      minWidth: width,
      maxWidth: width,
    );

    return Size(textPainter.maxIntrinsicWidth, textPainter.height);
  }

  @override
  void drawDemo(Canvas canvas, Size size) {
    setDefaultsForItem();
    canvas.drawRect(
        Rect.fromLTWH(0, 0, getDoubleZ("w"), getDoubleZ("h")),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.teal
          ..strokeWidth = 2);
    isDemo = true;
    draw(canvas, size, []);
  }

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "name_color", "Item Name Color", "color", "FF00BCD4"));
      props.add(MapItemPropItem("", "text_color", "Text Color", "color", "FF19EE46"));
      props.add(MapItemPropItem("", "uom_color", "UOM Color", "color", "FF009688"));
      props.add(MapItemPropItem("", "font_size", "Font Size", "double", "12"));
      groups.add(MapItemPropGroup("Text", true, props));
    }
    return groups;
  }

  @override
  List<MapItemPropItem> propThresholdOfItem() {
    List<MapItemPropItem> props = [];
    props.add(MapItemPropItem("", "name_color", "Item Name Color", "color", "FF00BCD4"));
    props.add(MapItemPropItem("", "text_color", "Text Color", "color", "FF19EE46"));
    props.add(MapItemPropItem("", "uom_color", "UOM Color", "color", "FF009688"));
    props.add(MapItemPropItem("", "font_size", "Font Size", "double", "12"));
    return props;
  }

  @override
  void tick() {
    {
      var diff = targetValue - lastValue;
      lastValue += diff / 2;
      if ((lastValue - targetValue).abs() < 0.1) {
        lastValue = targetValue;
      }
    }
    {
      aniCounter += 0.03;
      if (aniCounter > 1) {
        aniCounter = 1;
      }
    }
  }

  @override
  void resetToEndOfAnimation() {
    targetValue = getDoubleZ("font_size");
    lastValue = targetValue;
  }
}
