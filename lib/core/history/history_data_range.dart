import '../protocol/dataitem/data_item_history_chart.dart';
import '../repository.dart';
import '../workspace/workspace.dart';

const historyDataRangeSize = 100;

int historyDataRangeDuration(int groupTimeRange) {
  return historyDataRangeSize * groupTimeRange;
}

class HistoryDataRange {
  int beginTime;
  int groupTimeRange;
  int endTime = 0;
  bool processing = false;
  bool complete = false;
  List<DataItemHistoryChartItemResponse> values = [];
  DateTime lastAccessTime = DateTime.now();
  DateTime lastRequestTime = DateTime.now().add(const Duration(days: -1));

  HistoryDataRange(this.beginTime, this.groupTimeRange) {
    endTime = beginTime + groupTimeRange * historyDataRangeSize;
  }

  void requestForce(Connection connection, String itemName) {
    complete = false;
    request(connection, itemName);
  }

  bool isFresh() {
    DateTime now = DateTime.now();
    int currentTime = now.microsecondsSinceEpoch;
    int avgTimeOfThisBlock = ((beginTime + endTime) / 2).round();
    int diff = (avgTimeOfThisBlock - currentTime).abs();
    //print("diff: $diff");
    if (diff < historyDataRangeDuration(groupTimeRange)) {
      return true;
    }
    return false;
  }

  void request(Connection connection, String itemName) {
    DateTime now = DateTime.now();
    lastAccessTime = now;

    if (processing) {
      return;
    }
    if (complete) {
      return;
    }

    int timeDiff = now.difference(lastRequestTime).inMilliseconds;
    if (timeDiff < 1000) {
      return;
    }
    // print("timediff: $timeDiff");
    lastRequestTime = DateTime.now();

    List<DataItemHistoryChartItemRequest> reqItems = [];
    DataItemHistoryChartItemRequest req = DataItemHistoryChartItemRequest(
        itemName, beginTime, endTime, groupTimeRange, "");
    reqItems.add(req);

    processing = true;
    Repository()
        .client(connection)
        .dataItemHistoryChart(reqItems)
        .then((value) {
      values = value.items;
      complete = true;
      processing = false;
    }).catchError((e) {
      print("ERROR LOAD DATA $e");
      processing = false;
    });
  }
}
