import 'package:flutter/material.dart';
import 'package:gazer_client/core/protocol/dataitem/data_item_prop_get.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/forms/utilities/lookup_form/lookup_form.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';

import '../../../core/navigation/route_generator.dart';

class WidgetDataItemProperties extends StatefulWidget {
  final DataItemPropertiesFormArgument arg;

  const WidgetDataItemProperties(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WidgetDataItemPropertiesState();
  }
}

class WidgetDataItemPropertiesState extends State<WidgetDataItemProperties> {
  late Future<DataItemPropGetResponse> _futureItemProperties;

  final TextEditingController txtControllerSource = TextEditingController();
  final TextEditingController txtControllerTuneOffset = TextEditingController();
  final TextEditingController txtControllerTuneScale = TextEditingController();

  bool loaded = false;
  String source = "";
  bool tuneTrim = false;
  bool? tuneOn = false;
  double tuneScale = 1.0;
  double tuneOffset = 0.0;
  String sourceItemName = "";

  @override
  void initState() {
    Repository().client(widget.arg.connection).dataItemPropGet(widget.arg.itemName).then((value) {
      setState(() {
        for (var prop in value.props) {
          if (prop.propName == "source") {
            source = prop.propValue;
          }
          if (prop.propName == "#source_item_name") {
            sourceItemName = prop.propValue;
          }
          if (prop.propName == "tune_trim") {
            tuneTrim = prop.propValue == "1";
          }
          if (prop.propName == "tune_on") {
            tuneOn = prop.propValue == "1";
          }
          if (prop.propName == "tune_scale") {
            tuneScale = double.parse(prop.propValue);
          }
          if (prop.propName == "tune_offset") {
            tuneOffset = double.parse(prop.propValue);
          }
        }

        txtControllerSource.text = source;
        txtControllerTuneScale.text = tuneScale.toString();
        txtControllerTuneOffset.text = tuneOffset.toString();

        loaded = true;
      });
    }).catchError((err) {
      setState(() {
        loaded = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void save() {
    var tuneOnValue = "";
    if (tuneOn == true) {
      tuneOnValue = "1";
    }
    var tuneTrimValue = "";
    if (tuneTrim == true) {
      tuneTrimValue = "1";
    }

    Repository().client(widget.arg.connection).dataItemPropSet(widget.arg.itemName, {
      "source": txtControllerSource.text,
      "tune_trim": tuneTrimValue,
      "tune_on": tuneOnValue,
      "tune_offset": txtControllerTuneOffset.text,
      "tune_scale": txtControllerTuneScale.text,
    });
    Navigator.pop(context);
  }

  Widget buildFetched() {
    if (loaded) {
      return Expanded(
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Scrollbar(
            isAlwaysShown: true,
            child: ListView(
            children: [
              Card(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: tuneOn,
                            onChanged: (newValue) {
                              setState(() {
                                tuneOn = newValue;
                              });
                            },
                          ),
                          const Expanded(
                            child: Text("Tune On"),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxWidth: 150),
                            padding: const EdgeInsets.only(left: 20),
                            child: TextField(
                              enabled: tuneOn,
                              decoration: const InputDecoration(
                                labelText: "Tune Scale",
                                hintText: "Tune Scale",
                              ),
                              controller: txtControllerTuneScale,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            constraints: const BoxConstraints(maxWidth: 150),
                            padding: const EdgeInsets.only(left: 20),
                            child: TextField(
                              enabled: tuneOn,
                              decoration: const InputDecoration(
                                labelText: "Tune Offset",
                                hintText: "Tune Offset",
                              ),
                              controller: txtControllerTuneOffset,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: Container(
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              "RESULT = value * scale + offset",
                              style: TextStyle(color: Colors.white30),
                            ),
                          ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            //constraints: const BoxConstraints(maxWidth: 200),
                            child: CheckboxListTile(
                              title: const Text("Trim"),
                              value: tuneTrim,
                              onChanged: (newValue) {
                                setState(() {
                                  tuneTrim = newValue!;
                                });
                              },
                              controlAffinity: ListTileControlAffinity.leading, //  <-- leading Checkbox
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child:
                          Container(
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              "Remove characters [\\r & \\n & \\t] at the beginning and end of the value",
                              style: TextStyle(color: Colors.white30),
                            ),
                          ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Source",
                        style: TextStyle(fontSize: 24),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10),
                        constraints: const BoxConstraints(maxWidth: 200),
                        child: TextField(
                          decoration: const InputDecoration(
                            //border: OutlineInputBorder(),
                            labelText: "Data Item Id",
                            hintText: "Data Item Id",
                          ),
                          controller: txtControllerSource,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Text(
                          sourceItemName,
                          overflow: TextOverflow.fade,
                        ),
                      ),
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, "/lookup",
                                        arguments: LookupFormArgument(Repository().lastSelectedConnection, "Select source item", "data-item"))
                                    .then((value) {
                                  if (value != null) {
                                    var res = value as LookupFormResult;
                                    txtControllerSource.text = res.code();
                                    setState(() {
                                      sourceItemName = res.field("name");
                                    });
                                  }
                                });
                              },
                              icon: const Icon(Icons.more_horiz),
                              label: const Text("select"),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: OutlinedButton(
                              onPressed: () {
                                txtControllerSource.text = "";
                                setState(() {
                                  sourceItemName = "";
                                });
                              },
                              //icon: const Icon(Icons.arrow_left),
                              child: const Text("clear"),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: Container(
                            padding: const EdgeInsets.only(left: 20),
                            child: const Text(
                              "Write to this item all the values from the source item",
                              style: TextStyle(color: Colors.white30),
                            ),
                          ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      );
    } else {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Data Item Properties [" + widget.arg.itemName + "]",
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.fade,
                ),
                Text(
                  "address: " + widget.arg.connection.address,
                  style: const TextStyle(
                    color: Colors.white30,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.fade,
                )
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton.icon(
                  onPressed: () {
                    save();
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                ),
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LeftNavigator(showLeft),
                    buildFetched(),
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
