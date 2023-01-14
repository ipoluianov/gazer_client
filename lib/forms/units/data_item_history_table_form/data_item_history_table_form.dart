import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gazer_client/core/protocol/dataitem/data_item_history.dart';
import 'package:gazer_client/core/protocol/resource/resource_list.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/styles.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/widgets/time_filter/time_filter.dart';
import 'package:gazer_client/widgets/title_widget/title_widget.dart';
import 'package:intl/intl.dart' as international;

import '../../../widgets/title_bar/title_bar.dart';

class DataItemHistoryTableForm extends StatefulWidget {
  final DataItemHistoryTableFormArgument arg;
  const DataItemHistoryTableForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return DataItemHistoryTableFormSt();
  }
}

class DataItemHistoryTableFormSt extends State<DataItemHistoryTableForm> {
  international.DateFormat timeFormat =
      international.DateFormat("yyyy-MM-dd HH:mm:ss");
  TextEditingController textEditingControllerFilename = TextEditingController();
  TextEditingController textEditingControllerSeparator =
      TextEditingController();
  String filename = "";
  String separator = ";";
  String exportStatus = "";

  @override
  void initState() {
    super.initState();
    dtBegin = DateTime.now().add(const Duration(minutes: -5));
    dtEnd = DateTime.now();
    textEditingControllerSeparator.text = separator;
  }

  late DateTime dtBegin;
  late DateTime dtEnd;

  bool loading = false;
  //bool loaded = false;
  List<DataItemHistoryResultItemResponse> items = [];

  String getCSV() {
    print("start get csv");
    var buffer = StringBuffer();
    int linesCount = 0;
    for (var item in items) {
      var line = "";
      line += timeFormat.format(DateTime.fromMicrosecondsSinceEpoch(item.dt));
      line += separator;
      line += item.value;
      line += separator;
      line += item.uom;
      line += "\r\n";
      buffer.write(line);
      linesCount++;
      if ((linesCount % 1000) == 0) {
        print(linesCount);
      }
    }
    print("stop get csv");
    return buffer.toString();
  }

  void exportToCSV() async {
    if (filename.isEmpty) {
      setState(() {
        exportStatus = "Wrong file name";
      });
      return;
    }

    setState(() {
      loading = true;
      exportStatus = "loading data ...";
    });

    items = [];

    try {
      for (var dt1 = dtBegin;
          dt1.isBefore(dtEnd);
          dt1 = dt1.add(const Duration(hours: 1))) {
        exportStatus = "loading data ... " + timeFormat.format(dt1);

        var resp = await Repository()
            .client(widget.arg.connection)
            .dataItemHistory(widget.arg.itemName, dt1.microsecondsSinceEpoch,
                dt1.add(const Duration(hours: 1)).microsecondsSinceEpoch);
        items.addAll(resp.result.items);
      }
      setState(() {
        exportStatus = "data loaded ...";
      });
      String csv = getCSV();
      File file = File(filename);
      file.writeAsBytes(utf8.encode(csv));

      setState(() {
        exportStatus = "Complete";
      });
    } catch (ex) {
      setState(() {
        exportStatus = "Error" + ex.toString();
      });
    }

    setState(() {
      loading = false;
    });
  }

  Widget buildContent(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TimeFilter(dtBegin, dtEnd, (dtB, dtE) {
              setState(() {
                dtBegin = dtB;
                dtEnd = dtE;
              });
            }),
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.black45,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Export settings",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  Container(
                    height: 10,
                  ),
                  const Padding(
                    padding: EdgeInsets.all(6),
                    child: Text("File name:"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(6),
                    child: TextField(
                      controller: textEditingControllerFilename,
                      decoration: textInputDecoration(),
                      onChanged: (value) {
                        setState(() {
                          filename = value;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: ElevatedButton(
                      onPressed: () {
                        FilePicker.platform.saveFile(
                            dialogTitle: "Save to CSV",
                            type: FileType.custom,
                            allowedExtensions: ["csv"]).then(
                          (value) {
                            if (value != null) {
                              if (!value.endsWith(".csv")) {
                                value = value + ".csv";
                              }
                              textEditingControllerFilename.text = value;
                              filename = value;
                            }
                          },
                        );
                      },
                      child: const Text("Browse file ..."),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(6),
                    child: Text("Separator:"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: TextField(
                      controller: textEditingControllerSeparator,
                      decoration: textInputDecoration(),
                      onChanged: (value) {
                        setState(() {
                          separator = value;
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(6),
                    child: ElevatedButton(
                      onPressed: () {
                        exportToCSV();
                      },
                      child: const Text("Export to CSV"),
                    ),
                  ),
                  Text(exportStatus),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getCurrentTitleKey() {
    return "data_item_history_table_form";
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool narrow = constraints.maxWidth < constraints.maxHeight;
        bool showLeft = !narrow;
        bool showBottom = narrow;

        return Scaffold(
          appBar: AppBar(
            title: TitleBar(
              widget.arg.connection,
              "Export table",
              key: Key(getCurrentTitleKey()),
              actions: [
                buildHomeButton(context),
              ],
            ),
          ),
          body: Column(
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
        );
      },
    );
  }
}
