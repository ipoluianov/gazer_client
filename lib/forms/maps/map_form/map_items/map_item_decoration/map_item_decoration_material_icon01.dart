import 'package:flutter/material.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/maps/map_form/map_items/map_item_single/map_item_single.dart';
import 'package:gazer_client/forms/maps/utils/material_icons.dart';

import '../../../../../core/design.dart';
import '../../../utils/draw_text.dart';
import '../../main/map_item.dart';

class MapItemDecorationMaterialIcon01 extends MapItemSingle {
  static const String sType = "decoration.material_icon.01";
  static const String sName = "Decoration.material_icon.01";
  @override
  String type() {
    return sType;
  }

  MapItemDecorationMaterialIcon01(Connection connection) : super(connection) {}

  @override
  void setDefaultsForItem() {
    setDouble("w", 200);
    setDouble("h", 200);
  }

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    drawPre(canvas, size);

    double minSize = getDouble("w");
    if (getDouble("h") < minSize) {
      minSize = getDouble("h");
    }

    Color color = getColor("decor_color");

    canvas.save();

    IconData icon = MaterialIconsLib().getIconByName(get("icon_name"));
    drawText(
      canvas,
      getDoubleZ("x"),
      getDoubleZ("y"),
      getDoubleZ("w"),
      getDoubleZ("h"),
      String.fromCharCode(icon.codePoint),
      z(minSize),
      color,
      TextVAlign.middle,
      TextAlign.center,
      icon.fontFamily,
      400,
    );

    canvas.restore();

    drawPost(canvas, size);
  }

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    //groups.addAll(super.propGroupsOfItem());
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "icon_name", "Icon Name", "text", "add"));
      props.add(
          MapItemPropItem("", "decor_color", "Color", "color", "FF00EFFF"));
      groups.add(MapItemPropGroup("Decoration", true, props));
    }
    groups.add(borderGroup(borderWidthDefault: "0"));
    groups.add(backgroundGroup());
    return groups;
  }

  @override
  void tick() {}

  @override
  void resetToEndOfAnimation() {}
}
