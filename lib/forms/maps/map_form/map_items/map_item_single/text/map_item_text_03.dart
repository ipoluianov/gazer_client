import 'package:flutter/material.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/maps/map_form/map_items/map_item_single/map_item_single.dart';

import '../../../../utils/draw_text.dart';
import '../../../main/map_item.dart';

class MapItemText03 extends MapItemSingle {
  static const String sType = "text.03";
  static const String sName = "Text.03";
  @override
  String type() {
    return sType;
  }

  MapItemText03(Connection connection) : super(connection) {
    setDouble("font_size", 16);
  }

  @override
  void setDefaultsForItem() {
    //super.setDefaults();
    setDouble("w", 200);
    setDouble("h", 40);
  }

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    drawPre(canvas, size);

    var text = get("text");

    if (hasDataSource()) {
      var value = dataSourceValue();
      text = value.value;
    }

    var txtProps = getTextAppearance(this);

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(
        getDoubleZ("x"), getDoubleZ("y"), getDoubleZ("w"), getDoubleZ("h")));
    drawText(
      canvas,
      getDoubleZ("x"),
      getDoubleZ("y"),
      getDoubleZ("w"),
      getDoubleZ("h"),
      text,
      txtProps.fontSize,
      txtProps.textColor,
      TextVAlign.bottom,
      txtProps.hAlign,
      txtProps.fontFamily,
      txtProps.fontWeight,
    );
    canvas.restore();
    drawPost(canvas, size);
  }

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    groups.addAll(super.propGroupsOfItem());
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "text", "Text", "text", "Text"));
      groups.add(MapItemPropGroup("Text", true, props));
    }
    groups.add(textAppearanceGroup(
        halign: "left", fontFamily: "RobotoMono", fontSize: "14"));
    groups.add(borderGroup());
    groups.add(backgroundGroup());
    return groups;
  }

  @override
  void tick() {}

  @override
  void resetToEndOfAnimation() {}
}
