import 'package:gazer_client/widgets/time_chart/time_chart_settings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as international;

class TimeChartPainter extends CustomPainter {
  TimeChartSettings settings;
  Function(int groupTimeRange, int dtBegin, int dtEnd) onPaint;

  TimeChartPainter(this.settings, this.onPaint);

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
