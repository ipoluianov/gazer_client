import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as dart_ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/protocol/dataitem/data_item_list.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/tools/calc_preffered_scale.dart';
import 'package:gazer_client/core/tools/hex_colors.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/chart_groups/chart_group_form/chart_group_data_items.dart';
import 'package:gazer_client/widgets/confirmation_dialog/confirmation_dialog.dart';

import '../../../../runlang/program.dart';
import 'map_item_library.dart';

abstract class MapItem extends IPropContainer {
  late Map<String, String> props;
  double zoom = 1.0;
  List<MapItem> items = [];
  bool selected = false;
  Connection connection;
  bool isRoot = false;

  String lastBackImageBase64 = "";
  dart_ui.Image? backImage;

  String lastParentDataSource = "";

  MapItem(this.connection) {
    props = {};
    backImage = null;
  }

  late String _id = "";

  @override
  String id() {
    return _id;
  }

  void generateAndSetNewId() {
    Random rnd = Random();
    var intRandom = rnd.nextInt(1000000);
    var dt = DateTime.now().microsecondsSinceEpoch;
    _id = dt.toString() + intRandom.toString();
  }

  double z(double value) {
    return value * zoom;
  }

  void tickItem() {
    tick();
  }

  void tick() {}

  Rect rect() {
    return Rect.fromLTWH(
        getDouble("x"), getDouble("y"), getDouble("w"), getDouble("h"));
  }

  Rect rectZ() {
    return Rect.fromLTWH(
        getDoubleZ("x"), getDoubleZ("y"), getDoubleZ("w"), getDoubleZ("h"));
  }

  Rect rectZWidthOffset(Offset offset) {
    return Rect.fromLTWH(getDoubleZ("x") + offset.dx,
        getDoubleZ("y") + offset.dy, getDoubleZ("w"), getDoubleZ("h"));
  }

  bool needToZoom() {
    return false;
  }

  void draw(Canvas canvas, Size size, List<String> parentMaps);

  double calcPrefScale() {
    return zoom;
  }

  @protected
  void resetToEndOfAnimation() {}

  void drawDemo(Canvas canvas, Size size) {
    setDefaultsForItem();
    drawItem(canvas, size, "", []);
  }

  void drawItem(
      Canvas canvas, Size size, String dataSource, List<String> parentMaps) {
    lastParentDataSource = dataSource;

    var zoomForDecorators = calcPrefScale();

    canvas.save();

    var borderCornerRadius = getDoubleZ("border_corner_radius");
    if (borderCornerRadius > 0) {
      var rRect = RRect.fromRectAndRadius(
          backgroundRect(), Radius.circular(borderCornerRadius));
      canvas.clipRRect(rRect);
    } else {
      if (type() == "map") {
        var rRect =
            RRect.fromRectAndRadius(backgroundRect(), const Radius.circular(0));
        canvas.clipRRect(rRect);
      }
    }

    draw(canvas, size, parentMaps);
    canvas.restore();
  }

  void drawPre(Canvas canvas, Size size, {RRect? rRect}) {
    drawBack(canvas, size, rRect: rRect);
  }

  void drawPost(Canvas canvas, Size size, {RRect? rRect}) {
    rRect ??= RRect.fromRectAndRadius(
        backgroundRect(), Radius.circular(getDoubleZ("border_corner_radius")));

    drawBorders(canvas, size, rRect);
  }

  void drawSelection(Canvas canvas, Size size) {
    if (selected) {
      // draw action points
      var actionPointsList = actionPointsZ();
      Color colorOfSizePoint = Colors.purpleAccent;

      for (var ap in actionPointsList) {
        canvas.drawLine(
            Offset(ap.rect.left, ap.rect.bottom),
            Offset(ap.rect.right, ap.rect.top),
            Paint()
              ..style = PaintingStyle.stroke
              ..color = colorOfSizePoint
              ..isAntiAlias = true
              ..strokeWidth = 1);
        canvas.drawLine(
            Offset(ap.rect.left + ap.rect.width * 0.25, ap.rect.bottom),
            Offset(ap.rect.right, ap.rect.top + ap.rect.width * 0.25),
            Paint()
              ..style = PaintingStyle.stroke
              ..color = colorOfSizePoint
              ..isAntiAlias = true
              ..strokeWidth = 1);
        canvas.drawLine(
            Offset(ap.rect.left + ap.rect.width * 0.5, ap.rect.bottom),
            Offset(ap.rect.right, ap.rect.top + ap.rect.width * 0.5),
            Paint()
              ..style = PaintingStyle.stroke
              ..color = colorOfSizePoint
              ..isAntiAlias = true
              ..strokeWidth = 1);
        canvas.drawLine(
            Offset(ap.rect.left + ap.rect.width * 0.75, ap.rect.bottom),
            Offset(ap.rect.right, ap.rect.top + ap.rect.width * 0.75),
            Paint()
              ..style = PaintingStyle.stroke
              ..color = colorOfSizePoint
              ..isAntiAlias = true
              ..strokeWidth = 1);
      }

      // draw selection
      canvas.drawRect(
          Offset(getDoubleZ("x"), getDoubleZ("y")) &
              Size(getDoubleZ("w"), getDoubleZ("h")),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = Colors.purpleAccent.withOpacity(0.2)
            ..strokeWidth = 9);

      canvas.drawRect(
          Offset(getDoubleZ("x"), getDoubleZ("y")) &
              Size(getDoubleZ("w"), getDoubleZ("h")),
          Paint()
            ..style = PaintingStyle.stroke
            ..color = Colors.purpleAccent
            ..strokeWidth = 1);
    }
  }

  void drawEditingBorders(Canvas canvas, Size size) {
    // draw selection
    canvas.drawRect(
        Offset(getDoubleZ("x"), getDoubleZ("y")) &
            Size(getDoubleZ("w"), getDoubleZ("h")),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.red.withOpacity(0.1)
          ..strokeWidth = 9);

    /*canvas.drawRect(
        Offset(getDoubleZ("x"), getDoubleZ("y")) & Size(getDoubleZ("w"), getDoubleZ("h")),
        Paint()
          ..style = PaintingStyle.stroke
          ..color = Colors.red
          ..strokeWidth = 1);*/
  }

  Future<dart_ui.Image> _loadImage(Uint8List backImageBytes) async {
    return await decodeImageFromList(backImageBytes);
  }

  void drawBack(Canvas canvas, Size size, {RRect? rRect}) {
    var backColor = getColor("back_color");

    var backImageBytesB64 = get("back_img");
    if (lastBackImageBase64 != backImageBytesB64) {
      Uint8List backImageBytes = Uint8List(0);
      if (backImageBytesB64.isNotEmpty) {
        backImageBytes = base64Decode(backImageBytesB64);
        _loadImage(backImageBytes).then((value) {
          backImage = value;
        });
      } else {
        backImage = null;
      }
      lastBackImageBase64 = backImageBytesB64;
    }

    CalcPreferredScaleType scaleFit = CalcPreferredScaleType.contain;
    var calcScaleFitString = get("back_img_scale_fit");
    if (calcScaleFitString == "contain") {
      scaleFit = CalcPreferredScaleType.contain;
    }
    if (calcScaleFitString == "fill") {
      scaleFit = CalcPreferredScaleType.fill;
    }
    if (calcScaleFitString == "cover") {
      scaleFit = CalcPreferredScaleType.cover;
    }

    canvas.save();
    if (rRect != null) {
      canvas.clipRRect(rRect);
      //RRect.fromRectAndRadius();
    }

    if (backImage != null) {
      var backRect = backgroundRect();

      var calcRes = calcPreferredScale(
          Size(backRect.width / zoom, backRect.height / zoom),
          Size(backImage!.width.toDouble(), backImage!.height.toDouble()),
          scaleFit);
      var scaleFactorX = calcRes.scaleX * zoom;
      var scaleFactorY = calcRes.scaleY * zoom;
      var imgOffsetX =
          (getDoubleZ("x") + calcRes.offset.dx * zoom) / scaleFactorX;
      var imgOffsetY =
          (getDoubleZ("y") + calcRes.offset.dy * zoom) / scaleFactorY;
      canvas.save();
      canvas.clipRect(dart_ui.Rect.fromLTWH(
          getDoubleZ("x"), getDoubleZ("y"), getDoubleZ("w"), getDoubleZ("h")));
      canvas.scale(scaleFactorX, scaleFactorY);
      canvas.drawImage(backImage!, Offset(imgOffsetX, imgOffsetY), Paint());
      canvas.restore();
    }

    if (backColor.alpha > 0) {
      canvas.drawRect(
          backgroundRect(),
          Paint()
            ..style = PaintingStyle.fill
            ..color = backColor);
    }

    canvas.restore();
  }

  void setDefaults() {
    setDefaultsForItem();
  }

  void setDefaultsForItem() {}

  Rect backgroundRect() {
    return Offset(getDoubleZ("x"), getDoubleZ("y")) &
        Size(getDoubleZ("w"), getDoubleZ("h"));
  }

  void drawBorders(Canvas canvas, Size size, RRect? rRect) {
    if (rRect != null) {
      var borderColor = getColor("border_color");
      var borderWidth = getDouble("border_width");
      var borderCornerRadius = getDouble("border_corner_radius");
      if (borderCornerRadius > 0) {
        rRect = RRect.fromRectAndRadius(
            Rect.fromLTWH(rRect.left, rRect.top, rRect.width, rRect.height),
            Radius.circular(rRect.blRadiusX));
      }
      if (borderWidth > 0) {
        canvas.drawRRect(
            rRect,
            //Offset(getDoubleZ("x"), getDoubleZ("y")) & Size(getDoubleZ("w"), getDoubleZ("h")),
            Paint()
              ..style = PaintingStyle.stroke
              ..color = borderColor
              ..strokeWidth = z(borderWidth));
      }
    }
  }

  @override
  void set(String name, String value) {
    props[name] = value;
  }

  @override
  String get(String name) {
    if (props.containsKey(name)) {
      if (props[name] == null) {
        return "";
      }
      return props[name]!;
    }
    return "";
  }

  @override
  void setDouble(String name, double value) {
    props[name] = value.toString();
  }

  double getDouble(String name) {
    var val = get(name);
    if (val != "") {
      double? res = double.tryParse(val);
      if (res != null) {
        return res;
      }
      return 0;
    }
    return 0;
  }

  bool getBool(String name) {
    var val = get(name);
    return val == "1";
  }

  Color getColor(String name) {
    var val = get(name);
    if (val != "") {
      return colorFromHex(val);
    }
    return Colors.transparent;
  }

  double getDoubleZ(String name) {
    var val = get(name);
    if (val != "") {
      double? res = double.tryParse(val);
      if (res != null) {
        return res * zoom;
      }
      return 0;
    }
    return 0;
  }

  factory MapItem.fromJson(Map<String, dynamic> json, Connection connection) {
    MapItem item = MapItemsLibrary().makeItemByType(json['type'], connection);
    //print("3333 ${item.type()}");

    for (var key in json.keys) {
      if (key != "children" && json[key] is String) {
        item.set(key, json[key]);
      }
    }

    var children = json['children'];
    for (var ch in children) {
      item.items.add(MapItem.fromJson(ch, connection));
    }

    return item;
  }

  Set<String> childMapProperties() {
    return {
      "x",
      "y",
      "w",
      "h",
      "resource_id",
      "s1_resource_id",
      "s1_width",
      "data_source",
    };
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {};
    result['type'] = type();
    for (var propKey in props.keys) {
      bool needToSave = true;
      if (!isRoot) {
        if (type() == "map") {
          var allowedProperties = childMapProperties();
          if (!allowedProperties.contains(propKey)) {
            needToSave = false;
          }
        }
      }
      if (needToSave) {
        result[propKey] = props[propKey];
      }
    }

    List<Map<String, dynamic>> children = [];
    if (isRoot) {
      for (var ch in items) {
        var chRes = ch.toJson();
        children.add(chRes);
      }
    }
    result["children"] = children;

    return result;
  }

  String type() {
    return "unknown";
  }

  @protected
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    return groups;
  }

  String getDataSource() {
    var ds = get("data_source");
    if (ds.startsWith("~")) {
      if (lastParentDataSource.isNotEmpty) {
        ds = ds.replaceFirst("~", lastParentDataSource);
      }
    }
    return ds;
  }

  DataItemInfo dataSourceValue() {
    String ds = getDataSource();
    if (ds == "") {
      return DataItemInfo.makeDefault();
    }

    return Repository().itemsWatcher.value(connection, ds);
  }

  DataItemInfo itemValue(String name) {
    return Repository().itemsWatcher.value(connection, name);
  }

  bool hasDataSource() {
    return get("data_source") != "";
  }

  bool hasAction() {
    return get("action_on_click_write_data_item").isNotEmpty;
  }

  void onTapDown(BuildContext context) {
    {
      var onClickWriteDataItem = get("action_on_click_write_data_item");
      var onClickWriteValue = get("action_on_click_write_value");
      var onClickWriteConfirmation = getBool("action_on_click_confirmation");
      var onClickWriteConfirmationText =
          get("action_on_click_confirmation_text");

      if (onClickWriteDataItem.isNotEmpty) {
        if (onClickWriteConfirmation) {
          showConfirmationDialog(
              context, "Confirmation", onClickWriteConfirmationText, () {
            Repository()
                .client(connection)
                .dataItemWrite(onClickWriteDataItem, onClickWriteValue);
          });
        } else {
          Repository()
              .client(connection)
              .dataItemWrite(onClickWriteDataItem, onClickWriteValue);
        }
      }
    }

    onTapDownForItem();
  }

  void onTapUp(BuildContext context) {
    onTapUpForItem();
  }

  void onTapDownForItem() {}

  void onTapUpForItem() {}
  void initDefaultProperties() {
    for (var itemPropPage in propList()) {
      for (var itemPropGroup in itemPropPage.groups) {
        for (var itemProp in itemPropGroup.props) {
          set(itemProp.name, itemProp.defaultValue);
        }
      }
    }
  }

  List<MapItemPropItem> propListForInnerMap() {
    List<MapItemPropItem> props = [];
    props.add(MapItemPropItem("", "x", "X", "double", "0"));
    props.add(MapItemPropItem("", "y", "Y", "double", "0"));
    props.add(MapItemPropItem("", "w", "Width", "double", "200"));
    props.add(MapItemPropItem("", "h", "Height", "double", "200"));
    props.add(MapItemPropItem("", "resource_id", "Resource", "text", ""));
    props.add(
        MapItemPropItem("", "s1_resource_id", "Mini Resource", "text", ""));
    props.add(MapItemPropItem(
        "", "s1_width", "Mini Resource Width", "double", "200"));
    props.add(MapItemPropItem(
        "", "data_source", "Data Source Item", "data_source", ""));
    return props;
  }

  @override
  List<MapItemPropPage> propList() {
    //List<MapItemPropPage> pages = [];
    MapItemPropPage pageMain =
        MapItemPropPage("Main", const Icon(Icons.domain), []);

    MapItemPropPage pageDataItems =
        MapItemPropPage("Data Items", const Icon(Icons.data_usage), []);
    pageDataItems.widget = ChartGroupDataItems(connection);

    pageMain.groups.addAll(propGroupsOfItem());

    if (type() == "map") {
      {
        List<MapItemPropItem> props = [];
        if (isRoot) {
          props.add(MapItemPropItem("", "w", "Width", "double", "950"));
          props.add(MapItemPropItem("", "h", "Height", "double", "500"));
          /*props.add(MapItemPropItem("", "back_color", "Background Color", "color", "000000"));
          props.add(MapItemPropItem("", "back_img", "Background Image", "image", ""));
          props.add(MapItemPropItem("", "back_img_scale_fit", "Background Image Scale Fit", "scale_fit", "contain"));
          props.add(MapItemPropItem("", "border_corner_radius", "Border Corner Radius", "double", "0"));*/
        } else {
          props.addAll(propListForInnerMap());
        }
        pageMain.groups.add(MapItemPropGroup("Geometry", true, props));
      }
    } else {
      {
        List<MapItemPropItem> props = [];
        props.add(MapItemPropItem("", "code", "Code", "multiline", ""));
        pageMain.groups.add(MapItemPropGroup("Code", true, props));
      }
      /*{
        List<MapItemPropItem> props = [];
        props.add(MapItemPropItem(
            "", "data_source", "Data Source Item", "data_source", ""));
        pageMain.groups.add(MapItemPropGroup("Data Source", true, props));
      }*/
      /*{
        List<MapItemPropItem> props = [];
        props.add(MapItemPropItem("", "action_on_click_write_data_item",
            "On-Click Write Data Item", "data_source", ""));
        props.add(MapItemPropItem("", "action_on_click_write_value",
            "On-Click Write Value", "text", ""));
        props.add(MapItemPropItem("", "action_on_click_confirmation",
            "On-Click Write Confirmation", "bool", ""));
        props.add(MapItemPropItem("", "action_on_click_confirmation_text",
            "On-Click Write Confirmation Text", "text", ""));
        pageMain.groups.add(MapItemPropGroup("Actions", true, props));
      }*/
      {
        List<MapItemPropItem> props = [];
        props.add(MapItemPropItem("", "x", "X", "double", "0"));
        props.add(MapItemPropItem("", "y", "Y", "double", "0"));
        props.add(MapItemPropItem("", "w", "Width", "double", "200"));
        props.add(MapItemPropItem("", "h", "Height", "double", "200"));
        pageMain.groups.add(MapItemPropGroup("Geometry", false, props));
      }
    }
    return [pageMain, pageDataItems];
  }

  List<ActionPoint> actionPoints() {
    List<ActionPoint> result = [];
    double actionPointSize = 30;
    actionPointSize = actionPointSize / zoom;
    result.add(ActionPoint(
        "size_br",
        Rect.fromLTWH(
            getDouble("x") + getDouble("w") - actionPointSize,
            getDouble("y") + getDouble("h") - actionPointSize,
            actionPointSize,
            actionPointSize)));
    return result;
  }

  List<ActionPoint> actionPointsZ() {
    List<ActionPoint> result = [];
    double actionPointSize = 30;
    result.add(ActionPoint(
        "size_br",
        Rect.fromLTWH(
            getDoubleZ("x") + getDoubleZ("w") - actionPointSize,
            getDoubleZ("y") + getDoubleZ("h") - actionPointSize,
            actionPointSize,
            actionPointSize)));
    return result;
  }

  Future<Uint8List> drawToImage(double margin, bool demo) async {
    resetToEndOfAnimation();
    Uint8List pngBytes = Uint8List(0);
    dart_ui.PictureRecorder rec = dart_ui.PictureRecorder();
    Canvas canvas = Canvas(rec);
    Size size = Size(getDouble("w"), getDouble("h"));
    canvas.translate(margin, margin);
    if (demo) {
      drawDemo(canvas, size);
    } else {
      drawItem(canvas, size, "", []);
    }
    dart_ui.Picture pic = rec.endRecording();
    dart_ui.Image img = await pic.toImage(
        getDouble("w").toInt() + (margin * 2).toInt(),
        getDouble("h").toInt() + (margin * 2).toInt());
    ByteData? byteData = await img.toByteData(format: ImageByteFormat.png);
    if (byteData != null) {
      pngBytes = byteData.buffer.asUint8List();
      //pngBytes = makeThumbnail(pngBytes)!;
    }
    return pngBytes;
  }

  MapItem? itemUnderPoint(Offset offsetOnMap, bool fromTop, bool recourse) {
    return null;
  }

  @override
  Connection getConnection() {
    return connection;
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
      TextAlign align) {
    canvas.save();
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
}

enum TextVAlign {
  top,
  middle,
  bottom,
}

class ActionPoint {
  String code;
  Rect rect;
  ActionPoint(this.code, this.rect);
}

class MapItemPropPage {
  String name;
  Icon icon;
  Widget? widget;
  List<MapItemPropGroup> groups;
  MapItemPropPage(this.name, this.icon, this.groups, {this.widget}) {
    widget = null;
  }
}

class MapItemPropGroup {
  String name;
  bool expanded;
  List<MapItemPropItem> props;
  MapItemPropGroup(this.name, this.expanded, this.props);
}

class MapItemPropItem {
  String name;
  String displayName;
  String type;
  String groupName;
  String defaultValue;
  MapItemPropItem(this.groupName, this.name, this.displayName, this.type,
      this.defaultValue);
}

abstract class IPropContainer {
  String id();
  void set(String name, String value);
  String get(String name);
  Connection getConnection();
  List<MapItemPropPage> propList();
  void setDouble(String name, double value);
}
