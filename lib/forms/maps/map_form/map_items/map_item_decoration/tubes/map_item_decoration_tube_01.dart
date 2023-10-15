import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import '../../../../utils/draw_dashes.dart';
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

  MapItemDecorationTube01(Connection connection) : super(connection) {
    rndValues = [];
    for (int i = 0; i < 100; i++) {
      rndValues.add(rnd.nextInt(255));
    }
  }

  int rndValue(int index) {
    int realIndex = index % rndValues.length;
    return rndValues[realIndex];
  }

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

  List<Ticker> ticks = [];

  Random rnd = Random(DateTime.now().microsecondsSinceEpoch);
  //int currentRandom = 0;

  List<int> rndValues = [];

  int lastPeriod = 0;

  void initTickers(int count) {
    int period = getDouble("decor_period_1").toInt();
    if (count != ticks.length || period != lastPeriod) {
      ticks.clear();
      for (int i = 0; i < count; i++) {
        var t = Ticker();
        t.min = 0;
        t.max = 1;
        t.periodMs = period + rnd.nextInt((period * 1).round());
        t.valueMs = rnd.nextInt(period);
        ticks.add(t);
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

    initTickers((efHeight / itemSize).round() + 1);
    for (int i = 0; i < ticks.length; i++) {
      ticks[i].setEnabled(acEnabled);
    }
    for (double offset = padding;
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
    }
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
    double tickK = 0;

    for (int i = 0; i < ticks.length; i++) {
      ticks[i].tick();
      tickK = ticks[i].k;
    }

    double rndChangePeriod = getDouble("decor_period_2") + 10000 * (1 - tickK);
    if (lastRandomGenDT.difference(DateTime.now()).inMilliseconds.abs() >
        rndChangePeriod.round()) {
      if (rndValues.isNotEmpty) {
        rndValues[rnd.nextInt(10000) % rndValues.length] = rnd.nextInt(255);
      }
      lastRandomGenDT = DateTime.now();
    }
  }

  @override
  void resetToEndOfAnimation() {}
}
