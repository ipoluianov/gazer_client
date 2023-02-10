import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/tools/calc_preffered_scale.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/core/tools/hex_colors.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_decorations/map_item_decoration_circles_01.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_decorations/map_item_decoration_none.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_decorations/map_item_decoration_pipe_01.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_decorations/map_item_decoration_set.dart';

import '../map_item.dart';
import 'map_item_decoration_card_01.dart';
import 'map_item_decoration_rect_01.dart';
import 'map_item_decoration_braces_01.dart';
import 'map_item_decoration_clock_01.dart';
import 'map_item_decoration_card_02.dart';

import 'dart:ui' as dart_ui;

class MapItemDecoration extends IPropContainer {
  final Connection connection = Connection.makeDefault();

  MapItemDecoration() {
    generateAndSetNewId();
  }
  double showProgress = 0;
  DateTime dtCreated = DateTime.fromMillisecondsSinceEpoch(0);
  bool displayed() { return showProgress > 0.99; }

  double zoom = 1;
  double z(double value) {
    return value * zoom;
  }

  String _id = "";
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

  Map<String, String> props = {};

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
  void set(String name, String value) {
    props[name] = value;
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

  double getDoubleWithThresholds(String name) {
    var val = getWithThresholds(name);
    if (val != "") {
      double? res = double.tryParse(val);
      if (res != null) {
        return res;
      }
      return 0;
    }
    return 0;
  }

  void setBool(String name, bool value) {
    if (value) {
      props[name] = "1";
    } else {
      props[name] = "0";
    }
  }

  bool getBool(String name) {
    var val = get(name);
    return val == "1";
  }

  bool getBoolWithThresholds(String name) {
    var val = getWithThresholds(name);
    return val == "1";
  }

  void setColor(String name, Color? color) {
    if (color != null) {
      set(name, colorToHex(color));
    } else {
      set(name, "");
    }
  }

  Color getColor(String name) {
    var val = get(name);
    if (val != "") {
      return colorFromHex(val);
    }
    return Colors.transparent;
  }

  Color getColorWithThresholds(String name) {
    var val = getWithThresholds(name);
    if (val != "") {
      return colorFromHex(val);
    }
    return Colors.transparent;
  }

  void loadFromJson(Map<String, dynamic> json) {
    for (var propKey in json.keys) {
      props[propKey] = json[propKey];
    }
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {};
    for (var propKey in props.keys) {
      result[propKey] = props[propKey];
    }
    return result;
  }

  ThresholdType currentThreshold() {
    var dsValue = currentValue;
    double? valueWithNull = double.tryParse(dsValue);
    if (valueWithNull != null) {
      double value = valueWithNull;
      if (get("threshold_up_error_active") == "1") {
        if (value >= getDouble("threshold_up_error_value")) {
          return ThresholdType.upError;
        }
      }
      if (get("threshold_down_error_active") == "1") {
        if (value <= getDouble("threshold_down_error_value")) {
          return ThresholdType.downError;
        }
      }
      if (get("threshold_down_warning_active") == "1") {
        if (value <= getDouble("threshold_down_warning_value")) {
          return ThresholdType.downWarning;
        }
      }
      if (get("threshold_up_warning_active") == "1") {
        if (value >= getDouble("threshold_up_warning_value")) {
          return ThresholdType.upWarning;
        }
      }
    }

    String uom = currentUOM;

    if (get("threshold_uom_1_active") == "1") {
      if (uom == get("threshold_uom_1_value")) {
        return ThresholdType.uom1;
      }
    }

    return ThresholdType.none;
  }

  String getWithThresholds(String name) {
    var prefix = thresholdName(currentThreshold());
    if (prefix.isNotEmpty) {
      name = prefix + "_" + name;
    }
    if (props.containsKey(name)) {
      if (props[name] == null) {
        return "";
      }
      return props[name]!;
    }
    return "";
  }

  String thresholdName(ThresholdType thresholdType) {
    switch (thresholdType) {
      case ThresholdType.none:
        return "";
      case ThresholdType.downError:
        return "threshold_down_error";
      case ThresholdType.downWarning:
        return "threshold_down_warning";
      case ThresholdType.upWarning:
        return "threshold_up_warning";
      case ThresholdType.upError:
        return "threshold_up_error";
      case ThresholdType.uom1:
        return "threshold_uom_1";
    }
  }


  @override
  Connection getConnection() {
    return Connection.makeDefault();
  }

  @override
  MapItemDecorationList getDecorations() {
    return MapItemDecorationList([]);
  }

  @override
  List<MapItemPropItem> propThreshold() {
    List<MapItemPropItem> props = [];
    props.add(MapItemPropItem("", "show_visible", "Visible", "bool", "1"));
    //props.add(MapItemPropItem("", "show_wait", "Wait for the previous one1", "bool", "1"));
    props.addAll(propThresholdOfItem());
    return props;
  }

  @protected
  List<MapItemPropItem> propThresholdOfItem() {
    List<MapItemPropItem> props = [];
    return props;
  }

  bool drawWasCalled = false;
  void tickDecoration() {
    if (!drawWasCalled) { // No tick before first draw
      return;
    }

    var v = getBoolWithThresholds("show_visible");
    if (v != lastVisible) {
      lastVisible = v;
      dtCreated = DateTime.now();
      //print("dtCreated inited for ${get("type")}");
    }

    if (v) {
      if (showProgress < 1) {
        double showDelay = getDouble("show_delay");
        if (dtCreated.millisecondsSinceEpoch > 0 && DateTime
            .now()
            .difference(dtCreated)
            .inMilliseconds > showDelay) {
          var showDuration = getDouble("show_duration");
          var showTimeUS = DateTime
              .now()
              .difference(dtCreated)
              .inMicroseconds;

          showProgress = ((showTimeUS / 1000.0) - showDelay) / showDuration;
          //print("pr UP $showProgress");

          if (showProgress < 0) {
            showProgress = 0;
          }
          if (showProgress > 1) {
            showProgress = 1;
          }
        }
      }
    } else {
      if (showProgress > 0) {
        double showDelay = getDouble("show_delay");
        if (dtCreated.millisecondsSinceEpoch > 0 && DateTime
            .now()
            .difference(dtCreated)
            .inMilliseconds > showDelay) {
          var showDuration = getDouble("show_duration");
          var showTimeUS = DateTime
              .now()
              .difference(dtCreated)
              .inMicroseconds;
          showProgress = 1 - (((showTimeUS / 1000.0) - showDelay) / showDuration);
          //print("pr DOWN $showProgress");
          if (showProgress < 0) {
            showProgress = 0;
          }
          if (showProgress > 1) {
            showProgress = 1;
          }
        }
      }
    }
    tick();
  }

  void tick() {}

  String dataSource = "";
  String currentValue = "";
  String currentUOM = "";

  /*bool waitForPreviousDecoration() {
    return getBoolWithThresholds("show_wait");
  }*/

  bool visible() {
    return lastVisible;
  }

  bool lastVisible = false;

  void drawDecoratorPre(Canvas canvas, Rect rect, MapItem item, double z) {
    //print("drawDecoratorPre $showProgress ${getBoolWithThresholds("show_visible")} ${dtCreated.millisecondsSinceEpoch}");
    zoom = z;

    dataSource = item.getDataSource();
    currentValue = item
        .dataSourceValue()
        .value;
    currentUOM = item
        .dataSourceValue()
        .uom;
    if (!drawWasCalled) {
      //print("decorationPre first call");
      drawWasCalled = true;
    }
    if (showProgress > 0.001) {
      drawPre(canvas, rect, item);
    }
  }

  void drawDecoratorPost(Canvas canvas, Rect rect, MapItem item, double z) {
    zoom = z;
    if (showProgress > 0.001) {
      dataSource = item.getDataSource();
      currentValue = item
          .dataSourceValue()
          .value;
      drawPost(canvas, rect, item);
    }
  }

  void drawPre(Canvas canvas, Rect rect, MapItem item) {}
  void drawPost(Canvas canvas, Rect rect, MapItem item) {}
  List<MapItemPropGroup> propGroupsOfDecorator() { return []; }

  @override
  List<MapItemPropPage> propList() {
    List<MapItemPropPage> pages = [];
    MapItemPropPage page = MapItemPropPage("MMM", Icon(Icons.pages), []);
    pages.add(page);

    page.groups.addAll(propGroupsOfDecorator());
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "show_delay", "Delay before showing, ms", "double", "0"));
      props.add(MapItemPropItem("", "show_duration", "Showing duration, ms", "double", "500"));
      props.add(MapItemPropItem("", "show_visible", "Visible", "bool", "1"));
      //props.add(MapItemPropItem("", "show_wait", "Wait for the previous one1", "bool", "1"));
      page.groups.add(MapItemPropGroup("Showing", false, props));
    }
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "threshold_up_error", "Up Error", "threshold", ""));
      props.add(MapItemPropItem("", "threshold_up_warning", "Up Warning", "threshold", ""));
      props.add(MapItemPropItem("", "threshold_down_warning", "Down Warning", "threshold", ""));
      props.add(MapItemPropItem("", "threshold_down_error", "Down Error", "threshold", ""));
      props.add(MapItemPropItem("", "threshold_uom_1", "UOM", "threshold", ""));
      page.groups.add(MapItemPropGroup("Thresholds", false, props));
    }
    return pages;
  }

  void initDefaultProperties() {
    set("type", type());
    for (var itemPropPage in propList()) {
      for (var itemPropGroup in itemPropPage.groups) {
        for (var itemProp in itemPropGroup.props) {
          set(itemProp.name, itemProp.defaultValue);
        }
      }
    }
  }

  static MapItemDecoration makeByType(String decorationType) {
    MapItemDecoration? decoration;
    //print(decorationType);
    switch (decorationType) {
      case "circles.01":
        decoration = MapItemDecorationCircles01();
        break;
      case "card.01":
        decoration = MapItemDecorationCard01();
        break;
      case "rect.01":
        decoration = MapItemDecorationRect01();
        break;
      case "braces.01":
        decoration = MapItemDecorationBraces01();
        break;
      case "clock.01":
        decoration = MapItemDecorationClock01();
        break;
      case "card.02":
        decoration = MapItemDecorationCard02();
        break;
      case "pipe.01":
        decoration = MapItemDecorationPipe01();
        break;
    }

    decoration ??= MapItemDecorationNone();
    decoration.set("type", decorationType);

    return decoration;
  }

  String type() {
    return "none";
  }

  static List<MapItemDecorationType> types() {
    List<MapItemDecorationType> result = [];

    result.add(MapItemDecorationType("circles.01", "Circles.01"));
    result.add(MapItemDecorationType("card.01", "Card.01"));
    result.add(MapItemDecorationType("rect.01", "Rectangle.01"));
    result.add(MapItemDecorationType("braces.01", "Braces.01"));
    result.add(MapItemDecorationType("clock.01", "Clock.01"));
    result.add(MapItemDecorationType("card.02", "Card.02"));
    result.add(MapItemDecorationType("pipe.01", "Pipe.01"));

    return result;
  }

  String lastBackImageBase64 = "";
  dart_ui.Image? backImage;
  void drawBack(Canvas canvas,List<Offset> points) {
    double minX = double.maxFinite;
    double minY = double.maxFinite;
    double maxX = -double.maxFinite;
    double maxY = -double.maxFinite;

    for (var p in points) {
      if (p.dx < minX) {
        minX = p.dx;
      }
      if (p.dx > maxX) {
        maxX = p.dx;
      }
      if (p.dy < minY) {
        minY = p.dy;
      }
      if (p.dy > maxY) {
        maxY = p.dy;
      }
    }

    Rect rect = Rect.fromLTRB(minX, minY, maxX, maxY);

    var backColor = getColorWithThresholds("back_color");

    var backImageBytesB64 = getWithThresholds("back_img");
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
    var calcScaleFitString = getWithThresholds("back_img_scale_fit");
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

    /*if (rRect != null) {
      canvas.clipRRect(rRect);
      //RRect.fromRectAndRadius();
    }*/

    Path path = Path();
    path.addPolygon(points, true);
    canvas.clipPath(path);

    if (backImage != null) {
      var backRect = rect;

      var calcRes =
      calcPreferredScale(Size(backRect.width, backRect.height), Size(backImage!.width.toDouble(), backImage!.height.toDouble()), scaleFit);
      var scaleFactorX = calcRes.scaleX;
      var scaleFactorY = calcRes.scaleY;
      var imgOffsetX = (rect.left + calcRes.offset.dx) / scaleFactorX;
      var imgOffsetY = (rect.top + calcRes.offset.dy) / scaleFactorY;

      canvas.save();
      //canvas.clipRect(dart_ui.Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height));
      canvas.scale(scaleFactorX, scaleFactorY);
      canvas.drawImage(backImage!, Offset(imgOffsetX, imgOffsetY), Paint());
      canvas.restore();
    }

    if (backColor.alpha > 0) {
      canvas.drawRect(
          rect,
          Paint()
            ..style = PaintingStyle.fill
            ..color = backColor);
    }

    canvas.restore();
  }

  Future<dart_ui.Image> _loadImage(Uint8List backImageBytes) async {
    return await decodeImageFromList(backImageBytes);
  }

}

class MapItemDecorationType {
  String type;
  String name;
  MapItemDecorationType(this.type, this.name);
}
