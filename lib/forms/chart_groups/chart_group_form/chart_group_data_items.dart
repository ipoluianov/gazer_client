import 'package:flutter/material.dart';
import 'package:gazer_client/core/protocol/service/service_lookup.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

class ChartGroupDataItems extends StatefulWidget {
  final Connection connection;
  const ChartGroupDataItems(this.connection, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChartGroupDataItemsState();
  }
}

class ChartGroupDataItemsState extends State<ChartGroupDataItems> {
  @override
  void initState() {
    super.initState();
    load();
  }

  late ServiceLookupResponse lookupResponse;

  List<DataItemsGroup> _groups = [];

  void load() {
    Repository().client(widget.connection).serviceLookup("data-item", "").then((value) {
      List<DataItemsGroup> groups = [];
      Map<String, DataItemsGroup> groupsMap = {};
      for (var item in value.result.rows) {
        var parts = item.cells[1].split("/");
        var displayParts = item.cells[2].split("/");
        if (parts.isNotEmpty && displayParts.isNotEmpty) {
          var groupName = parts[0];
          var groupDisplayName = displayParts[0];
          if (groupsMap.containsKey(groupName)) {
            continue;
          }
          var group = DataItemsGroup(groupName, groupDisplayName);
          groupsMap[groupName] = group;
          groups.add(group);
        }
      }

      for (var item in value.result.rows) {
        var name = item.cells[1];
        int posOfSlash = name.indexOf("/");
        if (posOfSlash > -1) {
          var groupName = name.substring(0, posOfSlash);
          var itemName = name.substring(posOfSlash + 1);
          if (groupsMap.containsKey(groupName)) {
            groupsMap[groupName]?.items.add(DataItemsItem(name, itemName));
          }
        }
      }

      _groups = groups;

      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 100, maxWidth: 265),
      color: Colors.blueAccent.withOpacity(0.1),
      padding: const EdgeInsets.all(0),
      margin: const EdgeInsets.only(bottom: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: _groups.map((e) {
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        e.expanded = !e.expanded;
                      });
                    },
                    child: Container(
                      color: Colors.black,
                      child: Row(
                        children: [
                          const Icon(Icons.blur_on,),
                          Expanded(
                            child: Draggable<DataItemsObject>(
                              data: DataItemsObject(e.name, e.name, DataItemsObjectType.unit),
                              feedback: Container(
                                color: Colors.deepOrange,
                                height: 30,
                                width: 200,
                                child: const Icon(Icons.directions_run),
                              ),
                              child: Container(
                                color: Colors.black26,
                                padding: EdgeInsets.all(6),
                                margin: EdgeInsets.all(3),
                                child: Text(
                                  e.displayName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          e.expanded ? const Icon(Icons.keyboard_arrow_up_outlined) : const Icon(Icons.keyboard_arrow_down_outlined),
                        ],
                      ),
                    ),
                  ),
                ),
                e.expanded
                    ? Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: e.items.map((item) {
                            return Draggable<DataItemsObject>(
                              data: DataItemsObject(item.fullName, item.name, DataItemsObjectType.dataItem),
                              feedback: Container(
                                color: Colors.deepOrange,
                                height: 30,
                                width: 200,
                                child: const Icon(Icons.directions_run),
                              ),
                              child: MouseRegion(
                                cursor: SystemMouseCursors.move,
                                child: Container(
                                  color: Colors.black38,
                                  margin: const EdgeInsets.all(3),
                                  padding: const EdgeInsets.all(3),
                                  child: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      )
                    : Container(),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class DataItemsGroup {
  String name;
  String displayName;
  bool expanded = false;
  List<DataItemsItem> items = [];
  DataItemsGroup(this.name, this.displayName);
}

class DataItemsItem {
  String fullName;
  String name;
  DataItemsItem(this.fullName, this.name);
}

class DataItemsObject {
  String name;
  DataItemsObjectType type;
  String displayName;
  DataItemsObject(this.name, this.displayName, this.type);
}

enum DataItemsObjectType {
  dataItem,
  unit
}