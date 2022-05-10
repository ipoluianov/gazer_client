import 'package:flutter/material.dart';
import 'package:gazer_client/forms/maps/map_form/map_item.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/styles.dart';

import 'map_item_group_of_properties.dart';

class MapItemPropThreshold extends StatefulWidget {
  final IPropContainer item;
  final MapItemPropItem propItem;

  const MapItemPropThreshold(this.item, this.propItem, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemPropThresholdSt();
  }
}

class MapItemPropThresholdSt extends State<MapItemPropThreshold> {
  late String value;
  int currentUpdateIndex = 0;
  TextEditingController txtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    value = widget.item.get(widget.propItem.name + "_value");
    txtController.text = value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //constraints: const BoxConstraints(minWidth: 100, maxWidth: 250),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            constraints: const BoxConstraints(minWidth: 100, maxWidth: 250),
            child: Row(
              children: [
                Checkbox(
                    value: widget.item.get(widget.propItem.name + "_active") == "1",
                    onChanged: (checked) {
                      if (checked != null) {
                        setState(() {
                          widget.item.set(widget.propItem.name + "_active", checked ? "1" : "0");
                        });
                      }
                    }),
                Expanded(
                  child: TextField(
                    controller: txtController,
                    decoration: textInputDecoration(),
                    enabled: widget.item.get(widget.propItem.name + "_active") == "1",
                    onChanged: (value) {
                      widget.item.set(widget.propItem.name + "_value", value);
                    },
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      for (var propItem in widget.item.propThreshold()) {
                        widget.item.set(widget.propItem.name + "_" + propItem.name, widget.item.get(propItem.name));
                      }
                      currentUpdateIndex++;
                    });
                  },
                  icon: Icon(Icons.copy, color: Colors.white12),
                ),
              ],
            ),
          ),
          (widget.item.get(widget.propItem.name + "_active") == "1")
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.item.propThreshold().map<Widget>((propItem) {
                    return Container(
                      //color: Colors.black54,
                      padding: const EdgeInsets.only(left: 30),
                      child: MapItemGroupOfPropertiesSt.buildPropItem(widget.item, propItem..name = widget.propItem.name + "_" + propItem.name,
                          Key(widget.propItem.name + "_" + propItem.name + "_" + currentUpdateIndex.toString())),
                    );
                  }).toList(),
                )
              : Container(),
        ],
      ),
    );

    return Column(
      children: [
        Row(
          children: [
            Checkbox(
                value: widget.item.get(widget.propItem.name + "_active") == "1",
                onChanged: (checked) {
                  if (checked != null) {
                    setState(() {
                      widget.item.set(widget.propItem.name + "_active", checked ? "1" : "0");
                    });
                  }
                }),
            Expanded(
              child: TextField(
                controller: txtController,
                decoration: InputDecoration(
                  label: Text(widget.propItem.displayName),
                ),
                onChanged: (value) {
                  widget.item.set(widget.propItem.name + "_value", value);
                },
              ),
            ),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  for (var propItem in widget.item.propThreshold()) {
                    widget.item.set(widget.propItem.name + "_" + propItem.name, widget.item.get(propItem.name));
                  }
                  currentUpdateIndex++;
                });
              },
              child: Text("Copy"),
            ),
          ],
        ),
        (widget.item.get(widget.propItem.name + "_active") == "1")
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.item.propThreshold().map<Widget>((propItem) {
                  return Container(
                    //color: Colors.black54,
                    padding: const EdgeInsets.only(left: 30),
                    child: MapItemGroupOfPropertiesSt.buildPropItem(widget.item, propItem..name = widget.propItem.name + "_" + propItem.name,
                        Key(widget.propItem.name + "_" + propItem.name + "_" + currentUpdateIndex.toString())),
                  );
                }).toList(),
              )
            : Container(),
      ],
    );
  }
}
