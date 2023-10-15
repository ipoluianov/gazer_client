import 'dart:async';

class Ticker {
  double min = 0.0;
  double max = 1.0;
  int periodMs = 1000;
  DateTime dtLastTick = DateTime(0);

  int valueMs = 0;
  double value01 = 0;

  bool enabled_ = false;

  double k = 0;
  double kTarget = 0;

  Ticker() {
    dtLastTick = DateTime.now();
  }

  void setEnabled(bool en) {
    enabled_ = en;
    kTarget = en ? 1 : 0;
  }

  void tick() {
    if ((k - kTarget).abs() > 0.01) {
      k += (kTarget - k) / 50;
    } else {
      k = kTarget;
    }
    //print(k);

    var now = DateTime.now();
    var diff = now.millisecondsSinceEpoch - dtLastTick.millisecondsSinceEpoch;
    //if (enabled_) {
    valueMs += (diff * k).round();
    //}
    if (valueMs > periodMs) {
      valueMs = 0;
    }
    value01 = valueMs / periodMs;
    dtLastTick = now;
  }

  double value({reverse = false}) {
    double result = 0;
    if (reverse) {
      result = max - value01 * (max - min);
    } else {
      result = min + value01 * (max - min);
    }
    return result;
  }
}
