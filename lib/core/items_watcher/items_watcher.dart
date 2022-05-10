import 'dart:async';

import 'package:gazer_client/core/protocol/dataitem/data_item_list.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import '../repository.dart';

class ItemsWatcher {
  Map<String, ItemsWatcherNode> nodes = {};
  late Timer _timer;
  ItemsWatcher() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      for (var nodeKey in nodes.keys) {
        nodes[nodeKey]!.load();
        nodes[nodeKey]!.clear();
      }
    });
  }

  DataItemInfo value(Connection conn, String itemName) {
    //return DataItemInfo(0, itemName, "val", 0, "uom");
    return Repository().history.value(conn, itemName);

    if (nodes.containsKey(conn.id)) {
      return nodes[conn.id]!.value(itemName);
    }
    ItemsWatcherNode node = ItemsWatcherNode(conn);
    nodes[conn.id] = node;
    return nodes[conn.id]!.value(itemName);
  }
}

class WatcherItem {
  DataItemInfo value;
  DateTime lastAccessDateTime;
  WatcherItem(this.value, this.lastAccessDateTime);
}

class ItemsWatcherNode {
  final Connection connection;
  Map<String, WatcherItem> items = {};

  ItemsWatcherNode(this.connection);

  DataItemInfo value(String itemName) {
    if (items.containsKey(itemName)) {
      items[itemName]!.lastAccessDateTime = DateTime.now();
      return items[itemName]!.value;
    }
    items[itemName] = WatcherItem(DataItemInfo.makeDefault(), DateTime.now());
    return items[itemName]!.value;
  }

  void clear() {
    var dt = DateTime.now();
    List<String> itemsToRemove = [];
    for (var itemName in items.keys) {
      if (items[itemName]!.lastAccessDateTime.microsecondsSinceEpoch < dt.add(const Duration(seconds: -10)).microsecondsSinceEpoch) {
        itemsToRemove.add(itemName);
      }
    }

    for (var itemName in itemsToRemove) {
      items.remove(itemName);
      print("item removed from watcher ${itemName}");
    }
  }

  void load() {
    List<String> itemNames = [];
    for (var itemName in items.keys) {
      itemNames.add(itemName);
    }
    if (itemNames.isNotEmpty) {
      //print("data item value ${itemNames.length}");
      Repository().client(connection).dataItemList(itemNames).then((value) {
        for (var item in value.items) {
          if (items.containsKey(item.name)) {
            items[item.name]!.value = item;
          }
        }
      });
    }
  }
}

