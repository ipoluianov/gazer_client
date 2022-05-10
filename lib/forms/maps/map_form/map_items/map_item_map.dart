import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/protocol/resource/resource_get.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/tools/calc_preffered_scale.dart';
import 'package:gazer_client/core/tools/hex_colors.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_decorations/map_item_decoration_rect_01.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_decorations/map_item_decoration_set.dart';

import '../map_item.dart';
import '../map_item_decorations/map_item_decoration.dart';

class MapItemMap extends MapItem {
  static const String sType = "map";
  static const String sName = "Map";
  @override
  String type() {
    return sType;
  }

  MapItemMap(Connection connection) : super(connection) {
    backImage = null;
  }

  String lastLoadedResource = "";
  bool loaded = false;
  bool loading = false;
  //bool loaded = false;
  String loadingError = "";
  double loadingProgress = 0;

  Set<String> loadedParentMaps = {};

  Size loadedMapOriginalSize = Size.zero;

  //String lastResourceId = "";

  bool recourseFound = false;

  String nameOfMap = "";
  String mapName() {
    return nameOfMap;
  }

  @override
  void setDefaultsForItem() {
    print("setDefaultsForItem");
    postDecorations = MapItemDecorationList([]);
    {
      var decoration = MapItemDecorationRect01();
      decoration.initDefaultProperties();
      postDecorations.items.add(decoration);
    }

    if (isRoot) {
      setDouble("w", 960);
      setDouble("h", 540);
    } else {
      setDouble("w", 200);
      setDouble("h", 200);
    }
  }

  void loadFromResource(String resourceId, Set<String> loadedMaps) async {
    //lastResourceId = resourceId;
    //print("loadFromResource $resourceId");

    if (resourceId == "") {
      return;
    }

    if (loadedMaps.contains(resourceId)) {
      recourseFound = true;
      loadingError = "Recourse found";
      return;
    }

    if (loading) {
      return;
    }

    //print("loadFromResource $resourceId");

    loaded = false;

    clearProperties();

    loading = true;
    //print("loading $resourceId");

    int step = 200000;
    List<int> result = [];

    loadingProgress = 0;
    try {
      for (int offset = 0; offset < 100 * 1000000; offset += step) {
        //print("loading res offset $offset");
        var value = await Repository().client(connection).fetch<ResGetRequest, ResGetResponse>(
          'resource_get',
          ResGetRequest(resourceId, offset, step),
              (Map<String, dynamic> json) => ResGetResponse.fromJson(json),
        );
        if (value.content.isEmpty) {
          break;
        }
        nameOfMap = value.name;
        result.addAll(value.content.toList());
        if (value.size > 0) {
          loadingProgress = result.length / value.size;
        }
      }
    } catch (loadingErr) {
      print("loading error");
      loadingError = loadingErr.toString();
    }
    loadingProgress = 1;

    try {
      var jsonString = utf8.decode(result);
      var jsonObject = jsonDecode(jsonString);
      if (isRoot) {
        //print("root 222 $jsonString");
        loadPropertiesRoot(jsonObject);
      } else {
        //print("non-root 222 $jsonString");
        loadPropertiesInner(jsonObject);
      }
    } catch (err) {
      print("root 222 exception $err");
      setDefaults();
    }

    lastLoadedResource = resourceId;

    //print("loaded $resourceId");
    loading = false;
    loaded = true;
  }

  String resource(double actualWidth) {
    var resId = get("resource_id");
    if (isRoot) {
      return resId;
    }

    var resMiniId = get("s1_resource_id");
    var resMiniWidth = getDouble("s1_width");

    if (resMiniId.isNotEmpty && actualWidth < resMiniWidth) {
      resId = resMiniId;
    }

    return resId;
  }

  void load(Set<String> loadedMaps, double width) {
    var resId = resource(width);
    if (lastLoadedResource != resId) {
      loadFromResource(resId, loadedMaps);
    }
  }

  @override
  void tick() {
    for (var item in items) {
      item.tickItem();
    }
  }

  double targetZoom1 = 1;
  double localZoom = 1;

  @override
  double calcPrefScale() {
    if (isRoot) {
      return zoom;
    }

    lastBackgroundRect = Offset(getDoubleZ("x"), getDoubleZ("y")) & Size(getDoubleZ("w"), getDoubleZ("h"));
    CalcPreferredScaleResult calcRes = calcPreferredScale(Size(getDouble("w"), getDouble("h")), loadedMapOriginalSize, CalcPreferredScaleType.contain);
    targetZoom1 = zoom * calcRes.scaleX;
    localZoom = calcRes.scaleX;

    if (loaded) {
      lastBackgroundRect =
      Offset(getDoubleZ("x"), getDoubleZ("y")) & Size(loadedMapOriginalSize.width * targetZoom1, loadedMapOriginalSize.height * targetZoom1);
    }
    return targetZoom1;
  }

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {

    var parentMapsLocal = List<String>.from(parentMaps);
    parentMapsLocal.add(lastLoadedResource);

    //if (isRoot) {
      load(Set<String>.from(parentMaps), getDoubleZ("w"));
    //}
    canvas.save();

    targetZoom1 = zoom;
    //zoom = targetZoom1;

    bool needToTranslate = false;

    if (!isRoot) {
      if (loadedMapOriginalSize.width > 0 && loadedMapOriginalSize.height > 0) {
        calcPrefScale();
        needToTranslate = true;
      }
    }

    drawPre(canvas, size);

    if (loading) {
      canvas.drawRect(
          Rect.fromLTWH(getDoubleZ("x"), getDoubleZ("y"), getDoubleZ("w"), getDoubleZ("h")),
          Paint()
            ..color = colorFromHex("30247176")
            ..style = PaintingStyle.fill);

      //print("draw Loading: ${getDoubleZ("x")}");

      var prMargin = getDoubleZ("w") / 4;
      var prWidth = getDoubleZ("w") - prMargin * 2;

      canvas.drawRect(
          Rect.fromLTWH(getDoubleZ("x") + prMargin - 2, getDoubleZ("y") + getDoubleZ("h") / 2 - 10 - 2, prWidth+ 4, 20 + 4),
          Paint()
            ..color = colorFromHex("247176")
            ..strokeWidth = 1
            ..style = PaintingStyle.stroke);

      canvas.drawRect(
          Rect.fromLTWH(getDoubleZ("x") + prMargin, getDoubleZ("y") + getDoubleZ("h") / 2 - 10, prWidth * loadingProgress, 20),
          Paint()
            ..color = colorFromHex("247176")
            ..style = PaintingStyle.fill);
    } else {
      if (loadingError.isNotEmpty) {
        canvas.drawRect(
            Rect.fromLTWH(getDoubleZ("x"), getDoubleZ("y"), getDoubleZ("w"), getDoubleZ("h")),
            Paint()
              ..color = Colors.red
              ..style = PaintingStyle.fill);
        drawText(
            canvas,
            getDoubleZ("x"),
            getDoubleZ("y"),
            getDoubleZ("w"),
            getDoubleZ("h"),
            loadingError,
            z(20),
            Colors.yellowAccent,
            TextAlign.center);
      }

      if (needToTranslate) {
        canvas.translate(getDoubleZ("x"), getDoubleZ("y"));
      }

      for (var item in items) {
        item.zoom = targetZoom1;
        item.drawItem(canvas, size, getDataSource(), parentMapsLocal);
      }
    }



    drawPost(canvas, size);
    canvas.restore();
  }

  Rect lastBackgroundRect = Rect.zero;

  @override
  Rect backgroundRect() {
    if (isRoot) {
      return Offset(getDoubleZ("x"), getDoubleZ("y")) & Size(getDoubleZ("w"), getDoubleZ("h"));
    }
    calcPrefScale();
    return lastBackgroundRect;
  }

  void clearProperties() {
    var itemsDoNotRemove = propListForInnerMap();
    var itemsDoNotRemoveSet = Set<String>.from(itemsDoNotRemove.map((e1) => e1.name).toList());
    List<String> itemsToRemove = [];
    for (var itemPropKey in props.keys) {
      if (!itemsDoNotRemoveSet.contains(itemPropKey)) {
        itemsToRemove.add(itemPropKey);
      }
    }
    for (var itemToRemove in itemsToRemove) {
      props.remove(itemToRemove);
    }
    props.remove("children");
    props.remove("decorations");
    items.clear();
  }

  void loadPropertiesInner(Map<String, dynamic> json) {
    Set<String> doNotLoadFromSource = {
      "type",
      "x",
      "y",
      "w",
      "h",
      "data_source"
    };

    double? originalWidth = 0;
    double? originalHeight = 0;

    if (json.containsKey("w") && json["w"] != null) {
      originalWidth = double.tryParse(json["w"]);
    }

    if (json.containsKey("h") && json["h"] != null) {
      originalHeight = double.tryParse(json["h"]);
    }

    if (originalWidth != null && originalHeight != null) {
      loadedMapOriginalSize = Size(originalWidth, originalHeight);
    }

    //print("load inner map");
    for (var key in json.keys) {
      if (key != "children" && json[key] is String && !doNotLoadFromSource.contains(key)) {
        set(key, json[key]);
        //print("Load map prop ${key} ${json[key]}");
      }
    }
    var children = json['children'];
    for (var ch in children) {
      items.add(MapItem.fromJson(ch, connection));
    }

    postDecorations.items = [];
    var postDecorationsJson = json['decorations'];
    for (var ch in postDecorationsJson) {
      var decor = MapItemDecoration.makeByType(ch['type']);
      decor.loadFromJson(ch);
      postDecorations.items.add(decor);
    }

    print("load inner map ${get("data_source")}");

  }

  void loadPropertiesRoot(Map<String, dynamic> json) {
    for (var key in json.keys) {
      if (key != "children" && json[key] is String) {
        set(key, json[key]);
      }
    }

    var children = json['children'];
    for (var ch in children) {
      items.add(MapItem.fromJson(ch, connection));
    }

    postDecorations.items = [];
    var postDecorationsJson = json['decorations'];
    for (var ch in postDecorationsJson) {
      var decor = MapItemDecoration.makeByType(ch['type']);
      decor.loadFromJson(ch);
      postDecorations.items.add(decor);
    }

  }

  void drawText(Canvas canvas, double x, double y, double width, double height, String text, double size, Color color, TextAlign align) {
    var textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: size,
      ),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: align);
    textPainter.layout(
      minWidth: width,
      maxWidth: width,
    );
    textPainter.paint(canvas, Offset(x, y + (height / 2) - (textPainter.height / 2)));
  }

  @override
  MapItem? itemUnderPoint(Offset offsetOnMap, bool fromTop, bool recourse) {
    if (!isRoot) {
      if (localZoom > 0) {
        offsetOnMap = Offset(offsetOnMap.dx / localZoom, offsetOnMap.dy / localZoom);
      }
    }

    if (fromTop) {
      for (var i = items.length - 1; i >= 0; i--) {
        var item = items[i];
        double itemX = item.getDouble("x");
        double itemY = item.getDouble("y");
        double itemW = item.getDouble("w");
        double itemH = item.getDouble("h");
        Rect r = Rect.fromLTWH(itemX, itemY, itemW, itemH);
        if (r.contains(offsetOnMap)) {
          if (recourse) {
            var inItemResult = item.itemUnderPoint(offsetOnMap.translate(-itemX, -itemY), fromTop, recourse);
            if (inItemResult != null) {
              return inItemResult;
            }
            return item;
          } else {
            return item;
          }
        }
      }
    } else {
      for (var item in items) {
        double itemX = item.getDouble("x");
        double itemY = item.getDouble("y");
        double itemW = item.getDouble("w");
        double itemH = item.getDouble("h");
        Rect r = Rect.fromLTWH(itemX, itemY, itemW, itemH);
        if (r.contains(offsetOnMap)) {
          if (recourse) {
            var inItemResult = item.itemUnderPoint(offsetOnMap.translate(itemX, itemY), fromTop, recourse);
            if (inItemResult != null) {
              return inItemResult;
            }
            return item;
          } else {
            return item;
          }
        }
      }
    }
    return null;
  }



}
