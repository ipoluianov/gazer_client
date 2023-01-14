import 'package:gazer_client/core/history/request_to_node.dart';

import '../protocol/dataitem/data_item_history_chart.dart';
import '../protocol/dataitem/data_item_list.dart';
import '../repository.dart';
import '../workspace/workspace.dart';
import 'history_item.dart';
import 'history_loading_task.dart';

class HistoryNode {
  final Connection connection;
  Map<String, HistoryItem> items = {};
  List<RequestToNode> requests = [];

  HistoryNode(this.connection);

  HistoryItem getHistoryItem(String itemName) {
    if (items.containsKey(itemName)) {
      HistoryItem? item = items[itemName];
      if (item != null) {
        return item;
      }
    }
    HistoryItem item = HistoryItem(connection, itemName,
        DataItemInfo(0, itemName, "", "", 0, ""), DateTime.now());
    items[itemName] = item;
    return item;
  }

  List<DataItemHistoryChartItemValueResponse> getHistory(
      String itemName, int minTime, int maxTime, int groupTimeRange) {
    var res =
        getHistoryItem(itemName).getHistory(minTime, maxTime, groupTimeRange);
    requests.addAll(res.requests);
    return res.values;
  }

  DataItemInfo value(String itemName) {
    return getHistoryItem(itemName).getValue();
  }

  void clearItemCache(String itemName) {
    if (items.containsKey(itemName)) {
      items.remove(itemName);
    }
  }

  void cleanUp() {
    for (var iKey in items.keys) {
      items[iKey]!.cleanUp();
    }
  }

  List<HistoryLoadingTask> getLoadingTasks(String itemName) {
    return getHistoryItem(itemName).getLoadingTasks();
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

    //print("REQUEST ${DateTime.now()}");
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
              print("insert ${item.dtBegin}");
              req.range.removeLoadingTask(req.minTime, req.maxTime);
              foundReq = true;
              break;
            }
          }
          if (!foundReq) {
            //print("history req not found ${item.name}");
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
}
