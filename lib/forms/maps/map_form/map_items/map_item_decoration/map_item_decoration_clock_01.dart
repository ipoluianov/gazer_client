import 'package:flutter/material.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/maps/map_form/map_items/map_item_single/map_item_single.dart';
import 'package:intl/intl.dart';

import '../../../utils/draw_text.dart';
import '../../main/map_item.dart';

class MapItemDecorationClock01 extends MapItemSingle {
  static const String sType = "decoration.clock.01";
  static const String sName = "Decoration.clock.01";
  @override
  String type() {
    return sType;
  }

  //double realValue = 0.0;
  //double targetValue = 0.0;
  //double lastValue = 0.0;
  //double aniCounter = 0.0;

  MapItemDecorationClock01(Connection connection) : super(connection) {}

  @override
  void setDefaultsForItem() {
    //super.setDefaults();
    setDouble("w", 200);
    setDouble("h", 40);
  }

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    drawPre(canvas, size);

    /*
    yyyy = year
    MM = month
    dd = day

    hh = hour 12
    HH = hour 24
    mm = minutes
    ss = seconds
    */

    String text = "";
    try {
      DateTime time = DateTime.now();
      if (getBool("time_remote")) {
        //time = time.toUtc();
        var lastServiceInfo = Repository().client(connection).lastServiceInfo;
        if (lastServiceInfo != null) {
          int? nsUnixTime = int.tryParse(lastServiceInfo.time);
          if (nsUnixTime != null) {
            time = DateTime.fromMicrosecondsSinceEpoch(nsUnixTime ~/ 1000);
          }
        }
      }
      if (getBool("time_utc")) {
        time = time.toUtc();
      }
      double hourShift = getDouble("time_hour_shift");
      time = time.add(Duration(seconds: (hourShift * 3600).toInt()));
      text = DateFormat(get("time_format")).format(time);
    } catch (err) {
      text = err.toString();
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
    //groups.addAll(super.propGroupsOfItem());
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem(
          "", "time_format", "Time Format", "text", "HH:mm:ss"));
      props.add(
          MapItemPropItem("", "time_remote", "Remote Time", "bool", "false"));
      props.add(MapItemPropItem("", "time_utc", "UTC Time", "bool", "false"));
      props.add(MapItemPropItem(
          "", "time_hour_shift", "Time shift (hours)", "double", "0"));
      groups.add(MapItemPropGroup("Time", true, props));
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
