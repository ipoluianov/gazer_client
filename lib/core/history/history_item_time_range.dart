import '../protocol/dataitem/data_item_history_chart.dart';
import '../repository.dart';
import '../workspace/workspace.dart';
import 'history_get_request.dart';
import 'history_item_time_range_get_history_result.dart';
import 'history_loaded_range.dart';
import 'history_loading_task.dart';
import 'history_need_to_load.dart';
import 'request_to_node.dart';

import 'package:intl/intl.dart' as international;

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
