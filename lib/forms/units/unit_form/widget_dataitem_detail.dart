import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/core/protocol/service/service_lookup.dart';
import 'package:gazer_client/core/protocol/unit/unit_items_values.dart';
import 'package:gazer_client/core/protocol/unit/unit_state.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/forms/units/unit_form/widget_dataitem_state.dart';
import 'package:gazer_client/widgets/borders/border_01_item.dart';
import 'package:gazer_client/widgets/borders/border_02_titlebar.dart';
import 'package:gazer_client/widgets/borders/border_03_item_details.dart';
import 'package:gazer_client/widgets/borders/border_04_action_button.dart';
import 'package:gazer_client/widgets/borders/border_05_left_navigator.dart';
import 'package:gazer_client/widgets/borders/border_06_item_details_name.dart';
import 'package:gazer_client/widgets/borders/border_07_item_details_value.dart';
import 'package:gazer_client/widgets/borders/border_08_item_list_item.dart';
import 'package:gazer_client/widgets/borders/border_09_left_navigator_main.dart';
import 'package:intl/intl.dart';

import '../../../widgets/error_dialog/error_dialog.dart';

class WidgetDataItemDetail extends StatefulWidget {
  final Connection connection;
  final GazerLocalClient client;
  final String unitId;
  final String unitName;
  final UnitStateValuesResponseItem item;
  final Function onMainItemChanged;

  const WidgetDataItemDetail(this.connection, this.client, this.unitName,
      this.unitId, this.item, this.onMainItemChanged,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return WidgetDataItemDetailState();
  }
}

class WidgetDataItemDetailState extends State<WidgetDataItemDetail> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  DateFormat timeFormat = DateFormat("HH:mm:ss");
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  String shortName(String itemName) {
    return itemName.replaceAll("${widget.unitId}/", "");
  }

  Color colorByUOM(String uom) {
    if (uom == "error") {
      return DesignColors.bad();
    }
    return DesignColors.good();
  }

  @override
  Widget build(BuildContext context) {
    String valueText = widget.item.value.value + ' ' + widget.item.value.uom;
    double valueFontSize = 48;
    if (valueText.length > 20) {
      valueFontSize = 36;
    }
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: WidgetDataItemState(
                  widget.connection,
                  widget.client,
                  widget.unitName,
                  widget.unitId,
                  widget.item,
                  widget.onMainItemChanged),
            ),
            Stack(
              children: [
                Container(
                  child: Border03Painter.build(false),
                  height: 75,
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      /*buildActionButton(context, Icons.settings, "Properties",
                          () {
                        Navigator.pushNamed(context, "/data_item_properties",
                            arguments: DataItemPropertiesFormArgument(
                                widget.connection,
                                widget.item.id,
                                widget.item.name));
                      }),*/
                      /*buildActionButton(
                          context, Icons.table_rows_outlined, "Export to CSV",
                          () {
                        Navigator.pushNamed(context, "/data_item_history_table",
                            arguments: DataItemHistoryTableFormArgument(
                                widget.connection, widget.item.name));
                      }),*/
                      buildActionButton(
                          context, Icons.ac_unit, "Set as MainItem", () {
                        //Navigator.pushNamed(context, "/data_item_properties", arguments: DataItemPropertiesFormArgument(widget.connection, widget.item.id, widget.item.name));
                        Repository().client(widget.connection).unitPropSet(
                            widget.unitId,
                            {"main_item": widget.item.name}).then((value) {
                          widget.onMainItemChanged();
                        }).catchError((err) {
                          showErrorDialog(context, "$err");
                        });
                      }),
                      buildActionButton(
                          context, Icons.input, "Write value to the item", () {
                        _displayWriteValueDialog(context);
                      }),
                      buildActionButton(
                          context, Icons.remove_circle_outline, "Remove item",
                          () {
                        showRemoveItemDialog(context);
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  String txtWriteValue = "";
  final TextEditingController _textFieldWriteValueController =
      TextEditingController();

  Future<void> _displayWriteValueDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Write Value'),
            content: TextField(
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  txtWriteValue = value;
                });
              },
              controller: _textFieldWriteValueController,
              decoration: const InputDecoration(hintText: "Value"),
            ),
            actions: <Widget>[
              OutlinedButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              OutlinedButton(
                child: const Text('OK'),
                onPressed: () {
                  setState(() {
                    Repository()
                        .client(widget.connection)
                        .dataItemWrite(widget.item.name, txtWriteValue)
                        .then((value) {
                      Navigator.pop(context);
                    }).catchError((err) {
                      showErrorDialog(context, "$err");
                    });
                  });
                },
              ),
            ],
          );
        });
  }

  showRemoveItemDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = OutlinedButton(
      child: const SizedBox(width: 70, child: Center(child: Text("Cancel"))),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = OutlinedButton(
      child: const SizedBox(width: 70, child: Center(child: Text("Remove"))),
      onPressed: () {
        List<String> itemsToRemove = [];
        itemsToRemove.add(widget.item.name);
        Repository()
            .client(widget.connection)
            .dataItemRemove(itemsToRemove)
            .then((value) {
          Repository()
              .history
              .getNode(widget.connection)
              .clearItemCache(widget.item.name);
          Navigator.of(context).pop();
        }).catchError((err) {
          showErrorDialog(context, "$err");
        });
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Confirmation"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            //margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            color: Colors.black54,
            child: const Text("Would you like to REMOVE"),
          ),
          Container(
            //margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            color: Colors.black54,
            child: Text("${widget.item.name}?"),
          ),
          Container(
            //margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            color: Colors.red,
            child: const Text(
              "All history of this item will be destroyed!",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      actions: [
        continueButton,
        cancelButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
