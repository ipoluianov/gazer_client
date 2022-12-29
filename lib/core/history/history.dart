import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gazer_client/core/protocol/dataitem/data_item_history_chart.dart';
import 'package:gazer_client/core/protocol/dataitem/data_item_list.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:intl/intl.dart' as international;

import '../repository.dart';

class History {
  Map<String, HistoryNode> nodes = {};
  late Timer _timer;
  late Timer _timerRequester;

  History() {
    _timer = Timer.periodic(const Duration(milliseconds: 5000), (timer) {
      clear();
    });
    _timerRequester =
        Timer.periodic(const Duration(milliseconds: 250), (timer) {
      request();
    });
  }

  int alignGroupTimeRange(int groupTimeRange) {
    if (groupTimeRange >= 1 && groupTimeRange < 2) {
      groupTimeRange = 1;
    }

    if (groupTimeRange >= 2 && groupTimeRange < 5) {
      groupTimeRange = 2;
    }

    if (groupTimeRange >= 5 && groupTimeRange < 10) {
      groupTimeRange = 5;
    }

    if (groupTimeRange >= 10 && groupTimeRange < 20) {
      groupTimeRange = 10;
    }

    if (groupTimeRange >= 20 && groupTimeRange < 50) {
      groupTimeRange = 20;
    }

    if (groupTimeRange >= 50 && groupTimeRange < 100) {
      groupTimeRange = 50;
    }

    if (groupTimeRange >= 100 && groupTimeRange < 200) {
      groupTimeRange = 100;
    }

    if (groupTimeRange >= 200 && groupTimeRange < 500) {
      groupTimeRange = 200;
    }

    if (groupTimeRange >= 500 && groupTimeRange < 1000) {
      groupTimeRange = 500;
    }

    if (groupTimeRange >= 1000 && groupTimeRange < 2000) {
      groupTimeRange = 1000;
    }

    if (groupTimeRange >= 2000 && groupTimeRange < 5000) {
      groupTimeRange = 2000;
    }

    if (groupTimeRange >= 5000 && groupTimeRange < 10000) {
      groupTimeRange = 5000;
    }

    if (groupTimeRange >= 10000 && groupTimeRange < 20000) {
      groupTimeRange = 10000;
    }

    if (groupTimeRange >= 20000 && groupTimeRange < 50000) {
      groupTimeRange = 20000;
    }

    if (groupTimeRange >= 50000 && groupTimeRange < 100000) {
      groupTimeRange = 50000;
    }

    if (groupTimeRange >= 100000 && groupTimeRange < 200000) {
      groupTimeRange = 100000; // By 0.2 sec
    }

    if (groupTimeRange >= 200000 && groupTimeRange < 500000) {
      groupTimeRange = 200000; // By 0.2 sec
    }

    if (groupTimeRange >= 500000 && groupTimeRange < 1000000) {
      groupTimeRange = 500000; // By 0.5 sec
    }

    if (groupTimeRange >= 1000000 && groupTimeRange < 5 * 1000000) {
      groupTimeRange = 1000000; // By 1 sec
    }

    if (groupTimeRange >= 5 * 1000000 && groupTimeRange < 15 * 1000000) {
      groupTimeRange = 5 * 1000000; // By 5 sec
    }

    if (groupTimeRange >= 15 * 1000000 && groupTimeRange < 30 * 1000000) {
      groupTimeRange = 15 * 1000000; // By 15 sec
    }

    if (groupTimeRange >= 30 * 1000000 && groupTimeRange < 60 * 1000000) {
      groupTimeRange = 30 * 1000000; // By 30 sec
    }

    if (groupTimeRange >= 60 * 1000000 && groupTimeRange < 2 * 60 * 1000000) {
      groupTimeRange = 60 * 1000000; // By minute
    }

    if (groupTimeRange >= 2 * 60 * 1000000 &&
        groupTimeRange < 3 * 60 * 1000000) {
      groupTimeRange = 2 * 60 * 1000000; // By 2 minute
    }

    if (groupTimeRange >= 3 * 60 * 1000000 &&
        groupTimeRange < 4 * 60 * 1000000) {
      groupTimeRange = 3 * 60 * 1000000; // By 3 minute
    }

    if (groupTimeRange >= 4 * 60 * 1000000 &&
        groupTimeRange < 5 * 60 * 1000000) {
      groupTimeRange = 4 * 60 * 1000000; // By 4 minute
    }

    if (groupTimeRange >= 5 * 60 * 1000000 &&
        groupTimeRange < 10 * 60 * 1000000) {
      groupTimeRange = 5 * 60 * 1000000; // By 5 minute
    }

    if (groupTimeRange >= 10 * 60 * 1000000 &&
        groupTimeRange < 20 * 60 * 1000000) {
      groupTimeRange = 10 * 60 * 1000000; // By 10 minute
    }

    if (groupTimeRange >= 20 * 60 * 1000000 &&
        groupTimeRange < 30 * 60 * 1000000) {
      groupTimeRange = 20 * 60 * 1000000; // By 20 minute
    }

    if (groupTimeRange >= 30 * 60 * 1000000 &&
        groupTimeRange < 60 * 60 * 1000000) {
      groupTimeRange = 30 * 60 * 1000000; // By 30 minute
    }

    if (groupTimeRange >= 60 * 60 * 1000000 &&
        groupTimeRange < 3 * 60 * 60 * 1000000) {
      groupTimeRange = 60 * 60 * 1000000; // By 60 minutes
    }

    if (groupTimeRange >= 3 * 60 * 60 * 1000000 &&
        groupTimeRange < 6 * 60 * 60 * 1000000) {
      groupTimeRange = 3 * 60 * 60 * 1000000; // By 3 Hours
    }

    if (groupTimeRange >= 6 * 60 * 60 * 1000000 &&
        groupTimeRange < 12 * 60 * 60 * 1000000) {
      groupTimeRange = 6 * 60 * 60 * 1000000; // By 6 Hours
    }

    if (groupTimeRange >= 12 * 60 * 60 * 1000000 &&
        groupTimeRange < 24 * 60 * 60 * 1000000) {
      groupTimeRange = 12 * 60 * 60 * 1000000; // By 6 Hours
    }

    if (groupTimeRange >= 24 * 60 * 60 * 1000000) {
      groupTimeRange = 24 * 60 * 60 * 1000000; // By day
    }

    return groupTimeRange;
  }

  List<DataItemHistoryChartItemValueResponse> getHistory(Connection conn,
      String itemName, int minTime, int maxTime, int groupTimeRange) {
    int groupTimeRangeOriginal = groupTimeRange;
    groupTimeRange = alignGroupTimeRange(groupTimeRange);
    //print("getHistory $groupTimeRangeOriginal => $groupTimeRange ${(maxTime - minTime) / groupTimeRangeOriginal}");

    if (nodes.containsKey(conn.id)) {
      return nodes[conn.id]!
          .getHistory(itemName, minTime, maxTime, groupTimeRange);
    }

    HistoryNode node = HistoryNode(conn);
    nodes[conn.id] = node;
    return nodes[conn.id]!
        .getHistory(itemName, minTime, maxTime, groupTimeRange);
  }

  DataItemInfo value(Connection conn, String itemName) {
    if (nodes.containsKey(conn.id)) {
      return nodes[conn.id]!.value(itemName);
    }
    HistoryNode node = HistoryNode(conn);
    nodes[conn.id] = node;
    return nodes[conn.id]!.value(itemName);
  }

  void clearItem(Connection conn, String itemName) {
    if (nodes.containsKey(conn.id)) {
      nodes[conn.id]!.clearItem(itemName);
    }
  }

  void request() {
    for (var nodeKey in nodes.keys) {
      nodes[nodeKey]!.request();
    }
  }

  List<HistoryLoadingTask> getLoadingTasks(Connection conn, String itemName) {
    if (nodes.containsKey(conn.id)) {
      return nodes[conn.id]!.getLoadingTasks(itemName);
    }
    return [];
  }

  void clear() {
    for (var nKey in nodes.keys) {
      nodes[nKey]!.clear();
    }
  }

  double historySize() {
    double result = 0;
    return result;
  }
}

class RequestToNode {
  Connection connection;
  String itemName;
  int minTime;
  int maxTime;
  int groupTimeRange;
  HistoryItemTimeRange range;
  RequestToNode(this.connection, this.itemName, this.minTime, this.maxTime,
      this.groupTimeRange, this.range);
}

class HistoryNode {
  final Connection connection;
  Map<String, HistoryItem> items = {};
  List<RequestToNode> requests = [];

  HistoryNode(this.connection);

  List<DataItemHistoryChartItemValueResponse> getHistory(
      String itemName, int minTime, int maxTime, int groupTimeRange) {
    if (items.containsKey(itemName)) {
      var res = items[itemName]!.getHistory(minTime, maxTime, groupTimeRange);
      requests.addAll(res.requests);
      return res.values;
    }

    HistoryItem item = HistoryItem(connection, itemName,
        DataItemInfo(0, itemName, "", "", 0, ""), DateTime.now());
    items[itemName] = item;
    var res = items[itemName]!.getHistory(minTime, maxTime, groupTimeRange);
    requests.addAll(res.requests);
    return res.values;
  }

  DataItemInfo value(String itemName) {
    if (items.containsKey(itemName)) {
      items[itemName]!.lastAccessDateTime = DateTime.now();
      return items[itemName]!.getValue();
    }
    HistoryItem item = HistoryItem(connection, itemName,
        DataItemInfo(0, itemName, "", "", 0, ""), DateTime.now());
    items[itemName] = item;
    return items[itemName]!.getValue();
  }

  void clearItem(String itemName) {
    if (items.containsKey(itemName)) {
      items.remove(itemName);
    }
  }

  List<HistoryLoadingTask> getLoadingTasks(String itemName) {
    if (items.containsKey(itemName)) {
      return items[itemName]!.getLoadingTasks();
    }
    return [];
  }

  void request() {
    List<DataItemHistoryChartItemRequest> reqItems = [];

    for (var req in requests) {
      reqItems.add(DataItemHistoryChartItemRequest(
          req.itemName, req.minTime, req.maxTime, req.groupTimeRange, ""));
    }

    for (var item in items.values) {
      if (item.checkCurrentValueTTL()) {
        reqItems
            .add(DataItemHistoryChartItemRequest(item.itemName, 0, 0, 0, ""));
      }
    }

    if (reqItems.isEmpty) {
      return;
    }

    var currentRequests = requests;

    Repository()
        .client(connection)
        .dataItemHistoryChart(reqItems)
        .then((value) {
      List<DataItemHistoryChartItemResponse> receivedItems = value.items;
      for (var item in receivedItems) {
        //print("received ${item.name}");
        // Set current value
        if (items.containsKey(item.name)) {
          items[item.name]!.setValue(item.currentValue);
        }
        // Insert values to Range
        if (item.groupTimeRange > 0) {
          bool foundReq = false;
          for (var req in currentRequests) {
            if (req.itemName == item.name &&
                req.groupTimeRange == item.groupTimeRange) {
              req.range.insertValues(item);
              req.range.removeLoadingTask(req.minTime, req.maxTime);
              foundReq = true;
              break;
            }
          }
          if (!foundReq) {
            print("history req not found ${item.name}");
          }
        }
      }
    }).catchError((e) {
      print("ERROR LOAD DATA $e");
      //range.removeLoadingTask(minTime, maxTime);
      for (var req in currentRequests) {
        req.range.removeLoadingTask(req.minTime, req.maxTime);
      }
    });

    requests = [];
  }

  void clear() {
    for (var iKey in items.keys) {
      items[iKey]!.clear();
    }
  }
}

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

class HistoryLoadedRange {
  int minTime;
  int maxTime;
  HistoryLoadedRange(this.minTime, this.maxTime);
}

class HistoryNeedToLoad {
  int minTime;
  int maxTime;
  HistoryNeedToLoad(this.minTime, this.maxTime);
}

class HistoryLoadingTask {
  bool started = false;
  int minTime;
  int maxTime;
  HistoryLoadingTask(this.minTime, this.maxTime);
}

class HistoryGetRequest {
  int minTime;
  int maxTime;
  DateTime dt;
  HistoryGetRequest(this.minTime, this.maxTime, this.dt);
}

class HistoryItemTimeRangeGetHistoryResult {
  List<DataItemHistoryChartItemValueResponse> values;
  List<RequestToNode> requests;
  HistoryItemTimeRangeGetHistoryResult(this.values, this.requests);
}

class HistoryItemTimeRange {
  final Connection connection;
  String itemName;
  int groupTimeRange;
  List<DataItemHistoryChartItemValueResponse> values = [];
  int lastTaskTime = 0;

  DateTime _dtLastGetHistory = DateTime.now();
  DateTime _dtLastClearProcedure = DateTime.now();
  bool needToFastLoad = false;

  List<HistoryLoadedRange> loadedRanges = [];
  List<HistoryLoadingTask> loadingTasks = [];
  List<HistoryGetRequest> getHistoryRequests = [];

  HistoryItemTimeRange(this.connection, this.itemName, this.groupTimeRange);

  HistoryItemTimeRangeGetHistoryResult getHistory(int minTime, int maxTime) {
    getHistoryRequests.add(HistoryGetRequest(minTime, maxTime, DateTime.now()));
    var requests = checkValues(minTime, maxTime);
    _dtLastGetHistory = DateTime.now();
    //print(getHistoryRequests.length);

    List<DataItemHistoryChartItemValueResponse> result = [];
    for (var v in values) {
      if (v.datetimeFirst >= minTime && v.datetimeLast <= maxTime) {
        result.add(v);
      }
    }

    return HistoryItemTimeRangeGetHistoryResult(result, requests);
  }

  List<RequestToNode> checkValues(int minTime, int maxTime) {
    List<RequestToNode> requests = [];
    int currentTime = DateTime.now().microsecondsSinceEpoch;

    int delay = 1000000;
    if (needToFastLoad) {
      delay = 10000;
    }

    if (currentTime - lastTaskTime < delay) {
      return requests;
    }

    if (needToFastLoad) {
      //print("fast load");
    } else {
      //print("reg load");
    }

    lastTaskTime = currentTime;

    for (var range in loadedRanges) {
      if (minTime >= range.minTime && maxTime <= range.maxTime) {
        return requests;
      }
    }

    List<HistoryNeedToLoad> needToLoad = [];

    int workFrom = minTime;

    //print("need ${minTime} ${maxTime}");
    for (var range in loadedRanges) {
      //print("range ${range.minTime} ${range.maxTime}");
      if (range.minTime > maxTime) {
        break;
      }

      if (range.minTime > workFrom) {
        HistoryNeedToLoad needToLoadItem =
            HistoryNeedToLoad(workFrom, range.minTime);
        needToLoad.add(needToLoadItem);
      }
      workFrom = range.maxTime;
      if (workFrom < minTime) {
        workFrom = minTime;
      }
    }

    if (maxTime > workFrom) {
      HistoryNeedToLoad needToLoadItem = HistoryNeedToLoad(workFrom, maxTime);
      needToLoad.add(needToLoadItem);
    }

    for (var needToLoadItem in needToLoad) {
      bool alreadyLoading = false;
      for (var loadingTask in loadingTasks) {
        if (loadingTask.minTime == minTime && loadingTask.maxTime == maxTime) {
          alreadyLoading = true;
          break;
        }
      }

      if (alreadyLoading) {
        continue;
      }

      if (loadingTasks.isEmpty) {
        needToFastLoad = false;
        int diff = needToLoadItem.maxTime - needToLoadItem.minTime;
        int expectedCount = (diff / groupTimeRange).round();
        int needExpectedCount = 4000;
        var mTime = needToLoadItem.minTime;

        var beginTime = mTime;
        var endTime = mTime + needExpectedCount * groupTimeRange;
        if (endTime > needToLoadItem.maxTime) {
          endTime = needToLoadItem.maxTime;
        } else {
          needToFastLoad = true;
        }
        if (endTime > beginTime) {
          HistoryLoadingTask task = HistoryLoadingTask(beginTime, endTime);
          loadingTasks.add(task);
          //print("add task ${task.minTime} ${task.maxTime} ${task.maxTime - task.minTime}");
          requests.add(RequestToNode(connection, itemName, task.minTime,
              task.maxTime, groupTimeRange, this));
        }
      }
    }
    return requests;
  }

  void removeLoadingTask(int minTime, int maxTime) {
    loadingTasks.removeWhere((element) =>
        (element.minTime == minTime && element.maxTime == maxTime));
  }

  void loadData(int minTime, int maxTime, int values) {
    //print("history - loadData grTimeRange: $groupTimeRange");
    List<DataItemHistoryChartItemRequest> reqItems = [];
    reqItems.add(DataItemHistoryChartItemRequest(
        itemName, minTime, maxTime, groupTimeRange, ""));
    Repository()
        .client(connection)
        .dataItemHistoryChart(reqItems)
        .then((value) {
      List<DataItemHistoryChartItemResponse> items = value.items;
      if (items.isNotEmpty) {
        insertValues(value.items[0]);
      }
      removeLoadingTask(minTime, maxTime);
    }).catchError((e) {
      print("ERROR LOAD DATA $e");
      removeLoadingTask(minTime, maxTime);
    });
  }

  HistoryGetRequest? getActiveGetHistoryRange(DateTime dt) {
    bool processed = false;
    HistoryGetRequest? result;
    for (var i in getHistoryRequests) {
      if (i.dt.microsecondsSinceEpoch < dt.microsecondsSinceEpoch) {
        continue;
      }
      if (processed) {
        if (i.minTime < result!.minTime) {
          result.minTime = i.minTime;
        }
        if (i.maxTime > result.maxTime) {
          result.maxTime = i.maxTime;
        }
      } else {
        result = HistoryGetRequest(i.minTime, i.maxTime, DateTime.now());
        processed = true;
      }
    }
    return result;
  }

  void clear() {
    var now = DateTime.now();
    if (now.difference(_dtLastClearProcedure).inMilliseconds < 5000) {
      return;
    }

    _dtLastClearProcedure = DateTime.now();

    if (now.difference(_dtLastGetHistory).inSeconds > 5) {
      if (values.isNotEmpty) {
        //print("History Clear ${itemName} in $groupTimeRange count: ${values.length}");
        values.clear();
        loadedRanges.clear();
      }
    }

    var dtOldThreshold = DateTime.now().add(const Duration(seconds: -5));
    var lastActiveRange = getActiveGetHistoryRange(dtOldThreshold);
    if (lastActiveRange != null) {
      //print("--------- Clear ---------");
      //final f = international.NumberFormat("#.#");
      /*String minT = timeFormat.format(DateTime.fromMicrosecondsSinceEpoch(lastActiveRange.minTime));
      String maxT = timeFormat.format(DateTime.fromMicrosecondsSinceEpoch(lastActiveRange.maxTime));
      String perT = f.format((lastActiveRange.maxTime - lastActiveRange.minTime) / 1000000);
      String perTmin = f.format((lastActiveRange.maxTime - lastActiveRange.minTime) / 60000000);*/

      //int countOfGetHistoryRequestsBefore = getHistoryRequests.length;
      getHistoryRequests.removeWhere((element) =>
          element.dt.microsecondsSinceEpoch <
          dtOldThreshold.microsecondsSinceEpoch);
      //int countOfGetHistoryRequestsAfter = getHistoryRequests.length;
      //int removedGetHistoryRequests = countOfGetHistoryRequestsBefore - countOfGetHistoryRequestsAfter;

      {
        List<HistoryLoadedRange> rangesForDelete = [];
        for (var loadedRange in loadedRanges) {
          var newLoadedRangeMin = loadedRange.minTime;
          var newLoadedRangeMax = loadedRange.maxTime;
          if (lastActiveRange.minTime > loadedRange.minTime) {
            newLoadedRangeMin = lastActiveRange.minTime;
          }
          if (lastActiveRange.maxTime < loadedRange.maxTime) {
            newLoadedRangeMax = lastActiveRange.maxTime;
          }
          if (newLoadedRangeMin >= newLoadedRangeMax) {
            rangesForDelete.add(loadedRange);
          } else {
            loadedRange.minTime = newLoadedRangeMin;
            loadedRange.maxTime = newLoadedRangeMax;
          }
        }

        for (var loadedRange in rangesForDelete) {
          loadedRanges.removeWhere((element) =>
              element.minTime == loadedRange.minTime &&
              element.maxTime == loadedRange.maxTime);
          //values.removeWhere((element) => element.datetimeFirst >= loadedRange.minTime && element.datetimeLast <= loadedRange.maxTime);
        }

        /*print("");
        print("----------------------- $groupTimeRange");
        for (var loadedRange in loadedRanges) {
          print("r: ${loadedRange.minTime} ${loadedRange.maxTime}");
        }

        var valToRemove = values.where((element) {
          bool toDelete = true;
          for (var loadedRange in loadedRanges) {
            if (element.datetimeFirst >= loadedRange.minTime && element.datetimeLast <= (loadedRange.maxTime + (groupTimeRange - 1))) {
              toDelete = false;
              break;
            }
          }
          return toDelete;
        });
        print("--------------- remove: ${valToRemove.length}");
        for (var iii in valToRemove) {
          print("v:                  ${iii.datetimeFirst} ${iii.datetimeLast}");
        }*/

        values.removeWhere((element) {
          bool toDelete = true;
          for (var loadedRange in loadedRanges) {
            if (element.datetimeFirst >= loadedRange.minTime &&
                element.datetimeLast <=
                    (loadedRange.maxTime + (groupTimeRange - 1))) {
              toDelete = false;
              break;
            }
          }
          return toDelete;
        });
      }

      /*print("Clear minActiveMin at ${timeFormat.format(
          DateTime.now())}: $minT - $maxT period: $perT sec / $perTmin min removed: $removedGetHistoryRequests currentCount: $countOfGetHistoryRequestsAfter");
*/
      /*for (var loadedRange in loadedRanges) {
        //print("loaded range: ${timeFormat.format(DateTime.fromMicrosecondsSinceEpoch(loadedRange.minTime))} ${timeFormat.format(DateTime.fromMicrosecondsSinceEpoch(loadedRange.maxTime))}");
      }
      if (values.length > 0) {
        String dtFirstItem = timeFormat.format(DateTime.fromMicrosecondsSinceEpoch(values[0].datetimeFirst));
        String dtLastItem = timeFormat.format(DateTime.fromMicrosecondsSinceEpoch(values[values.length - 1].datetimeLast));
        //print("loaded items: $dtFirstItem $dtLastItem items count: ${values.length}");
      }*/
    }
  }

  international.DateFormat timeFormat = international.DateFormat("HH:mm:ss");

  void insertValues(DataItemHistoryChartItemResponse response) {
    //print("Loaded###  ${response.dtBegin} - ${response.dtEnd}");
    //print("history - insertValues ${response.items.length} to ${values.length} group: ${groupTimeRange}");
    values.removeWhere((element) =>
        element.datetimeFirst >= response.dtBegin &&
        element.datetimeLast < response.dtEnd);
    values.addAll(response.items);
    values.sort((q, w) {
      if (q.datetimeFirst < w.datetimeFirst) {
        return -1;
      }
      if (q.datetimeFirst == w.datetimeFirst) {
        return 0;
      }
      return 1;
    });
    var range = HistoryLoadedRange(response.dtBegin, response.dtEnd);
    loadedRanges.add(range);

    loadedRanges.sort((q, w) {
      if (q.minTime < w.minTime) {
        return -1;
      }
      if (q.minTime == w.minTime) {
        return 0;
      }
      return 1;
    });

    if (loadedRanges.isNotEmpty) {
      List<HistoryLoadedRange> newLoadedRanges = [];
      var currentLoadedRange =
          HistoryLoadedRange(loadedRanges[0].minTime, loadedRanges[0].maxTime);
      for (var range in loadedRanges) {
        // if range has margin
        if (range.minTime > (currentLoadedRange.maxTime + 1)) {
          newLoadedRanges.add(currentLoadedRange);
          currentLoadedRange = HistoryLoadedRange(range.minTime, range.maxTime);
          continue;
        }

        // expand current range if needed
        if (range.maxTime > currentLoadedRange.maxTime) {
          currentLoadedRange.maxTime = range.maxTime;
        }
      }
      newLoadedRanges.add(currentLoadedRange);

      loadedRanges = newLoadedRanges;
      //print(loadedRanges.length);
    }

    // Last time range must be less than last timestamp of values
    if (values.isNotEmpty) {
      var lastDateTime = values[values.length - 1].datetimeFirst;
      for (int index = 0; index < loadedRanges.length; index++) {
        var range = loadedRanges[index];
        if (lastDateTime >= range.minTime && lastDateTime <= range.maxTime) {
          range.maxTime = lastDateTime;
          if (range.maxTime <= range.minTime) {
            loadedRanges.removeAt(index);
          }
          break;
        }
      }
    } else {
      var lastDateTime = DateTime.now().microsecondsSinceEpoch.toInt();
      for (int index = 0; index < loadedRanges.length; index++) {
        range.maxTime = lastDateTime;
        if (range.maxTime <= range.minTime) {
          loadedRanges.removeAt(index);
        }
        break;
      }
    }
  }
}
