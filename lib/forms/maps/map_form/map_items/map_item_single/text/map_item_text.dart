import 'package:flutter/material.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/maps/map_form/map_items/map_item_single/map_item_single.dart';

import '../../../../utils/draw_text.dart';
import '../../../main/map_item.dart';

class MapItemText extends MapItemSingle {
  static const String sType = "text.01";
  static const String sName = "Text.01";
  @override
  String type() {
    return sType;
  }

  //double realValue = 0.0;
  //double targetValue = 0.0;
  //double lastValue = 0.0;
  //double aniCounter = 0.0;

  bool isReplacer = false;
  String replaceType = "";

  MapItemText(Connection connection) : super(connection) {
    setDouble("font_size", 20);
  }

  @override
  void setDefaultsForItem() {
    //super.setDefaults();
    setDouble("w", 200);
    setDouble("h", 40);
  }

  void drawReplacer(Canvas canvas, Size size, List<String> parentMaps) {
    canvas.drawRect(
        Rect.fromLTWH(getDoubleZ("x"), getDoubleZ("y"), getDoubleZ("w"), z(60)),
        Paint()
          ..color = Colors.black54
          ..style = PaintingStyle.fill);
    drawText(
      canvas,
      getDoubleZ("x"),
      getDoubleZ("y"),
      getDoubleZ("w"),
      z(60),
      "replaced by a text element\r\nplease update your software\r\n[$replaceType]",
      z(14),
      Colors.red,
      TextVAlign.middle,
      TextAlign.center,
      null,
      400,
    );
  }

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    drawPre(canvas, size);

    var text = get("text");
    var prefix = get("prefix");
    var suffix = get("suffix");

    if (hasDataSource()) {
      var value = dataSourceValue();
      text = value.value;
    }

    text = prefix + text + suffix;
    text = text.replaceAll("[nl]", "\n");
    text = text.replaceAll("[name]", dataSourceValue().displayName);
    text = text.replaceAll("[uom]", dataSourceValue().uom);

    if (isReplacer) {
      drawReplacer(canvas, size, parentMaps);
    }

    var txtProps = getTextAppearance(this);

    drawText(
      canvas,
      getDoubleZ("x"),
      getDoubleZ("y"),
      getDoubleZ("w"),
      getDoubleZ("h"),
      text,
      txtProps.fontSize,
      txtProps.textColor,
      TextVAlign.middle,
      txtProps.hAlign,
      txtProps.fontFamily,
      txtProps.fontWeight,
    );
    drawPost(canvas, size);
  }

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    groups.addAll(super.propGroupsOfItem());
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "text", "Text", "text", "Text"));
      props.add(MapItemPropItem("", "prefix", "Prefix", "text", ""));
      props.add(MapItemPropItem("", "suffix", "Suffix", "text", ""));
      groups.add(MapItemPropGroup("Text", true, props));
    }
    groups.add(textAppearanceGroup());
    groups.add(borderGroup());
    groups.add(backgroundGroup());
    return groups;
  }

  @override
  void tick() {}

  @override
  void resetToEndOfAnimation() {}
}
