import 'package:flutter/material.dart';
import 'package:gazer_client/forms/maps/map_form/main/map_item.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/styles.dart';

class MapItemPropFontWeight extends StatefulWidget {
  final IPropContainer item;
  final MapItemPropItem propItem;

  const MapItemPropFontWeight(this.item, this.propItem, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemPropFontWeightSt();
  }
}

class MapItemPropFontWeightSt extends State<MapItemPropFontWeight> {
  late String value;

  @override
  void initState() {
    super.initState();
    value = widget.item.get(widget.propItem.name);
  }

  Widget buildFontWeightButton(String data, IconData iconData, Color color) {
    return Container(
      width: 120,
      height: 30,
      margin: const EdgeInsets.all(2),
      padding: EdgeInsets.zero,
      child: OutlinedButton(
        onPressed: () {
          widget.item.set(widget.propItem.name, data);
        },
        child: Text(
          data,
          style: TextStyle(color: color),
        ),
      ),
    );
  }

//
  @override
  Widget build(BuildContext context) {
    Color colActive = Colors.amber;
    Color colReg = Colors.white.withOpacity(0.5);
    return Wrap(
      children: [
        buildFontWeightButton(
            "100",
            Icons.format_align_left,
            widget.item.get(widget.propItem.name) == "100"
                ? colActive
                : colReg),
        buildFontWeightButton(
            "300",
            Icons.format_align_right,
            widget.item.get(widget.propItem.name) == "300"
                ? colActive
                : colReg),
        buildFontWeightButton(
            "400",
            Icons.format_align_right,
            widget.item.get(widget.propItem.name) == "400"
                ? colActive
                : colReg),
        buildFontWeightButton(
            "600",
            Icons.format_align_right,
            widget.item.get(widget.propItem.name) == "600"
                ? colActive
                : colReg),
      ],
    );
  }
}
