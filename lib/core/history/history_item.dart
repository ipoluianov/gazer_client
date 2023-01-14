import '../protocol/dataitem/data_item_list.dart';
import '../workspace/workspace.dart';
import 'history_item_time_range.dart';
import 'history_item_time_range_get_history_result.dart';
import 'history_loading_task.dart';

class HistoryItem {
  final Connection connection;
  String itemName = "";
  Map<int, HistoryItemTimeRange> ranges = {};
  HistoryItem(
      this.connection, this.itemName, this._value, this.lastAccessDateTime);

  DataItemInfo? _value;
  DateTime lastAccessDateTime;

  HistoryItemTimeRangeGetHistoryResult getHistory(
      int minTime, int maxTime, int groupTimeRange) {
    if (ranges.containsKey(groupTimeRange)) {
      var res = ranges[groupTimeRange]!.getHistory(minTime, maxTime);
      return res;
    }
    HistoryItemTimeRange range =
        HistoryItemTimeRange(connection, itemName, groupTimeRange);
    range.itemName = itemName;
    ranges[groupTimeRange] = range;
    var res = ranges[groupTimeRange]!.getHistory(minTime, maxTime);
    return res;
  }

  DataItemInfo getValue() {
    if (_value == null) {
      return DataItemInfo(0, itemName, "", "", 0, "");
    }
    return _value!;
  }

  void setValue(DataItemInfo value) {
    _value = value;
  }

  List<HistoryLoadingTask> getLoadingTasks() {
    List<HistoryLoadingTask> result = [];
    for (var rKey in ranges.keys) {
      result.addAll(ranges[rKey]!.loadingTasks);
    }
    return result;
  }

  void clear() {
    for (var rKey in ranges.keys) {
      ranges[rKey]!.clear();
    }

    checkCurrentValueTTL();
  }

  bool checkCurrentValueTTL() {
    var dt = DateTime.now();
    dt = dt.add(const Duration(seconds: -10));
    if (lastAccessDateTime.microsecondsSinceEpoch < dt.microsecondsSinceEpoch) {
      _value = null;
      return false;
    }
    return true;
  }
}
