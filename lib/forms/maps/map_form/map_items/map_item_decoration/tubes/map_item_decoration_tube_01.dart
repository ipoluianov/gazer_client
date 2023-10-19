import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import '../../../../utils/draw_text.dart';
import '../../../../utils/ticker.dart';
import '../../../main/map_item.dart';
import '../map_item_decoration.dart';

class MapItemDecorationTube01 extends MapItemDecoration {
  static const String sType = "decoration.tube.01";
  static const String sName = "Decoration.tube.01";
  @override
  String type() {
    return sType;
  }

  MapItemDecorationTube01(Connection connection) : super(connection) {}

  @override
  void setDefaultsForItem() {
    //super.setDefaults();
    setDouble("w", 100);
    setDouble("h", 100);
  }

  Rect padding(Rect rect, double padding) {
    return Rect.fromLTRB(rect.left + padding, rect.top + padding,
        rect.right - padding, rect.bottom - padding);
  }

  List<MapItemDecorationTube01Item> items_ = [];

  Random rnd = Random(DateTime.now().microsecondsSinceEpoch);
  //int currentRandom = 0;

  int lastPeriod = 0;

  void initTickers(int count, double size, int period) {
    int period = getDouble("decor_period_1").toInt();
    if (count != items_.length || period != lastPeriod) {
      items_.clear();
      double yOffset = 0;
      var ta = getTextAppearance(this);

      for (int i = 0; i < count; i++) {
        var t = MapItemDecorationTube01Item(
          yOffset,
          period,
          get("decor_values"),
          ta.fontSize,
          getColor("decor_color"),
          getColor("decor_color_disabled"),
          ta.fontFamily,
        );
        items_.add(t);
        yOffset = yOffset + size;
      }
      lastPeriod = period;
    }
  }

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    bool acEnabled = activityEnabled();

    var ta = getTextAppearance(this);

    drawPre(canvas, size);

    Rect mainRect = Offset(getDoubleZ("x"), getDoubleZ("y")) &
        Size(getDoubleZ("w"), getDoubleZ("h"));

    double minSize = getDoubleZ("w");
    if (getDoubleZ("h") < minSize) minSize = getDoubleZ("h");

    Color decColor = getColor("decor_color");
    if (!acEnabled) {
      decColor = getColor("decor_color_disabled");
    }

    Color borderColor = getColor("decor_border_color");
    double borderWidth = getDoubleZ("decor_border_width");

    canvas.drawLine(
      Offset(mainRect.left, mainRect.top + borderWidth / 2),
      Offset(mainRect.right, mainRect.top + borderWidth / 2),
      Paint()
        ..color = borderColor
        ..strokeWidth = borderWidth
        ..style = PaintingStyle.stroke,
    );

    canvas.drawLine(
      Offset(mainRect.left, mainRect.bottom - borderWidth / 2),
      Offset(mainRect.right, mainRect.bottom - borderWidth / 2),
      Paint()
        ..color = borderColor
        ..strokeWidth = borderWidth
        ..style = PaintingStyle.stroke,
    );

    double padding = borderWidth;
    double efHeight = mainRect.height - padding * 2;

    double itemSize = ta.fontSize;
    int index = 0;
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(
        mainRect.left, mainRect.top + padding, mainRect.width, efHeight));

    initTickers((efHeight / itemSize).round() + 1, itemSize,
        getDouble("decor_period_1").round());
    var clientRect = Rect.fromLTWH(mainRect.left, mainRect.top + padding,
        mainRect.width, mainRect.height - padding * 2);
    for (int i = 0; i < items_.length; i++) {
      items_[i].setEnabled(acEnabled);
      items_[i].draw(canvas, clientRect);
    }
    /*for (double offset = padding;
        offset < padding + efHeight;
        offset += itemSize) {
      double val = 0;
      if (index >= 0 && index < ticks.length) {
        val = ticks[index].value();
      }

      String decorValues = get("decor_values");
      double hIncrement = itemSize * 10;
      if (decorValues == "HEX") {
        hIncrement = itemSize * 3;
      }
      if (decorValues == "BIN") {
        hIncrement = itemSize * 10;
      }

      int hIndex = 0;
      for (double hOffset = -mainRect.width;
          hOffset < mainRect.width;
          hOffset += hIncrement) {
        String text = "";
        int num = rndValue(index * 10 + hIndex);
        num = num & 0xFF;
        if (decorValues == "HEX") {
          text = num.toRadixString(16);
        }
        if (decorValues == "BIN") {
          text = num.toRadixString(2);
        }
        if (decorValues == "HEX") {
          while (text.length < 2) {
            text = "0$text";
          }
        }
        if (decorValues == "BIN") {
          while (text.length < 8) {
            text = "0$text";
          }
        }
        text = text.toUpperCase();
        drawText(
          canvas,
          mainRect.left + hOffset + mainRect.width * val,
          mainRect.top + offset,
          mainRect.width * 2,
          itemSize,
          text,
          itemSize,
          decColor,
          TextVAlign.middle,
          TextAlign.left,
          ta.fontFamily,
          itemSize.round(),
        );
        hIndex++;
      }
      index++;
    }*/
    canvas.restore();

    drawPost(canvas, size);
  }

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = [];
    groups.addAll(super.propGroupsOfItem());
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem(
          "", "decor_color", "Active Color", "color", "FF00EFFF"));
      props.add(MapItemPropItem(
          "", "decor_color_disabled", "Passive Color", "color", "FF555555"));
      props.add(MapItemPropItem(
          "", "decor_period_1", "Sliding Period", "double", "20000"));
      props.add(MapItemPropItem(
          "", "decor_period_2", "Changing Text Period", "double", "100"));
      props.add(MapItemPropItem(
          "", "decor_border_width", "Border Width", "double", "2"));
      props.add(MapItemPropItem(
          "", "decor_border_color", "Border Color", "color", "FF00EFFF"));
      props.add(MapItemPropItem(
          "", "decor_values", "Values", "options:BIN:HEX", "BIN"));

      groups.add(MapItemPropGroup("Decoration", true, props));
    }
    groups.add(textAppearanceGroup());
    groups.add(borderGroup(borderWidthDefault: "0"));
    groups.add(backgroundGroup());
    return groups;
  }

  DateTime lastRandomGenDT = DateTime(0);

  @override
  void tick() {
    for (int i = 0; i < items_.length; i++) {
      items_[i].ticker.tick();
    }
  }

  @override
  void resetToEndOfAnimation() {}
}

class MapItemDecorationTube01Item {
  Ticker ticker = Ticker();
  double yOffset_ = 0;
  Random rnd = Random(DateTime.now().microsecondsSinceEpoch);

  Color colorActive_ = Colors.black;
  Color colorPassive_ = Colors.black;

  String decorValues_ = "";
  double size_ = 1;
  String fontFamily_ = "";

  MapItemDecorationTube01Item(double yOffset, int period, String decorValues,
      double size, Color colorActive, Color colorPassive, String fontFamily) {
    ticker.min = 0;
    ticker.max = 1;
    ticker.periodMs = period + rnd.nextInt((period * 0.2).round());
    ticker.valueMs = rnd.nextInt(ticker.periodMs);
    yOffset_ = yOffset;
    colorActive_ = colorActive;
    colorPassive_ = colorPassive;
    decorValues_ = decorValues;
    size_ = size;
    fontFamily_ = fontFamily;
  }

  void setEnabled(en) {
    ticker.setEnabled(en);
  }

  void draw(Canvas canvas, Rect rect) {
    /*canvas.drawRect(
        Rect.fromLTWH(rect.left + rect.width * ticker.value(),
            rect.top + yOffset_, 10, 10),
        Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.fill);*/

    String text = "";
    int num = 123;
    num = num & 0xFF;
    if (decorValues_ == "HEX") {
      text = num.toRadixString(16);
    }
    if (decorValues_ == "BIN") {
      text = num.toRadixString(2);
    }
    if (decorValues_ == "HEX") {
      while (text.length < 2) {
        text = "0$text";
      }
    }
    if (decorValues_ == "BIN") {
      while (text.length < 8) {
        text = "0$text";
      }
    }
    text = text.toUpperCase();
    drawText(
      canvas,
      rect.left + rect.width * ticker.value(),
      rect.top + yOffset_,
      rect.width * 2,
      size_,
      text,
      size_,
      ticker.enabled_ ? colorActive_ : colorPassive_,
      TextVAlign.middle,
      TextAlign.left,
      fontFamily_,
      size_.round(),
    );
  }
}
