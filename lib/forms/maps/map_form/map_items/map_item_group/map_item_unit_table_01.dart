import 'package:flutter/material.dart';
import 'package:gazer_client/core/protocol/dataitem/data_item_list.dart';
import 'package:gazer_client/core/protocol/unit/unit_items_values.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import '../../../utils/draw_text.dart';
import '../../main/map_item.dart';

class MapItemUnitTable01 extends MapItem {
  static const String sType = "unit.table.01";
  static const String sName = "Unit.Table.01";
  @override
  String type() {
    return sType;
  }

  MapItemUnitTable01(Connection connection) : super(connection) {
    setDouble("font_size", 20);
  }

  @override
  void setDefaultsForItem() {
    setDouble("w", 200);
    setDouble("h", 200);
  }

  bool isDemo = false;

  // Data Items
  bool dataItemsLoaded = false;
  bool dataItemsLoading = false;
  List<String> dataItems = [];

  String unitDisplayName = "";

  String lastDataSource = "";

  void reloadItems() {
    dataItemsLoaded = false;
    dataItemsLoading = false;
    dataItems = [];
    unitDisplayName = "";
  }

  void loadDataItems() {
    if (dataItemsLoading) {
      return;
    }
    dataItemsLoaded = true;
    dataItemsLoading = true;
    Repository()
        .client(connection)
        .unitItemsValues(getDataSource())
        .then((value) {
      value.items.sort((a, b) {
        return a.name.compareTo(b.name);
      });
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
    if (lastDataSource != getDataSource()) {
      lastDataSource = getDataSource();
      reloadItems();
    }

    var fontSize = getDoubleZ("font_size");
    var fontFamily = get("font_family");
    int? fontWeightN = int.tryParse(get("font_weight"));
    int fontWeight = 400;
    if (fontWeightN != null) {
      fontWeight = fontWeightN;
    }

    if (!dataItemsLoaded && !isDemo) {
      loadDataItems();
    }

    Map<String, DataItemInfo> values = {};
    if (isDemo) {
      unitDisplayName = "Unit";
      dataItems = [];
      dataItems.add("u0/item1");
      dataItems.add("u0/item2");
      dataItems.add("u0/item3");

      values["u0/item1"] =
          DataItemInfo(0, "u0/item1", "u0/item1", "42.0", 0, "uom");
      values["u0/item2"] =
          DataItemInfo(0, "u0/item2", "u0/item2", "142.0", 0, "uom");
      values["u0/item3"] =
          DataItemInfo(0, "u0/item3", "u0/item3", "242.0", 0, "uom");
    }

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(
        getDoubleZ("x"), getDoubleZ("y"), getDoubleZ("w"), getDoubleZ("h")));

    drawPre(canvas, size);

    if (!isDemo) {
      for (var itemName in dataItems) {
        var val = Repository().history.getNode(connection).value(itemName);
        values[itemName] = val;

        if (unitDisplayName.isEmpty) {
          int indexOfSlash = val.displayName.indexOf("/");
          if (indexOfSlash > -1) {
            unitDisplayName = val.displayName.substring(0, indexOfSlash);
          }
        }
      }
    }

    if (isDemo) {}

    var padding = z(10);

    double yOffset = padding;
    Size textSize = const Size(0, 0);

    textSize = drawText(
      canvas,
      getDoubleZ("x") + padding,
      getDoubleZ("y") + yOffset,
      getDoubleZ("w") - padding * 2,
      getDoubleZ("h"),
      unitDisplayName,
      fontSize * 2,
      getColor("name_color"),
      TextVAlign.top,
      TextAlign.left,
      fontFamily,
      fontWeight,
    );
    yOffset += textSize.height;

    var lineHeight = z(2);

    yOffset += lineHeight;
    yOffset += lineHeight;

    canvas.drawLine(
        Offset(getDoubleZ("x") + padding, getDoubleZ("y") + yOffset),
        Offset(getDoubleZ("x") + getDoubleZ("w") - padding,
            getDoubleZ("y") + yOffset),
        Paint()
          ..strokeWidth = lineHeight
          ..color = getColor("name_color"));

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

          textSize = measureText(
              canvas,
              getDoubleZ("x") + padding,
              getDoubleZ("y") + yOffset,
              getDoubleZ("w") - padding * 2,
              getDoubleZ("h"),
              itemName,
              getDouble("font_size"),
              getColor("name_color"),
              TextAlign.left,
              fontFamily,
              fontWeight);

          drawText(
            canvas,
            getDoubleZ("x") + padding,
            getDoubleZ("y") + yOffset,
            getDoubleZ("w") - padding * 2,
            getDoubleZ("h"),
            itemName,
            fontSize,
            getColor("name_color"),
            TextVAlign.top,
            TextAlign.left,
            fontFamily,
            fontWeight,
          );

          drawValueAndUOM(
              canvas,
              getDoubleZ("x") + padding,
              getDoubleZ("y") + yOffset,
              getDoubleZ("w") - padding * 2,
              getDoubleZ("h"),
              value.value,
              value.uom,
              fontSize,
              getColor("text_color"),
              getColor("uom_color"),
              TextAlign.right,
              fontFamily,
              fontWeight);

          var valLineOffsetY = z(textSize.height) / 2;
          valLineOffsetY = z(textSize.height);
          canvas.drawLine(
              Offset(getDoubleZ("x") + padding,
                  getDoubleZ("y") + yOffset + valLineOffsetY),
              Offset(getDoubleZ("x") + getDoubleZ("w") - padding,
                  getDoubleZ("y") + yOffset + valLineOffsetY),
              Paint()
                ..strokeWidth = z(0.3)
                ..color = getColor("name_color"));
        }
      }

      yOffset += z(textSize.height);
    }

    canvas.restore();

    drawPost(canvas, size);
  }

  Size drawValueAndUOM(
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
          height: 1.1,
        ),
      ),
      TextSpan(
        text: uom,
        style: TextStyle(
          color: colorUOM,
          fontSize: size,
          fontFamily: fontFamily,
          fontWeight: intToFontWeight(fontWeight),
          height: 1.1,
        ),
      ),
    ]);
    final textPainter = TextPainter(
        text: textSpan, textDirection: TextDirection.ltr, textAlign: align);
    textPainter.layout(
      minWidth: width,
      maxWidth: width,
    );
    textPainter.paint(canvas, Offset(x, y));
    return Size(textPainter.maxIntrinsicWidth, textPainter.height);
  }

  Size measureText(
      Canvas canvas,
      double x,
      double y,
      double width,
      double height,
      String text,
      double size,
      Color color,
      TextAlign align,
      String? fontFamily,
      int fontWeight) {
    var textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
        height: 1.2,
        fontFamily: fontFamily,
        fontWeight: intToFontWeight(fontWeight),
      ),
    );
    final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: align,
        maxLines: 1);
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
    groups.addAll(super.propGroupsOfItem());
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem(
          "", "data_source", "Data Source Item", "data_source", ""));
      groups.add(MapItemPropGroup("Data Source", true, props));
    }

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
