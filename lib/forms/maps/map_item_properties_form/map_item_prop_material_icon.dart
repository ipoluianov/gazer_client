import 'package:flutter/material.dart';
import 'package:gazer_client/forms/maps/map_form/main/map_item.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/styles.dart';
import 'package:image/image.dart';

import '../utils/material_icons.dart';

class MapItemPropMaterialIcon extends StatefulWidget {
  final IPropContainer item;
  final MapItemPropItem propItem;

  const MapItemPropMaterialIcon(this.item, this.propItem, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemPropMaterialIconSt();
  }
}

class MapItemPropMaterialIconSt extends State<MapItemPropMaterialIcon> {
  late String value;
  TextEditingController txtController = TextEditingController();
  TextEditingController txtControllerFilter = TextEditingController();

  @override
  void initState() {
    super.initState();
    value = widget.item.get(widget.propItem.name);
    txtController.text = value;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: txtController,
            decoration: textInputDecoration(),
            onChanged: (text) {
              setState(() {
                widget.item.set(widget.propItem.name, text);
              });
              //widget.onChanged();
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.only(left: 1),
          child: IconButton(
            icon: const Icon(Icons.more_horiz),
            color: Colors.white.withOpacity(0.5),
            onPressed: () {
              originalValueBeforeDialog = widget.item.get(widget.propItem.name);
              currentValue = originalValueBeforeDialog;
              showSelectDialog("Select icon");
            },
            //child: const Text("..."),
          ),
        ),
      ],
    );
  }

  String currentValue = "";
  String originalValueBeforeDialog = "";

  void changeValue(String value) {
    setState(() {
      currentValue = value;
      setCurrentValue(value);
    });
  }

  void setCurrentValue(String value) {
    widget.item.set(widget.propItem.name, value);
    txtController.text = value;
  }

  List<String> getIcons(String filter) {
    List<String> result = [];
    for (var iconName in MaterialIconsLib().icons.keys) {
      if (iconName.contains(filter) || filter.isEmpty) {
        result.add(iconName);
      }
      if (result.length >= 1000) break;
    }
    return result;
  }

  //String selectedIconName = "";
  String filter = "";

  ScrollController listScrollController = ScrollController();
  Widget dialogContent(BuildContext context, Function setState) {
    return Container(
      constraints: const BoxConstraints(
        maxWidth: 500,
        maxHeight: 500,
      ),
      child: Column(
        children: [
          TextField(
            controller: txtControllerFilter,
            onChanged: (value) {
              setState(() {
                filter = txtControllerFilter.text;
              });
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              controller: listScrollController,
              child: Container(
                constraints: const BoxConstraints(minWidth: 500),
                child: Wrap(
                  children: getIcons(txtControllerFilter.text)
                      .map(
                        (e) => MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                currentValue = e;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: currentValue == e
                                      ? Colors.amber
                                      : Colors.transparent),
                              width: 60,
                              height: 60,
                              child: Icon(
                                MaterialIconsLib().getIconByName(e),
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<void> showSelectDialog(String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(text),
            content: dialogContent(context, setState),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  setCurrentValue(originalValueBeforeDialog);
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  setCurrentValue(currentValue);
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
      },
    );
  }
}
