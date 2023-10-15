import 'dart:math';
import 'dart:ui';

import 'package:gazer_client/core/workspace/workspace.dart';

import '../../../../utils/draw_dashes.dart';
import '../../../../utils/draw_text.dart';
import '../../../../utils/ticker.dart';
import '../../../main/map_item.dart';
import '../map_item_decoration.dart';

class MapItemDecorationGauge02 extends MapItemDecoration {
  static const String sType = "decoration.gauge.02";
  static const String sName = "Decoration.gauge.02";
  @override
  String type() {
    return sType;
  }

  MapItemDecorationGauge02(Connection connection) : super(connection) {}

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

  Ticker tick1 = Ticker();
  Ticker tick2 = Ticker();

  @override
  void draw(Canvas canvas, Size size, List<String> parentMaps) {
    tick1.min = 0;
    tick1.max = 2 * pi;
    tick1.periodMs = getDouble("decor_period_1").toInt();
    tick2.min = 0;
    tick2.max = 2 * pi;
    tick2.periodMs = getDouble("decor_period_2").toInt();
    bool acEnabled = activityEnabled();
    tick1.setEnabled(acEnabled);
    tick2.setEnabled(acEnabled);

    drawPre(canvas, size);

    Rect mainRect = Offset(getDoubleZ("x"), getDoubleZ("y")) &
        Size(getDoubleZ("w"), getDoubleZ("h"));

    double minSize = getDoubleZ("w");
    if (getDoubleZ("h") < minSize) minSize = getDoubleZ("h");

    Color decColor = getColor("decor_color");
    if (!acEnabled) {
      decColor = getColor("decor_color_disabled");
    }

    drawDashes(
      canvas,
      decColor,
      padding(mainRect, minSize * 0.08 / 2),
      10,
      minSize * 0.08,
      tick1.value(),
    );

    drawDashes(
      canvas,
      decColor,
      padding(mainRect, minSize * 0.15),
      7,
      minSize * 0.02,
      tick2.value(reverse: true),
    );

    drawDashes(
      canvas,
      decColor,
      padding(mainRect, minSize / 5),
      0,
      z(0.5),
      0,
    );

    drawDashes(
      canvas,
      decColor,
      padding(mainRect, minSize / 3),
      50,
      z(5),
      tick1.value(),
    );

    drawDashes(
      canvas,
      decColor,
      padding(mainRect, minSize / 2),
      50,
      z(1),
      0,
    );

    canvas.drawPath(
      Path()
        ..moveTo(mainRect.left + mainRect.width / 2,
            mainRect.top + mainRect.height / 4)
        ..lineTo(mainRect.left + mainRect.width / 2,
            mainRect.top + mainRect.height - mainRect.height / 4),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = decColor
        ..strokeWidth = 2
        ..imageFilter =
            ImageFilter.blur(sigmaX: 2, sigmaY: mainRect.height / 10),
    );

    canvas.drawPath(
      Path()
        ..moveTo(mainRect.left + mainRect.width / 4,
            mainRect.top + mainRect.height / 2)
        ..lineTo(mainRect.left + mainRect.width - mainRect.width / 4,
            mainRect.top + mainRect.height / 2),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = decColor
        ..strokeWidth = 2
        ..imageFilter =
            ImageFilter.blur(sigmaX: mainRect.width / 10, sigmaY: 2),
    );

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
      props.add(
          MapItemPropItem("", "decor_period_1", "Period 1", "double", "20000"));
      props.add(
          MapItemPropItem("", "decor_period_2", "Period 2", "double", "10000"));
      groups.add(MapItemPropGroup("Decoration", true, props));
    }
    groups.add(borderGroup(borderWidthDefault: "0"));
    groups.add(backgroundGroup());
    return groups;
  }

  @override
  void tick() {
    tick1.tick();
    tick2.tick();
  }

  @override
  void resetToEndOfAnimation() {}
}
