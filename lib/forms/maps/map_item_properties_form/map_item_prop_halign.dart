import 'package:flutter/material.dart';
import 'package:gazer_client/forms/maps/map_form/main/map_item.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/styles.dart';

class MapItemPropHAlign extends StatefulWidget {
  final IPropContainer item;
  final MapItemPropItem propItem;

  const MapItemPropHAlign(this.item, this.propItem, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemPropHAlignSt();
  }
}

class MapItemPropHAlignSt extends State<MapItemPropHAlign> {
  late String value;

  @override
  void initState() {
    super.initState();
    value = widget.item.get(widget.propItem.name);
  }

  Widget buildAlignButton(String data, IconData iconData, Color color) {
    return Container(
      padding: const EdgeInsets.only(left: 1),
      child: IconButton(
        icon: Icon(iconData),
        color: color,
        onPressed: () {
          widget.item.set(widget.propItem.name, data);
        },
        //child: const Text("..."),
      ),
    );
  }

//
  @override
  Widget build(BuildContext context) {
    Color colActive = Colors.amber;
    Color colReg = Colors.white.withOpacity(0.5);
    return Row(
      children: [
        buildAlignButton(
            "left",
            Icons.format_align_left,
            widget.item.get(widget.propItem.name) == "left"
                ? colActive
                : colReg),
        buildAlignButton(
            "center",
            Icons.format_align_center,
            widget.item.get(widget.propItem.name) == "center"
                ? colActive
                : colReg),
        buildAlignButton(
            "right",
            Icons.format_align_right,
            widget.item.get(widget.propItem.name) == "right"
                ? colActive
                : colReg),
      ],
    );
  }
}
