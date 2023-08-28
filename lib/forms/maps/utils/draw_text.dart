import 'dart:ui';

import 'package:flutter/material.dart';

import '../map_form/main/map_item.dart';

FontWeight intToFontWeight(int fontWeight) {
  FontWeight result = FontWeight.w400;
  switch (fontWeight) {
    case 100:
      result = FontWeight.w100;
      break;
    case 200:
      result = FontWeight.w200;
      break;
    case 300:
      result = FontWeight.w300;
      break;
    case 400:
      result = FontWeight.w400;
      break;
    case 500:
      result = FontWeight.w500;
      break;
    case 600:
      result = FontWeight.w600;
      break;
    case 700:
      result = FontWeight.w700;
      break;
    case 800:
      result = FontWeight.w800;
      break;
    case 900:
      result = FontWeight.w900;
      break;
  }

  return result;
}

Size drawText(
  Canvas canvas,
  double x,
  double y,
  double width,
  double height,
  String text,
  double size,
  Color color,
  TextVAlign vAlign,
  TextAlign align,
  String? fontFamily,
  int fontWeight,
) {
  if (fontWeight < 1) {
    fontWeight = 400;
  }

  canvas.save();
  var textSpan = TextSpan(
    text: text,
    style: TextStyle(
        color: color,
        fontSize: size,
        fontFamily: fontFamily,
        fontWeight: intToFontWeight(fontWeight)),
  );
  final textPainter = TextPainter(
      text: textSpan, textDirection: TextDirection.ltr, textAlign: align);
  textPainter.layout(
    minWidth: width,
    maxWidth: width,
  );
  double yOffset = y;
  if (vAlign == TextVAlign.middle) {
    yOffset = y + (height / 2) - (textPainter.height / 2);
  }
  if (vAlign == TextVAlign.bottom) {
    yOffset = y + (height - textPainter.height);
  }
  textPainter.paint(canvas, Offset(x, yOffset));
  canvas.restore();
  return Size(textPainter.maxIntrinsicWidth, textPainter.height);
}

enum TextVAlign {
  top,
  middle,
  bottom,
}

MapItemPropGroup textAppearanceGroup(
    {textColorDefault = "{fore}",
    halign = "center",
    fontFamily = "Roboto",
    fontSize = "20"}) {
  List<MapItemPropItem> props = [];
  props.add(MapItemPropItem(
      "", "font_family", "Font Family", "font_family", fontFamily));
  props.add(
      MapItemPropItem("", "font_size", "Font Size", "font_size", fontSize));
  props.add(
      MapItemPropItem("", "font_weight", "Font Weight", "font_weight", "400"));
  props.add(MapItemPropItem(
      "", "text_color", "Text Color", "color", textColorDefault));
  props.add(MapItemPropItem("", "h_align", "Hor Align", "halign", halign));
  return MapItemPropGroup("Text Appearance", false, props);
}

MapItemPropGroup borderGroup({borderWidthDefault}) {
  borderWidthDefault ??= "1";
  List<MapItemPropItem> props = [];
  props.add(
      MapItemPropItem("", "border_color", "Border Color", "color", "{fore}"));
  props.add(MapItemPropItem(
      "", "border_width", "Border Width", "double", borderWidthDefault));
  props.add(MapItemPropItem(
      "", "border_corner_radius", "Border Corner Radius", "double", "0"));
  return MapItemPropGroup("Border", false, props);
}

MapItemPropGroup backgroundGroup() {
  List<MapItemPropItem> props = [];
  props.add(MapItemPropItem(
      "", "back_color", "Background Color", "color", "00000000"));
  props.add(MapItemPropItem("", "back_img", "Background Image", "image", ""));
  props.add(MapItemPropItem("", "back_img_scale_fit",
      "Background Image Scale Fit", "scale_fit", "contain"));
  props.add(
      MapItemPropItem("", "grid_color", "Grid Color", "color", "00000000"));
  props.add(MapItemPropItem("", "grid_size", "Grid Size", "double", "0"));
  return MapItemPropGroup("Background", false, props);
}

class TextAppearance {
  String fontFamily;
  double fontSize;
  int fontWeight;
  Color textColor;
  TextAlign hAlign;
  TextAppearance(this.fontFamily, this.fontSize, this.fontWeight,
      this.textColor, this.hAlign);
}

TextAppearance getTextAppearance(MapItem mapItem) {
  var hAlign = mapItem.getTextAlign("h_align");
  var fontSize = mapItem.getDoubleZ("font_size");
  var fontFamily = mapItem.get("font_family");
  int? fontWeightN = int.tryParse(mapItem.get("font_weight"));
  int fontWeight = 400;
  if (fontWeightN != null) {
    fontWeight = fontWeightN;
  }
  var textColor = mapItem.getColor("text_color");
  return TextAppearance(fontFamily, fontSize, fontWeight, textColor, hAlign);
}
