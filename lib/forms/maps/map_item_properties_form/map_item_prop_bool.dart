import 'package:flutter/material.dart';
import 'package:gazer_client/forms/maps/map_form/map_item.dart';

class MapItemPropBool extends StatefulWidget {
  final IPropContainer item;
  final MapItemPropItem propItem;

  const MapItemPropBool(this.item, this.propItem, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemPropBoolSt();
  }
}

class MapItemPropBoolSt extends State<MapItemPropBool> {
  late String value;
  TextEditingController txtController = TextEditingController();

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
        Checkbox(
          value: widget.item.get(widget.propItem.name) == "1",
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() {
                widget.item.set(widget.propItem.name, newValue ? "1" : "0");
              });
            }
          },
        ),
      ],
    );
    return TextField(
      controller: txtController,
      decoration: InputDecoration(
        label: Text(widget.propItem.displayName),
      ),
      onChanged: (value) {
        widget.item.set(widget.propItem.name, value);
      },
    );
  }
}
