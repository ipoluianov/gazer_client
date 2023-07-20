class Ticker {
  double min = 0.0;
  double max = 1.0;
  int periodMs = 1000;

  Ticker(this.min, this.max, this.periodMs);

  double value({reverse = false}) {
    int period = periodMs;
    if (period < 1) {
      period = 1;
    }
    double periodMsDbl = period.toDouble();
    int nowMs = DateTime.now().millisecondsSinceEpoch;
    double result = (nowMs % period).toDouble() / periodMsDbl;
    double delta = max - min;
    if (reverse) {
      result = max - result * delta;
    } else {
      result = min + result * delta;
    }
    return result;
  }
}
