import 'dart:math';

import 'package:gazer_client/core/protocol/dataitem/data_item_history_chart.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_settings.dart';
import 'package:flutter/material.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_vline.dart';
import 'package:gazer_client/widgets/time_table/time_table_settings.dart';
import 'package:intl/intl.dart' as international;

import 'dart:ui';

class TimeTablePainter extends CustomPainter {
  TimeTableSettings settings;
  Function(int groupTimeRange, int dtBegin, int dtEnd) onPaint;

  TimeTablePainter(this.settings, this.onPaint);

  @override
  void paint(Canvas canvas, Size size) {
    settings.draw(canvas, size);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;

  final f = international.NumberFormat("#.##########");
  String formatValue(num n) {
    return f.format(n);
  }
}
