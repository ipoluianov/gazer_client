import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as dart_ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/tools/calc_preffered_scale.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import '../../../../utils/draw_text.dart';
import '../../../main/map_item.dart';
import '../map_item_single.dart';

class MapItemText02 extends MapItemSingle {
  static const String sType = "text.02";
  static const String sName = "Text.02";
  @override
  String type() {
    return sType;
  }

  MapItemText02(Connection connection) : super(connection) {
    setDouble("font_size", 20);
  }

  @override
  void setDefaultsForItem() {
    setDouble("w", 200);
    setDouble("h", 40);
  }

  bool isDemo = false;

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    drawPre(canvas, size);
    var itemName = "";
    var text = "";
    var uom = "";

    var fontSize = getDoubleZ("font_size");
    var fontFamily = get("font_family");
    int? fontWeightN = int.tryParse(get("font_weight"));
    int fontWeight = 400;
    if (fontWeightN != null) {
      fontWeight = fontWeightN;
    }

    if (hasDataSource()) {
      var value = dataSourceValue();
      itemName = value.displayName;
      text = value.value;
      uom = value.uom;
    }

    if (isDemo) {
      itemName = "Name";
      text = "Value";
      uom = "";
    }

    var padding = z(10);

    drawText(
      canvas,
      getDoubleZ("x") + padding,
      getDoubleZ("y"),
      getDoubleZ("w") - padding * 2,
      getDoubleZ("h"),
      itemName,
      fontSize,
      getColor("name_color"),
      TextVAlign.middle,
      TextAlign.left,
      fontFamily,
      fontWeight,
    );

    drawValueAndUOM(
        canvas,
        getDoubleZ("x") + padding,
        getDoubleZ("y"),
        getDoubleZ("w") - padding * 2,
        getDoubleZ("h"),
        text,
        uom,
        fontSize,
        getColor("text_color"),
        getColor("uom_color"),
        TextAlign.right,
        fontFamily,
        fontWeight);
    drawPost(canvas, size);
  }

  void drawValueAndUOM(
      Canvas canvas,
      double x,
      double y,
      double width,
      double height,
      String value,
      String uom,
      double size,
      Color colorValue,
      Color colorUOM,
      TextAlign align,
      String fontFamily,
      int fontWeight) {
    var textSpan = TextSpan(children: [
      TextSpan(
        text: value + " ",
        style: TextStyle(
          color: colorValue,
          fontSize: size,
          fontFamily: fontFamily,
          fontWeight: intToFontWeight(fontWeight),
        ),
      ),
      TextSpan(
        text: uom,
        style: TextStyle(
          color: colorUOM,
          fontSize: size,
          fontFamily: fontFamily,
          fontWeight: intToFontWeight(fontWeight),
        ),
      ),
    ]);
    final textPainter = TextPainter(
        text: textSpan, textDirection: TextDirection.ltr, textAlign: align);
    textPainter.layout(
      minWidth: width,
      maxWidth: width,
    );
    textPainter.paint(
        canvas, Offset(x, y + (height / 2) - (textPainter.height / 2)));
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
    groups.addAll(super.propGroupsOfItem());
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem(
          "", "name_color", "Item Name Color", "color", "{fore}"));
      props.add(
          MapItemPropItem("", "text_color", "Text Color", "color", "{good}"));
      props.add(
          MapItemPropItem("", "uom_color", "UOM Color", "color", "{fore1}"));
      props.add(MapItemPropItem(
          "", "font_family", "Font Family", "font_family", "Roboto"));
      props.add(
          MapItemPropItem("", "font_size", "Font Size", "font_size", "20"));
      props.add(MapItemPropItem(
          "", "font_weight", "Font Weight", "font_weight", "400"));
      groups.add(MapItemPropGroup("Text", true, props));
    }
    groups.add(borderGroup());
    groups.add(backgroundGroup());

    return groups;
  }

  @override
  void tick() {}

  @override
  void resetToEndOfAnimation() {}
}
