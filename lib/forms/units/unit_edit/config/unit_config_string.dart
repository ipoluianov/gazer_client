import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/core/protocol/service/service_lookup.dart';
import 'package:gazer_client/core/protocol/unit_type/unit_type_config_meta.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/forms/utilities/lookup_form/lookup_form.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/forms/units/unit_edit/config/unit_default_value.dart';
import 'package:flutter/material.dart';

class UnitConfigString extends StatefulWidget {
  final GazerLocalClient client;
  final Map<String, dynamic> meta;
  Map<String, dynamic> config;
  final Function() onChanged;
  UnitConfigString(this.client, this.meta, this.config, this.onChanged,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UnitConfigStringState();
  }
}

class UnitConfigStringState extends State<UnitConfigString>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  late Future<ServiceLookupResponse> _futureServiceLookupResponse;
  int selectedIndex = 1;
  String lookupSelectedItem = "";

  @override
  void initState() {
    _controller = TextEditingController();
    _futureServiceLookupResponse = widget.client.serviceLookup("", "");
    if (!widget.config.containsKey(widget.meta['name'])) {
      widget.config[widget.meta['name']] = defaultValue(widget.meta['type'],
          widget.meta['default_value'], widget.meta['format']);
    }
    _controller.text = widget.config[widget.meta['name']];
    dropdownValue = widget.config[widget.meta['name']];

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String dropdownValue = "int32";

  Widget buildInputField(String metaMin, String metaMax, String format) {
    if (metaMin.isEmpty) {
      return TextField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.meta['display_name'],
            labelText: widget.meta['display_name'],
          ),
          onChanged: (text) {
            setState(() {
              widget.config[widget.meta['name']] = text;
            });
            //widget.onChanged();
          });
    }

    var options = metaMin.split("|");
    for (var i = 0; i < options.length; i++) {
      options[i] = options[i].trim();
    }

    return DropdownButton<String>(
      value: dropdownValue,
      onChanged: (String? newValue) {
        setState(
          () {
            dropdownValue = newValue!;
            widget.config[widget.meta['name']] = dropdownValue;
          },
        );
      },
      style: TextStyle(
        fontSize: 14,
      ),
      items: options.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    //print("string build ${widget.meta['name']}");
    return Container(
      constraints: const BoxConstraints(minWidth: 100, maxWidth: 300),
      child: Row(children: [
        Expanded(
          child: buildInputField(widget.meta['min_value'],
              widget.meta['max_value'], widget.meta['format']),
        ),
        widget.meta['format'] != ""
            ? OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, "/lookup",
                          arguments: LookupFormArgument(
                              Repository().lastSelectedConnection,
                              "Select source item",
                              widget.meta['format']))
                      .then((value) {
                    if (value != null) {
                      var res = value as LookupFormResult;

                      setState(() {
                        _controller.text = res.code();
                        widget.config[widget.meta['name']] = res.code();
                        //print('Selected: $value');
                      });
                    }
                  });
                },
                child: const Text("..."))
            : const Text(""),
      ]),
    );
  }

  Future<void> _showLookupDialog(String text, String lookupParameter,
      Function(String) onLookupAccept) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(text),
              content: SingleChildScrollView(
                child: FutureBuilder<ServiceLookupResponse>(
                  future: _futureServiceLookupResponse,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return DataTable(
                        headingRowColor: MaterialStateColor.resolveWith(
                            (states) => Colors.black26),
                        showCheckboxColumn: false,
                        rows: snapshot.data!.result.rows
                            .asMap()
                            .keys
                            .map<DataRow>((rowIndex) {
                          var rows = snapshot.data!.result.rows;
                          return DataRow(
                              selected: selectedIndex == rowIndex,
                              onSelectChanged: (bool? selected) {
                                setState(() {
                                  selectedIndex = rowIndex;
                                  lookupSelectedItem = rows[rowIndex].cells[0];
                                });
                              },
                              cells: snapshot.data!.result.columns
                                  .asMap()
                                  .keys
                                  .map<DataCell>((colIndex) {
                                return DataCell(
                                    Text("${rows[rowIndex].cells[colIndex]}"));
                              }).toList());
                        }).toList(),
                        columns:
                            snapshot.data!.result.columns.map<DataColumn>((e) {
                          return DataColumn(label: Text(e.displayName));
                        }).toList(),
                      );
                    } else if (snapshot.hasError) {
                      return const Text("Error");
                    }
                    return const Text("unknown");
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    //print("$lookupParameter = $lookupSelectedItem");
                    //widget.config[lookupParameter] = lookupSelectedItem;
                    onLookupAccept(lookupSelectedItem);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> showOptionsDialog(String text, List<String> values,
      List<String> valuesNames, Function(String) onLookupAccept) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(text),
              content: Text("ComboBox"),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    //print("$lookupParameter = $lookupSelectedItem");
                    //widget.config[lookupParameter] = lookupSelectedItem;
                    onLookupAccept("selected_item");
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
