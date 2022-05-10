import 'dart:convert';

import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/forms/units/unit_edit/config/unit_config_object.dart';
import 'package:gazer_client/forms/units/unit_edit/config/unit_default_value.dart';
import 'package:flutter/material.dart';

class UnitConfigTable extends StatefulWidget {
  final GazerLocalClient client;
  final Map<String, dynamic> meta;
  Map<String, dynamic> config;
  UnitConfigTable(this.client, this.meta, this.config, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UnitConfigTableState();
  }
}

class UnitConfigTableState extends State<UnitConfigTable> with TickerProviderStateMixin {
  int selectedIndex = 0;

  @override
  void initState() {
    if (!widget.config.containsKey(widget.meta['name'])) {
      widget.config[widget.meta['name']] = [];
      try {
        var decRes = jsonDecode(widget.meta['default_value']);
        //print("decRes" + decRes.toString());
        widget.config[widget.meta['name']] = decRes;
      } catch (err) {
        //print("decRes error" + err.toString());
        widget.config[widget.meta['name']] = [];
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool fixedRows() {
    return widget.meta['format'] == "fixed-rows";
  }

  void deleteRow(int index) {
    //print('Delete $index');
    setState(() {
      widget.config[widget.meta['name']].removeAt(index);
      selectedIndex = -1;
    });
  }

  Widget buildWide(BuildContext context) {
    var rowsMap = widget.config[widget.meta['name']].asMap();

    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTableToolbar(context),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTable(context),
              Expanded(
                child: buildTableItem(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildNarrow(BuildContext context) {
    var rowsMap = widget.config[widget.meta['name']].asMap();

    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildTableToolbar(context),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildTable(context),
            ],
          ),
          buildTableItem(context),
        ],
      ),
    );
  }

  Widget buildTableToolbar(BuildContext context) {
    return Container(
      color: Colors.black38,
      child: ButtonBar(
        buttonPadding: const EdgeInsets.all(10),
        alignment: MainAxisAlignment.start,
        children: [
          Text(
            widget.meta['display_name'],
            style: const TextStyle(fontSize: 16),
          ),
          (fixedRows() == false)
              ? ElevatedButton(
                  onPressed: () {
                    setState(() {
                      Map<String, dynamic> defObject = <String, dynamic>{};
                      for (var item in widget.meta['children']) {
                        var colName = item['name'];
                        defObject[colName] = defaultValue(item['type'], item['default_value'], widget.meta['format']);
                      }
                      widget.config[widget.meta['name']].add(defObject);
                    });
                  },
                  child: const Icon(Icons.add))
              : Container(),
        ],
      ),
    );
  }

  Widget buildTable(BuildContext context) {
    return buildTableWide(context);
  }

  Widget buildTableWide(BuildContext context) {
    var rowsMap = widget.config[widget.meta['name']].asMap();
    return Container(
      child: DataTable(
          headingRowColor: MaterialStateColor.resolveWith((states) => Colors.black26),
          showCheckboxColumn: false,
          columns: [
            ...widget.meta['children'].map<DataColumn>((col) {
              var colName = col['display_name'];
              return DataColumn(label: Text(colName));
            }).toList(),
            const DataColumn(label: Text("-"))
          ],
          rows: rowsMap.keys.map<DataRow>((index) {
            return DataRow(
              selected: selectedIndex == index,
              onSelectChanged: (bool? selected) {
                setState(() {
                  selectedIndex = index;
                });
              },
              cells: [
                ...widget.meta['children'].map<DataCell>((col) {
                  var colName = col['name'];
                  var cellVal = rowsMap[index][colName];
                  return DataCell(
                    Container(
                      constraints: const BoxConstraints(minWidth: 50, maxWidth: 50),
                      child: Text('$cellVal'),
                    ),
                  );
                }).toList(),
                DataCell((fixedRows() == false)
                    ? IconButton(
                        onPressed: () {
                          deleteRow(index);
                        },
                        icon: const Icon(Icons.delete),
                      )
                    : Container())
              ],
            );
          }).toList()),
    );
  }

  String tableRowText(int index) {
    String result = "";
    var rowsMap = widget.config[widget.meta['name']].asMap();
    for (var c in widget.meta['children']) {
      var colName = c['name'];
      var cellVal = rowsMap[index][colName];
      result += colName + "=" + '$cellVal';
    }
    return result;
  }

  Widget buildTableNarrow(BuildContext context) {
    var rowsMap = widget.config[widget.meta['name']].asMap();
    return Container(
      constraints: BoxConstraints(maxWidth: 300),
      child: Container(
        child: DataTable(
            dataRowHeight: 100,
            headingRowColor: MaterialStateColor.resolveWith((states) => Colors.black26),
            showCheckboxColumn: false,
            columns: [DataColumn(label: Text("---"))],
            rows: rowsMap.keys.map<DataRow>((index) {
              return DataRow(
                selected: selectedIndex == index,
                onSelectChanged: (bool? selected) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                cells: [
                  DataCell(Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        tableRowText(index),
                        overflow: TextOverflow.ellipsis,
                      )
                    ],
                  )),
                ],
              );
            }).toList()),
      ),
    );
  }

  Widget buildTableItem(BuildContext context) {
    return widget.config[widget.meta['name']].length == 0 || selectedIndex >= widget.config[widget.meta['name']].length || selectedIndex < 0
        ? const Text("no row selected")
        : Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border.all(color: Colors.white10)),
            child: UnitConfigObject(widget.client, widget.meta['children'], widget.config[widget.meta['name']][selectedIndex], () {
              setState(() {
                //print("table set state");
              });
            }),
            key: Key('$selectedIndex'),
          );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth < 850) {
          return buildNarrow(context);
        }
        return buildWide(context);
      },
    );
  }
}
