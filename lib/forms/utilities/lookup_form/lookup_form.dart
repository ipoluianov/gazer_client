import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gazer_client/core/protocol/service/service_info.dart';
import 'package:gazer_client/core/protocol/service/service_lookup.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';

import '../../../core/design.dart';
import '../../../widgets/title_bar/title_bar.dart';

class LookupForm extends StatefulWidget {
  final LookupFormArgument arg;
  const LookupForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LookupFormSt();
  }
}

class LookupFormResult {
  final String _code;
  final Map<String, String> _fields;
  LookupFormResult(this._code, this._fields);

  String code() {
    return _code;
  }

  String field(String name) {
    if (_fields.containsKey(name)) {
      if (_fields[name] == null) {
        return "";
      }
      return _fields[name]!;
    }
    return "";
  }
}

class LookupFormSt extends State<LookupForm> {
  bool serviceInfoLoaded = false;
  late ServiceInfoResponse serviceInfo;
  void loadNodeInfo() {
    Repository().client(widget.arg.connection).serviceInfo().then((value) {
      setState(() {
        serviceInfo = value;
        serviceInfoLoaded = true;
      });
    });
  }

  String nodeName() {
    if (serviceInfoLoaded) {
      return serviceInfo.nodeName;
    }
    return widget.arg.connection.address;
  }

  bool loaded = false;
  late ServiceLookupResponse lookupResponse;
  List<ServiceLookupRowResponse> filteredRows = [];

  int selectedIndex = 1;
  String lookupSelectedItem = "";
  String lookupSelectedItem2 = "";
  String lookupFilter = "";
  TextEditingController lookupFilterController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadNodeInfo();

    Repository()
        .client(widget.arg.connection)
        .serviceLookup(widget.arg.lookupParameter, "")
        .then((value) {
      setState(() {
        lookupResponse = value;
        loaded = true;
        applyFilter();
      });
    });
  }

  void applyFilter() {
    print("-------------------");
    setState(() {
      if (loaded) {
        var lookupFilterLowerCase = lookupFilter.toLowerCase();
        filteredRows = lookupResponse.result.rows.where((element) {
          var found = false;
          for (var c in element.cells) {
            if (c.toLowerCase().contains(lookupFilterLowerCase)) {
              found = true;
              print("found ${c}");
            }
          }
          return found;
        }).toList();

        print("result = ${filteredRows.length}");
      } else {
        filteredRows = [];
      }
      selectedIndex = 0;
    });
  }

  Widget buildContent(BuildContext context) {
    if (!loaded) {
      return Text("loading ...");
    }

    List<ServiceLookupColumnResponse> columns = [];
    for (var col in lookupResponse.result.columns) {
      if (!col.hidden) {
        columns.add(col);
      }
    }

    List<ServiceLookupRowResponse> rows = [];
    for (var row in filteredRows) {
      List<String> cells = [];
      for (var colIndex = 0;
          colIndex < lookupResponse.result.columns.length;
          colIndex++) {
        var col = lookupResponse.result.columns[colIndex];
        if (!col.hidden) {
          cells.add(row.cells[colIndex]);
        }
      }
      ServiceLookupRowResponse resp = ServiceLookupRowResponse(cells);
      rows.add(resp);
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: lookupFilterController,
              decoration: const InputDecoration(
                label: Text("Search ..."),
              ),
              onChanged: (newValue) {
                lookupFilter = newValue;
                applyFilter();
              },
            ),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: DataTable(
                    headingRowColor: MaterialStateColor.resolveWith((states) {
                      return Colors.black26;
                    }),
                    dataRowColor: MaterialStateColor.resolveWith((states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.blue.withAlpha(100);
                      }
                      if (states.contains(MaterialState.hovered)) {
                        return Colors.black26;
                      }
                      return Colors.black26;
                    }),
                    showCheckboxColumn: false,
                    rows: rows.asMap().keys.map<DataRow>((rowIndex) {
                      return DataRow(
                          selected: selectedIndex == rowIndex,
                          onSelectChanged: (bool? selected) {
                            setState(() {
                              selectedIndex = rowIndex;
                            });
                          },
                          cells: columns.asMap().keys.map<DataCell>((colIndex) {
                            return DataCell(
                                Text(rows[rowIndex].cells[colIndex]));
                          }).toList());
                    }).toList(),
                    columns: columns.map<DataColumn>((e) {
                      return DataColumn(label: Text(e.displayName));
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool narrow = constraints.maxWidth < constraints.maxHeight;
        bool showLeft = !narrow;
        bool showBottom = narrow;

        return Scaffold(
          appBar: TitleBar(
            widget.arg.connection,
            "Lookup ...",
            actions: [
              Container(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (selectedIndex >= 0 &&
                        selectedIndex < filteredRows.length) {
                      String selectedCode = "";
                      var selectedRow = filteredRows[selectedIndex];
                      Map<String, String> fields = {};
                      for (int colIndex = 0;
                          colIndex < lookupResponse.result.columns.length;
                          colIndex++) {
                        var col = lookupResponse.result.columns[colIndex];
                        fields[col.name] = selectedRow.cells[colIndex];
                        if (lookupResponse.result.keyColumn == col.name) {
                          selectedCode = selectedRow.cells[colIndex];
                        }
                      }
                      LookupFormResult res =
                          LookupFormResult(selectedCode, fields);
                      Navigator.pop(context, res);
                    }
                  },
                  icon: const Icon(Icons.check),
                  label: const Text("Select"),
                ),
              ),
              buildHomeButton(context),
            ],
          ),
          body: Container(
            color: DesignColors.mainBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LeftNavigator(showLeft),
                      buildContent(context),
                    ],
                  ),
                ),
                BottomNavigator(showBottom),
              ],
            ),
          ),
        );
      },
    );
  }
}
