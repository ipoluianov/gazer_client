import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as dart_ui;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import 'map_item.dart';
import 'map_item_library.dart';
import '../map_items/map_item_special/map_item_map.dart';

class MapView {
  MapView(Connection connection) {
    _displayOffset = Offset.zero;
    lastTapOffset = null;
    startMovingOffset = Offset.zero;
    initMapInstance(connection);
  }

  void initMapInstance(Connection connection) {
    instance = MapItemMap(connection);
    instance.isRoot = true;
    instance.initDefaultProperties();
    instance.backImage = null;
  }

  late MapItemMap instance;

  late Offset _displayOffset;
  bool defaultView = true;
  Size lastSize = const Size(0, 0);
  bool autoZoom = false;
  late bool _editing = false;
  String currentTool = "";
  String currentToolParameter = "";
  double gridSize = 10;
  bool fullscreen = false;

  void resetView() {
    defaultView = false;

    double fullWidthOfView = instance.getDouble("w");
    double fullHeightOfView = instance.getDouble("h");
    var intWidth = lastSize.width;
    var intHeight = lastSize.height;

    var xOffset = intWidth / 2 - fullWidthOfView / 2;
    var yOffset = intHeight / 2 - fullHeightOfView / 2;

    setTargetDisplayOffset(Offset(xOffset, yOffset));

    setTargetZoom(xOffset, yOffset, 1.0);
  }

  void setTargetDisplayOffset(Offset target) {
    targetDisplayOffset = target;
  }

  Offset offsetOfCenter() {
    var intWidth = lastSize.width;
    var intHeight = lastSize.height;
    var xOffset = intWidth / 2;
    var yOffset = intHeight / 2;
    return Offset(xOffset, yOffset);
  }

  void zoomIn() {
    defaultView = false;
    var z = instance.zoom + 0.1;
    if (z > 100) {
      z = 100;
    }

    var center = offsetOfCenter();
    setTargetZoom(center.dx, center.dy, z);
  }

  void zoomOut() {
    defaultView = false;
    var z = instance.zoom - 0.1;
    if (z < 0.1) {
      z = 0.1;
    }
    var center = offsetOfCenter();
    setTargetZoom(center.dx, center.dy, z);
  }

  void autoZoomToggle() {
    autoZoom = !autoZoom;
    if (!autoZoom) {
      entire();
    } else {
      currentAutoZoomRect = Rect.zero;
    }
  }

  void setEditing(bool editing) {
    _editing = editing;
    if (!editing) {
      for (var item in instance.items) {
        item.selected = false;
      }
    }
  }

  bool editing() {
    return _editing;
  }

  void editingToggle() {
    setEditing(!_editing);
  }

  void setItemPos(MapItem item, double x, double y) {
    x = x - x % gridSize;
    y = y - y % gridSize;
    item.setDouble("x", x);
    item.setDouble("y", y);
  }

  void setItemSize(MapItem item, double w, double h) {
    w = w - w % gridSize;
    h = h - h % gridSize;
    item.setDouble("w", w);
    item.setDouble("h", h);
  }

  void entire() {
    var width = instance.getDouble("w");
    var height = instance.getDouble("h");
    double margin01 = 0.02;
    if (fullscreen) {
      margin01 = 0.0;
    }
    var intWidth = lastSize.width - (lastSize.width * margin01); // margin
    var intHeight = lastSize.height - (lastSize.height * margin01); // margin

    double iK = 0;
    double iKo = 0;

    if (height != 0) {
      iK = width / height;
    }

    if (intHeight != 0) {
      iKo = intWidth / intHeight;
    }

    double intScale = 0;

    if (iK > iKo) {
      if (width != 0) {
        intScale = intWidth / width;
      }
    } else {
      if (height != 0) {
        intScale = intHeight / height;
      }
    }

    double fullWidthOfView = instance.getDouble("w") * intScale;
    double fullHeightOfView = instance.getDouble("h") * intScale;

    var xOffset = intWidth / 2 - fullWidthOfView / 2;
    var yOffset = intHeight / 2 - fullHeightOfView / 2;

    setTargetZoom(xOffset, yOffset, intScale);
    defaultView = true;
  }

  double calcZoomForEntireItem(MapItem item, double marginsInPercents) {
    double marginValue = 10;
    if (marginsInPercents < 0.01) {
      marginsInPercents = 0.01;
    }
    if (marginsInPercents > 0.99) {
      marginsInPercents = 0.99;
    }
    marginValue = 1 / marginsInPercents;

    var width = item.getDouble("w");
    var height = item.getDouble("h");
    var intWidth = lastSize.width - (lastSize.width / marginValue); // margin
    var intHeight = lastSize.height - (lastSize.height / marginValue); // margin

    double iK = 0;
    double iKo = 0;

    if (height != 0) {
      iK = width / height;
    }

    if (intHeight != 0) {
      iKo = intWidth / intHeight;
    }

    double intScale = 0;

    if (iK > iKo) {
      if (width != 0) {
        intScale = intWidth / width;
      }
    } else {
      if (height != 0) {
        intScale = intHeight / height;
      }
    }
    return intScale;
  }

  double calcZoomForRect(Size sizeVirtual, double marginsInPercents) {
    double marginValue = 10;
    if (marginsInPercents < 0.01) {
      marginsInPercents = 0.01;
    }
    if (marginsInPercents > 0.99) {
      marginsInPercents = 0.99;
    }
    marginValue = 1 / marginsInPercents;

    var width = sizeVirtual.width;
    var height = sizeVirtual.height;
    var intWidth = lastSize.width - (lastSize.width / marginValue); // margin
    var intHeight = lastSize.height - (lastSize.height / marginValue); // margin

    double iK = 0;
    double iKo = 0;

    if (height != 0) {
      iK = width / height;
    }

    if (intHeight != 0) {
      iKo = intWidth / intHeight;
    }

    double intScale = 0;

    if (iK > iKo) {
      if (width != 0) {
        intScale = intWidth / width;
      }
    } else {
      if (height != 0) {
        intScale = intHeight / height;
      }
    }
    return intScale;
  }

  Rect currentAutoZoomRect = const Rect.fromLTWH(0, 0, 1, 1);

  void runAutoZoom(List<MapItem> itemsToZoom) {
    if (itemsToZoom.isEmpty) {
      return;
    }
    double calcX1 = itemsToZoom[0].getDouble("x");
    double calcY1 = itemsToZoom[0].getDouble("y");
    double calcX2 =
        itemsToZoom[0].getDouble("x") + itemsToZoom[0].getDouble("w");
    double calcY2 =
        itemsToZoom[0].getDouble("y") + itemsToZoom[0].getDouble("h");
    for (var i in itemsToZoom) {
      if (i.getDouble("x") < calcX1) {
        calcX1 = i.getDouble("x");
      }
      if (i.getDouble("y") < calcY1) {
        calcY1 = i.getDouble("y");
      }
      if (i.getDouble("x") + i.getDouble("w") > calcX2) {
        calcX2 = i.getDouble("x") + i.getDouble("w");
      }
      if (i.getDouble("y") + i.getDouble("h") > calcY2) {
        calcY2 = i.getDouble("y") + i.getDouble("h");
      }
    }
    Rect autoZoomRect = Rect.fromLTRB(calcX1, calcY1, calcX2, calcY2);
    //print("${autoZoomRect} ${currentAutoZoomRect}");

    /*if (autoZoomRect.left == currentAutoZoomRect.left
        && autoZoomRect.top == currentAutoZoomRect.top
        && autoZoomRect.width == currentAutoZoomRect.width
        && autoZoomRect.height == currentAutoZoomRect.height
    ) {
      return;
    }*/

    // item.rectZWidthOffset(_displayOffset)

    //print("autozoom $autoZoomRect");
    currentAutoZoomRect = autoZoomRect;
    zoomOnRectVirtual(currentAutoZoomRect);
  }

  void tick() {
    instance.tickItem();

    if (autoZoom) {
      bool found = false;
      List<MapItem> itemsToZoom = [];
      for (var item in instance.items) {
        if (item.needToZoom()) {
          defaultView = false;
          itemsToZoom.add(item);
          found = true;
        }
      }
      if (!found) {
        entire();
      } else {
        runAutoZoom(itemsToZoom);
      }
    }

    processZoom();
  }

  void setViewPropertiesDirect(Offset dOffset, double z) {
    if (z < 0.01) {
      z = 0.01;
    }
    if (z > 100) {
      z = 100;
    }
    targetDisplayOffset = dOffset;
    _displayOffset = dOffset;
    targetZoomZ = z;
    instance.zoom = z;
  }

  Offset displayOffset() {
    return _displayOffset;
  }

  void removeSelectedItem() {
    instance.items.removeWhere((element) {
      return element.selected;
    });
  }

  void copySelectedItem() {
    var item = currentItem();
    if (item != null) {
      var encoder = JsonUtf8Encoder();
      Map<String, dynamic> jsonResObj = {};
      jsonResObj["type"] = "map_item";
      jsonResObj["content"] = item.toJson();
      String jsonString = String.fromCharCodes(encoder.convert(jsonResObj));
      Clipboard.setData(ClipboardData(text: jsonString));
    }
  }

  void pasteFromClipboard() {
    Clipboard.getData(Clipboard.kTextPlain).then((value) {
      if (value != null) {
        if (value.text != null) {
          String? jsonString = value.text;
          if (jsonString != null) {
            Map<String, dynamic> jsonMap = jsonDecode(jsonString);
            if (jsonMap.containsKey("type")) {
              if (jsonMap["type"] == "map_item") {
                var item =
                    MapItem.fromJson(jsonMap["content"], instance.connection);
                item.setDouble("x", item.getDouble("x") + gridSize);
                item.setDouble("y", item.getDouble("y") + gridSize);
                instance.items.add(item);
              }
            }
          }
        }
      }
    });
  }

  bool keyControl = false;
  bool keyAlt = false;
  bool keyShift = false;

  void setKeys(control, alt, shift) {
    keyControl = control;
    keyAlt = alt;
    keyShift = shift;
  }

  void drawGrid(Canvas canvas, Size size) {
    var gridColor = Colors.white12;
    for (double x = 0; x <= instance.getDouble("w"); x += gridSize) {
      canvas.drawLine(
          Offset(instance.z(x), 0),
          Offset(instance.z(x), instance.getDoubleZ("h")),
          Paint()
            ..strokeWidth = 1
            ..color = gridColor
            ..style = PaintingStyle.stroke);
    }
    for (double y = 0; y <= instance.getDouble("h"); y += gridSize) {
      canvas.drawLine(
          Offset(0, instance.z(y)),
          Offset(instance.getDoubleZ("w"), instance.z(y)),
          Paint()
            ..strokeWidth = 1
            ..color = gridColor
            ..style = PaintingStyle.stroke);
    }
  }

  List<String> parentMaps = [];

  void draw(Canvas canvas, Size size) {
    lastSize = size;

    parentMaps = [];

    if (defaultView) {
      entire();
      _displayOffset = Offset(
          size.width / 2 - instance.z(instance.getDouble("w") / 2),
          size.height / 2 - instance.z(instance.getDouble("h") / 2));
      targetDisplayOffset = _displayOffset;
    }

    canvas.save();
    canvas.translate(_displayOffset.dx, _displayOffset.dy);

    // DRAW ITEM ///////////////////////
    instance.drawItem(canvas, size, "", parentMaps);
    ////////////////////////////////////

    if (_editing) {
      drawGrid(canvas, size);
    }

    for (var i in instance.items) {
      if (i.selected) {
        i.drawSelection(canvas, size);
      }
      if (_editing) {
        i.drawEditingBorders(canvas, size);
      }
    }

    canvas.restore();

    if (currentTool != "") {
      drawText(canvas, 0, 0, size.width, size.height,
          "Click to add $currentTool", 36, Colors.white30, TextAlign.left);
    }

    while (mapViewLog.length > 10) {
      mapViewLog.removeAt(0);
    }
    /*var logItemIndex = 0;
    for (var logItem in mapViewLog) {
      //drawText(canvas, 0, 0 + logItemIndex * 20, 500, 100, logItem, 12, Colors.red, TextAlign.left);
      logItemIndex++;
    }*/
  }

  void drawText(Canvas canvas, double x, double y, double width, double height,
      String text, double size, Color color, TextAlign align) {
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
    //textPainter.paint(canvas, Offset(x, y + (height / 2) - (textPainter.height / 2)));
    textPainter.paint(canvas, Offset(x + 10, y + 10));
  }

  bool moveModeMap = false;
  bool moveModeItem = false;
  bool moveModeResizeItem = false;

  late MapItem movingItem;
  late Offset? lastTapOffset;
  late Offset movingItemStartOffset;
  late Size movingItemStartSize;

  late Offset startMovingOffset;
  double multiTouchScaleOriginal = 1;

  //Offset lastHoverOffset = const Offset(0, 0);
  PointerDeviceKind lastDeviceType = PointerDeviceKind.unknown;

  void startMoving(int pointerCount, Offset offsetDoNotUse) {
    if (lastTapOffset != null) {
      print("startMoving last: $lastTapOffset current: $offsetDoNotUse");
    } else {
      print("startMoving last: -------------- current: $offsetDoNotUse");
    }
    lastTapOffset ??= offsetDoNotUse;
    var item = itemUnderPoint(lastTapOffset!, true, false);

    multiTouchScaleOriginal = instance.zoom;
    startMovingOffset = lastTapOffset!;

    if (item != null && _editing) {
      for (var i in instance.items) {
        i.selected = false;
      }
      item.selected = true;

      var actionPointsList = item.actionPointsZ();
      for (var ap in actionPointsList) {
        var offsetFterCorrection =
            lastTapOffset!.translate(-_displayOffset.dx, -_displayOffset.dy);
        if (ap.rect.contains(offsetFterCorrection)) {
          moveModeResizeItem = true;
        }
      }

      if (!moveModeResizeItem) {
        moveModeItem = true;
      }

      movingItem = item;
    } else {
      //print("no item");
      moveModeMap = true;
    }
    startMovingOffset = lastTapOffset!;
    defaultView = false;
    autoZoom = false;
    //print("scroll ${offset.dx} ${offset.dy}");
  }

  void updateMoving(int pointerCount, Offset offset, double scale) {
    if (moveModeItem) {
      var x = (offset.dx - _displayOffset.dx) / instance.zoom -
          movingItemStartOffset.dx;
      var y = (offset.dy - _displayOffset.dy) / instance.zoom -
          movingItemStartOffset.dy;
      setItemPos(movingItem, x, y);
      return;
    }

    if (moveModeResizeItem) {
      var coordinatesOnItemX = (offset.dx - _displayOffset.dx) / instance.zoom -
          movingItem.getDouble("x");
      var coordinatesOnItemY = (offset.dy - _displayOffset.dy) / instance.zoom -
          movingItem.getDouble("y");
      setItemSize(movingItem, coordinatesOnItemX, coordinatesOnItemY);
      return;
    }

    double offsetX = 0;
    double offsetY = 0;
    if (scale > 1.00001 || scale < 0.99999) {
      targetZoomX = offset.dx;
      targetZoomY = offset.dy;
      targetZoomZ = multiTouchScaleOriginal * scale;
      var deltaZoom = targetZoomZ / instance.zoom;
      var offsetOfPointerX = targetZoomX - _displayOffset.dx;
      var offsetOfPointerY = targetZoomY - _displayOffset.dy;
      offsetX = offsetOfPointerX * deltaZoom - offsetOfPointerX;
      offsetY = offsetOfPointerY * deltaZoom - offsetOfPointerY;
      instance.zoom = multiTouchScaleOriginal * scale;
    }

    var dX = offset.dx - startMovingOffset.dx;
    var dY = offset.dy - startMovingOffset.dy;
    targetDisplayOffset = Offset(
        _displayOffset.dx + dX - offsetX, _displayOffset.dy + dY - offsetY);
    _displayOffset = targetDisplayOffset;
    startMovingOffset = offset;
    //print("display offset: ${_displayOffset.dx} ${_displayOffset.dy}");
  }

  void stopMoving(int pointerCount) {
    moveModeMap = false;
    moveModeItem = false;
    moveModeResizeItem = false;
    lastTapOffset = null;
  }

  List<String> mapViewLog = [];

  MapItem addItem(String type, Offset offset, Map<String, String> props) {
    var item = MapItemsLibrary().makeItemByType(type, instance.connection);
    print("add item " + item.type() + " " + type);

    if (currentTool == "map") {
      item.set("resource_id", currentToolParameter);
    }

    double itemW = 100;
    double itemH = 100;
    setItemPos(
        item,
        (offset.dx - _displayOffset.dx) / instance.zoom - itemW / 2,
        (offset.dy - _displayOffset.dy) / instance.zoom - itemH / 2);
    //setItemSize(item, itemW, itemH);
    item.setDefaultsForItem();
    setItemPos(
        item,
        (offset.dx - _displayOffset.dx) / instance.zoom -
            item.getDouble("w") / 2,
        (offset.dy - _displayOffset.dy) / instance.zoom -
            item.getDouble("height") / 2);
    instance.items.add(item);
    currentTool = "";
    currentToolParameter = "";

    props.forEach((key, value) {
      item.set(key, value);
    });

    for (var item in instance.items) {
      item.selected = false;
    }

    item.selected = true;
    return item;
  }

  void tapDown(Offset offset, BuildContext context) {
    //print("tapDown $offset");
    mapViewLog.add("Tap down $offset");
    autoZoom = false;

    if (_editing) {
      if (currentTool != "") {
        var item =
            MapItemsLibrary().makeItemByType(currentTool, instance.connection);
        print("add item " + item.type() + " " + currentTool);
        if (currentTool == "map") {
          item.set("resource_id", currentToolParameter);
        }

        double itemW = 100;
        double itemH = 100;
        setItemPos(
            item,
            (offset.dx - _displayOffset.dx) / instance.zoom - itemW / 2,
            (offset.dy - _displayOffset.dy) / instance.zoom - itemH / 2);
        //setItemSize(item, itemW, itemH);
        item.setDefaultsForItem();
        setItemPos(
            item,
            (offset.dx - _displayOffset.dx) / instance.zoom -
                item.getDouble("w") / 2,
            (offset.dy - _displayOffset.dy) / instance.zoom -
                item.getDouble("height") / 2);
        instance.items.add(item);
        currentTool = "";
        currentToolParameter = "";
      } else {
        for (var item in instance.items) {
          item.selected = false;
        }

        MapItem? item = itemUnderPoint(offset, true, false);
        if (item != null) {
          /*lastTapOffset = offset;
          movingItemStartOffset = Offset((offset.dx - _displayOffset.dx) / zoom - item.getDouble("x"), (offset.dy - _displayOffset.dy) / zoom - item.getDouble("y"));
          movingItemStartSize = Size(item.getDouble("w"), item.getDouble("h"));
*/
          defaultView = false;
          item.selected = true;
        }
      }
    } else {
      // zoom to item
      MapItem? item = itemUnderPoint(offset, true, true);
      if (item != null) {
        defaultView = false;
        item.onTapDown(context);
      }
    }
  }

  void tapUp(Offset offset, BuildContext context) {
    MapItem? item = itemUnderPoint(offset, true, true);
    if (item != null) {
      defaultView = false;
      item.onTapUp(context);
    }
  }

  MapItem? currentItem() {
    for (var i in instance.items) {
      if (i.selected) {
        return i;
      }
    }
    return instance;
  }

  void onPointerDown(Offset offset) {
    //print("onPointerDown");
    MapItem? item = itemUnderPoint(offset, true, false);
    if (item != null) {
      lastTapOffset = offset;
      movingItemStartOffset = Offset(
          (offset.dx - _displayOffset.dx) / instance.zoom - item.getDouble("x"),
          (offset.dy - _displayOffset.dy) / instance.zoom -
              item.getDouble("y"));
      movingItemStartSize = Size(item.getDouble("w"), item.getDouble("h"));
    }
  }

  void onPointerUp(Offset offset) {
    //print("onPointerUp");
    lastTapOffset = null;
  }

  MapItem? hoverItem;

  void onHover(Offset offset) {
    if (!_editing) {
      MapItem? item = itemUnderPoint(offset, true, true);
      if (item != null) {
        hoverItem = item;
        //print("HOVER ${item.type()}");
      } else {
        hoverItem = null;
      }
    } else {
      hoverItem = null;
    }
  }

  void zoomOnItem(MapItem item) {
    Offset itemPos = Offset(item.getDoubleZ("x") + _displayOffset.dx,
        item.getDoubleZ("y") + _displayOffset.dy);
    Size itemSize = Size(item.getDoubleZ("w"), item.getDoubleZ("h"));
    //print("item rect : ${itemPos.dx} ${itemPos.dy} ${itemSize.width} ${itemSize.height}");
    Offset centerOfItem = Offset(
        itemPos.dx + itemSize.width / 2, itemPos.dy + itemSize.height / 2);
    //print("item center : ${centerOfItem.dx} ${centerOfItem.dy}");
    var centerOfScreen = offsetOfCenter();
    double z = calcZoomForEntireItem(item, 0.1);
    //print("Target Zoom ------- : $z");

    setTargetDisplayOffset(Offset(
        _displayOffset.dx - (centerOfItem.dx - centerOfScreen.dx),
        _displayOffset.dy - (centerOfItem.dy - centerOfScreen.dy)));
    setTargetZoom(centerOfScreen.dx, centerOfScreen.dy, z);
    //defaultView = true;

    //setTargetZoom(itemPos.dx, itemPos.dy, );
  }

  void zoomOnRect(Rect rectOnDisplay) {
    Offset itemPos = Offset(rectOnDisplay.left, rectOnDisplay.top);
    Size itemSize = Size(rectOnDisplay.width, rectOnDisplay.height);
    Offset centerOfItem = Offset(
        itemPos.dx + itemSize.width / 2, itemPos.dy + itemSize.height / 2);
    var centerOfScreen = offsetOfCenter();

    double z = calcZoomForRect(Size(itemSize.width, itemSize.height), 0.1);
    //print("Target Zoom: $z");

    setTargetDisplayOffset(Offset(
        _displayOffset.dx - (centerOfItem.dx - centerOfScreen.dx),
        _displayOffset.dy - (centerOfItem.dy - centerOfScreen.dy)));
    setTargetZoom(centerOfScreen.dx, centerOfScreen.dy, z);
  }

  void zoomOnRectVirtual(Rect rectVirtual) {
    Offset itemPos = Offset(instance.z(rectVirtual.left) + _displayOffset.dx,
        instance.z(rectVirtual.top) + _displayOffset.dy);
    Size itemSize =
        Size(instance.z(rectVirtual.width), instance.z(rectVirtual.height));
    Offset centerOfItem = Offset(
        itemPos.dx + itemSize.width / 2, itemPos.dy + itemSize.height / 2);
    var centerOfScreen = offsetOfCenter();

    double tz =
        calcZoomForRect(Size(rectVirtual.width, rectVirtual.height), 0.1);
    //print("Target Zoom: $tz");

    setTargetDisplayOffset(Offset(
        _displayOffset.dx - (centerOfItem.dx - centerOfScreen.dx),
        _displayOffset.dy - (centerOfItem.dy - centerOfScreen.dy)));
    setTargetZoom(centerOfScreen.dx, centerOfScreen.dy, tz);
  }

  double targetZoomX = 0.0;
  double targetZoomY = 0.0;
  double targetZoomZ = 1.0;

  Offset targetDisplayOffset = const Offset(0, 0);

  double currentZoomX = 0.0;
  double currentZoomY = 0.0;

  void setTargetZoom(double x, double y, double z) {
    targetZoomX = x;
    targetZoomY = y;
    targetZoomZ = z;
  }

  void processZoom() {
    if (processDisplayOffset()) {
      return;
    }
    var diff = targetZoomZ - instance.zoom;
    var z = instance.zoom;

    z += diff / 3;

    if ((z - targetZoomZ).abs() < 0.1) {
      z = targetZoomZ;
    }

    if (z < 0.1) {
      z = 0.1;
    }
    if (z > 100) {
      z = 100;
    }

    var deltaZoom = z / instance.zoom;

    var offsetOfPointerX = targetZoomX - _displayOffset.dx;
    var offsetOfPointerY = targetZoomY - _displayOffset.dy;
    var offsetX = offsetOfPointerX * deltaZoom - offsetOfPointerX;
    var offsetY = offsetOfPointerY * deltaZoom - offsetOfPointerY;
    _displayOffset =
        Offset(_displayOffset.dx - offsetX, _displayOffset.dy - offsetY);
    targetDisplayOffset = _displayOffset;

    instance.zoom = z;
  }

  bool processDisplayOffset() {
    if (_displayOffset.dx == targetDisplayOffset.dx &&
        _displayOffset.dy == targetDisplayOffset.dy) {
      return false;
    }

    var diffX = targetDisplayOffset.dx - _displayOffset.dx;
    var x = _displayOffset.dx;
    x += diffX / 3;
    if ((x - targetDisplayOffset.dx).abs() < 3) {
      x = targetDisplayOffset.dx;
    }

    var diffY = targetDisplayOffset.dy - _displayOffset.dy;
    var y = _displayOffset.dy;
    y += diffY / 3;
    if ((y - targetDisplayOffset.dy).abs() < 3) {
      y = targetDisplayOffset.dy;
    }

    _displayOffset = Offset(x, y);
    return true;
  }

  void setZoom(double x, double y, double z) {
    if (z < 0.1) {
      z = 0.1;
    }
    if (z > 100) {
      z = 100;
    }

    var deltaZoom = z / instance.zoom;

    var offsetOfPointerX = x - _displayOffset.dx;
    var offsetOfPointerY = y - _displayOffset.dy;
    var offsetX = offsetOfPointerX * deltaZoom - offsetOfPointerX;
    var offsetY = offsetOfPointerY * deltaZoom - offsetOfPointerY;
    _displayOffset =
        Offset(_displayOffset.dx - offsetX, _displayOffset.dy - offsetY);

    instance.zoom = z;
  }

  void scroll(Offset offset, Offset position) {
    defaultView = false;
    autoZoom = false;

    var newZoom = instance.zoom;
    var pointOfChange = 20.0;
    var distance = (offset.dy / pointOfChange);
    distance = -distance / 2;
    distance += 1;
    newZoom *= distance;

    setTargetZoom(position.dx, position.dy, newZoom);
  }

  MapItem? itemUnderPoint(Offset offsetOnWidget, bool fromTop, bool recourse) {
    double x = (offsetOnWidget.dx - _displayOffset.dx) / instance.zoom;
    double y = (offsetOnWidget.dy - _displayOffset.dy) / instance.zoom;
    Offset offsetOnMap = Offset(x, y);
    return instance.itemUnderPoint(offsetOnMap, fromTop, recourse);
  }

  void convertSelectedItemToType(String type, String parameter) {
    var item = currentItem();
    if (item == null) {
      return;
    }
    if (item.isRoot) {
      return;
    }

    double itemX = item.getDouble("x");
    double itemY = item.getDouble("y");
    double itemW = item.getDouble("w");
    double itemH = item.getDouble("h");
    String itemDS = item.get("data_source");

    removeSelectedItem();
    addItem(type, Offset(itemX, itemY), {
      "x": itemX.toString(),
      "y": itemY.toString(),
      "w": itemW.toString(),
      "h": itemH.toString(),
      "data_source": itemDS
    });
  }
}

class MapPainter extends CustomPainter {
  MapView settings;
  MapPainter(this.settings);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    settings.draw(canvas, size);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
