import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/core/gazer_style.dart';
import 'package:gazer_client/core/protocol/unit/unit_state.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/widgets/borders/border_03_item_details.dart';
import 'package:intl/intl.dart' as intls;

class WidgetDataItemState extends StatefulWidget {
  final Connection connection;
  final GazerLocalClient client;
  final String unitId;
  final String unitName;
  final UnitStateValuesResponseItem item;
  final Function onMainItemChanged;

  const WidgetDataItemState(this.connection, this.client, this.unitName,
      this.unitId, this.item, this.onMainItemChanged,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WidgetDataItemStateState();
  }
}

class WidgetDataItemStateState extends State<WidgetDataItemState> {
  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 2000), (t) {
      timerUpdate();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void timerUpdate() {
    setState(() {
      if (actual1 != target1) {
        if (actual1 < target1) {
          actual1++;
        } else {
          actual1--;
        }
      }
    });
  }

  intls.DateFormat timeFormat = intls.DateFormat("HH:mm:ss");
  intls.DateFormat dateFormat = intls.DateFormat("yyyy-MM-dd");

  late Timer _timer;
  String lastItemName = "";

  int target1 = 20;
  int actual1 = 0;

  String shortName(String itemName) {
    return itemName.replaceAll("${widget.unitId}/", "");
  }

  Color colorByUOM(String uom) {
    if (uom == "error") {
      return DesignColors.bad();
    }
    return DesignColors.good();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WidgetDataItemStatePainter(
          widget.item, widget.unitId, widget.unitName, this),
      child: Container(),
      key: UniqueKey(),
    );
  }
}

class WidgetDataItemStatePainter extends CustomPainter {
  final UnitStateValuesResponseItem item;
  final String unitId;
  final String unitName;
  final WidgetDataItemStateState state;

  WidgetDataItemStatePainter(this.item, this.unitId, this.unitName, this.state);

  intls.DateFormat timeFormat = intls.DateFormat("HH:mm:ss");
  intls.DateFormat dateFormat = intls.DateFormat("yyyy-MM-dd");

  Rect buildRect(Rect rectOriginal) {
    return Rect.fromLTWH(rectOriginal.left, rectOriginal.top,
        rectOriginal.width, rectOriginal.height);
  }

  Path buildPath(Rect rectOriginal) {
    Path p = Path();
    p.addPolygon(buildPoints(buildRect(rectOriginal)), true);
    return p;
  }

  double thickness = 2;

  double calcCornerRadius() {
    return 12;
  }

  List<Offset> buildPoints(Rect rect) {
    List<Offset> points = [];
    var cornerRadius = calcCornerRadius();
    points.add(Offset(rect.left, rect.top));
    points.add(Offset(rect.left + rect.width / 2 - cornerRadius, rect.top));
    points.add(Offset(rect.left + rect.width / 2, rect.top + cornerRadius));
    points.add(Offset(rect.right, rect.top + cornerRadius));
    points.add(Offset(rect.right, rect.bottom));

    /*points.add(Offset(
        rect.left + rect.width / 2 + cornerRadius - cornerRadius / 2,
        rect.bottom - cornerRadius));*/
    //points.add(Offset(rect.left + rect.width / 2 - cornerRadius / 2, rect.bottom));

    points.add(Offset(rect.left, rect.bottom));
    return points;
  }

  String shortName(String itemName) {
    return itemName.replaceAll("$unitId/", "");
  }

  Path buildDecorationPath(Rect rect, bool reverse) {
    List<Offset> points = [];

    if (reverse) {
      points.add(Offset(rect.left + rect.width / 2, rect.top));
      points.add(Offset(rect.right, rect.top));
      points.add(Offset(rect.right - rect.width / 2, rect.bottom));
      points.add(Offset(rect.left, rect.bottom));
    } else {
      points.add(Offset(rect.left, rect.top));
      points.add(Offset(rect.right - rect.width / 2, rect.top));
      points.add(Offset(rect.right, rect.bottom));
      points.add(Offset(rect.left + rect.width / 2, rect.bottom));
    }

    Path p = Path();
    p.addPolygon(points, true);
    return p;
  }

  void drawDecoration(Canvas canvas, Rect rect, Color color, bool reverse) {
    canvas.save();
    Path path = buildDecorationPath(rect, reverse);
    //path.addPolygon(buildPoints(rect), true);
    canvas.clipPath(path);
    canvas.drawRect(
        Rect.fromLTWH(
            rect.left, rect.top, rect.width + rect.height, rect.height),
        Paint()
          ..style = PaintingStyle.fill
          ..color = color);
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    Color backColor = DesignColors.back();
    Color valueColor = colorByUOM(item.value.uom);
    if (valueColor == colorByUOM("")) {
      valueColor = DesignColors.fore2();
    }

    canvas.save();
    Path path = Path();
    path.addPolygon(buildPoints(rect), true);
    canvas.clipPath(path);
    canvas.drawRect(
        Rect.fromLTWH(
            -calcCornerRadius(),
            -calcCornerRadius(),
            size.width + calcCornerRadius() * 2,
            size.height + calcCornerRadius() * 2),
        Paint()
          ..style = PaintingStyle.fill
          ..color = backColor);

    String valueText = item.value.value + ' ' + item.value.uom;
    if (item.value.value.isEmpty) {
      valueText = item.value.uom;
    }
    double valueFontSize = 48;
    if (valueText.length > 20) {
      valueFontSize = 36;
    }

    canvas.save();

    double padding = calcCornerRadius();

    canvas.translate(padding, padding);
    double contentWidth = size.width - padding * 2;

    double offset = calcCornerRadius();
    // Unit Name
    Size sizeOfUnitName = measureText(canvas, 0, offset, contentWidth, 0,
        unitName, 16, DesignColors.fore1(), TextAlign.start);
    Size sizeOfItemName = measureText(canvas, 0, offset, contentWidth, 0,
        shortName(item.name), 36, DesignColors.fore(), TextAlign.start);
    offset += drawText(canvas, padding, offset, contentWidth, 0, unitName, 16,
        DesignColors.fore1(), TextAlign.start);

    offset += 5;

    Offset line1Offset = Offset(0, offset - 1);

    canvas.drawLine(
        line1Offset,
        Offset(200 - 2, offset - 1),
        Paint()
          //..isAntiAlias = false
          ..strokeWidth = 2
          ..color = valueColor);

    for (int i = 0; i < state.actual1; i++) {
      double left = 200 + i * 15;
      drawDecoration(
          canvas,
          Rect.fromLTWH(left, offset - sizeOfUnitName.height / 2,
              sizeOfUnitName.height, sizeOfUnitName.height / 2),
          valueColor,
          true);
    }

    offset += 5;

    // Item Name
    offset += drawText(canvas, padding, offset, contentWidth, 0,
        shortName(item.name), 36, DesignColors.fore(), TextAlign.start);

    offset += 12;

    var isErr = isError(item.value.uom);

    double linesValue =
        DateTime.now().millisecondsSinceEpoch.toDouble() / 10000;
    if (isErr) {
      linesValue = DateTime.now().millisecondsSinceEpoch.toDouble() / 500;
    }
    for (double i = offset; i < size.height; i += 10) {
      var begin = 490 + sin(linesValue) * 100 + 100;
      double opacity = 1 - i / (size.height - offset);
      opacity += 0.3;

      if (i == offset) {
        begin = padding;
      }

      if (opacity < 0) {
        opacity = 0;
      }
      if (opacity > 1) {
        opacity = 1;
      }

      var strokeWidth = 1.0;
      if (isErr) {
        strokeWidth = 3;
      }

      canvas.drawLine(
          Offset(begin, i),
          Offset(size.width, i),
          Paint()
            ..color = colorByUOM(item.value.uom).withOpacity(opacity)
            ..strokeWidth = strokeWidth);

      if (isErr) {
        linesValue += 0.15;
      } else {
        linesValue += 0.15;
      }
    }

    // Item Value
    offset += drawText(canvas, padding, offset, 490, 0, valueText,
        valueFontSize, colorByUOM(item.value.uom), TextAlign.start);
    double lastOffset = offset;

    // Time & Date
    offset = size.height - padding;

    Size sizeOfTime = measureText(
        canvas,
        0,
        offset,
        contentWidth,
        0,
        timeFormat.format(DateTime.fromMicrosecondsSinceEpoch(item.value.time)),
        24,
        DesignColors.fore(),
        TextAlign.start);
    Size sizeOfDate = measureText(
        canvas,
        0,
        offset,
        contentWidth,
        0,
        dateFormat.format(DateTime.fromMicrosecondsSinceEpoch(item.value.time)),
        12,
        DesignColors.fore(),
        TextAlign.start);
    offset -= sizeOfTime.height;
    //offset -= sizeOfDate.height;
    offset -= padding;

    double timeAndDateWidth = sizeOfTime.width;
    if (sizeOfDate.width > timeAndDateWidth) {
      timeAndDateWidth = sizeOfDate.width;
    }
    //double timeAndDateHeight = sizeOfTime.height + sizeOfDate.height;

    Offset line2Offset = Offset(0, size.height);

    if (offset > lastOffset) {
      canvas.drawLine(
          Offset(0, offset + 1),
          Offset(109 - 2, offset + 1),
          Paint()
            //..isAntiAlias = false
            ..strokeWidth = 2
            ..color = valueColor);
      line2Offset = Offset(0, offset + 1);

      for (int i = 0; i < state.actual1 + 6; i++) {
        double left = 109 + i * 15;
        drawDecoration(
            canvas,
            Rect.fromLTWH(
                left, offset, sizeOfUnitName.height, sizeOfUnitName.height / 2),
            valueColor,
            false);
      }

      double dtOffset = offset;
      offset += drawText(
          canvas,
          0,
          dtOffset,
          contentWidth,
          0,
          timeFormat
              .format(DateTime.fromMicrosecondsSinceEpoch(item.value.time)),
          24,
          DesignColors.fore(),
          TextAlign.start);
      drawText(
          canvas,
          120,
          dtOffset + 12,
          contentWidth,
          0,
          dateFormat
              .format(DateTime.fromMicrosecondsSinceEpoch(item.value.time)),
          12,
          DesignColors.fore1(),
          TextAlign.start);
    }

    canvas.drawLine(
        Offset(line1Offset.dx + 1, line1Offset.dy + 10),
        Offset(line2Offset.dx + 1, line2Offset.dy - 10),
        Paint()
          //..isAntiAlias = false
          ..strokeWidth = 1
          ..color = valueColor);

    canvas.restore();

    canvas.drawLine(
        Offset(0, 0),
        Offset(0, size.height),
        Paint()
          //..isAntiAlias = false
          ..strokeWidth = 2
          ..color = valueColor);

    canvas.restore();
  }

  double drawText(Canvas canvas, double x, double y, double width,
      double height, String text, double size, Color color, TextAlign align) {
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
    textPainter.paint(canvas, Offset(x, y));
    return textPainter.height;
  }

  Size measureText(Canvas canvas, double x, double y, double width,
      double height, String text, double size, Color color, TextAlign align) {
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
    return Size(textPainter.maxIntrinsicWidth, textPainter.height);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
