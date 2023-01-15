import '../protocol/dataitem/data_item_history_chart.dart';
import '../protocol/dataitem/data_item_list.dart';
import '../repository.dart';
import '../workspace/workspace.dart';
import 'history_item.dart';
import 'history_loading_task.dart';

class HistoryNode {
  final Connection connection;
  Map<String, HistoryItem> items = {};

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
    return res;
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
    List<String> itemNames = [];

    for (var item in items.values) {
      if (item.checkCurrentValueTTL()) {
        itemNames.add(item.itemName);
      }
    }

    if (itemNames.isEmpty) {
      return;
    }

    Repository().client(connection).dataItemList(itemNames).then((value) {
      DataItemListResponse resp = value;
      for (var item in resp.items) {
        //print("received ${item.name}");
        // Set current value
        if (items.containsKey(item.name)) {
          items[item.name]!.setValue(item);
        }
      }
    }).catchError((e) {
      print("ERROR LOAD DATA $e");
    });

    //requests = [];
  }
}
