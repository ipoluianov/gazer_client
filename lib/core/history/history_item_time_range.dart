import '../protocol/dataitem/data_item_history_chart.dart';
import '../workspace/workspace.dart';
import 'history_data_range.dart';
import 'history_loading_task.dart';

class HistoryItemTimeRange {
  final Connection connection;
  String itemName;
  int groupTimeRange;
  DateTime _dtLastClearProcedure = DateTime.now();
  Map<int, HistoryDataRange> data = {};
  HistoryItemTimeRange(this.connection, this.itemName, this.groupTimeRange);

  List<DataItemHistoryChartItemValueResponse> getHistory(
      int minTime, int maxTime) {
    List<DataItemHistoryChartItemValueResponse> result = [];
    int duration = historyDataRangeDuration(groupTimeRange);
    int startRangeTime = minTime - (minTime % duration);
    int endRangeTime = maxTime - (maxTime % duration) + duration;

    for (int i = startRangeTime; i < endRangeTime; i += duration) {
      if (!data.containsKey(i)) {
        HistoryDataRange r = HistoryDataRange(i, groupTimeRange);
        data[i] = r;
        r.request(connection, itemName);
      } else {
        var dataRange = data[i];
        if (dataRange != null) {
          dataRange.request(connection, itemName);
          if (dataRange.values.isNotEmpty) {
            for (var v in dataRange.values[0].items) {
              if (v.datetimeFirst >= minTime && v.datetimeLast <= maxTime) {
                result.add(v);
              }
            }
          }
          // Invalidate last block
          if (dataRange.isFresh()) {
            dataRange.requestForce(connection, itemName);
          }
        }
      }
    }

    return result;
  }

  List<HistoryLoadingTask> rangesInProgress() {
    List<HistoryLoadingTask> result = [];
    for (var entry in data.entries) {
      if (entry.value.processing) {
        result.add(
            HistoryLoadingTask(entry.value.beginTime, entry.value.endTime));
      }
    }
    return result;
  }

  void cleanUp() {
    var now = DateTime.now();
    if (now.difference(_dtLastClearProcedure).inMilliseconds < 5000) {
      return;
    }
    _dtLastClearProcedure = DateTime.now();
    List<int> blocksToDelete = [];
    for (var entry in data.entries) {
      if (now.difference(entry.value.lastAccessTime).inSeconds > 5) {
        blocksToDelete.add(entry.key);
      }
    }
    for (int time in blocksToDelete) {
      data.remove(time);
    }
  }
}
