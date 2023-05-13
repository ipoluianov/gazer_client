import 'package:flutter/material.dart';
import 'package:gazer_client/forms/maps/map_form/main/map_item.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/styles.dart';

class MapItemPropFontFamily extends StatefulWidget {
  final IPropContainer item;
  final MapItemPropItem propItem;

  const MapItemPropFontFamily(this.item, this.propItem, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemPropFontFamilySt();
  }
}

class MapItemPropFontFamilySt extends State<MapItemPropFontFamily> {
  late String value;

  @override
  void initState() {
    super.initState();
    value = widget.item.get(widget.propItem.name);
  }

  Widget buildFontFamilyButton(
      String data, String name, IconData iconData, Color color) {
    return Container(
      width: 120,
      height: 40,
      margin: const EdgeInsets.all(2),
      padding: EdgeInsets.zero,
      child: OutlinedButton(
        onPressed: () {
          widget.item.set(widget.propItem.name, data);
        },
        child: Text(
          name,
          textAlign: TextAlign.center,
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
        buildFontFamilyButton(
            "Roboto",
            "Roboto",
            Icons.format_align_left,
            widget.item.get(widget.propItem.name) == "Roboto"
                ? colActive
                : colReg),
        buildFontFamilyButton(
            "RobotoMono",
            "Roboto Mono",
            Icons.format_align_center,
            widget.item.get(widget.propItem.name) == "RobotoMono"
                ? colActive
                : colReg),
        buildFontFamilyButton(
            "MajorMono",
            "Major Mono",
            Icons.format_align_right,
            widget.item.get(widget.propItem.name) == "MajorMono"
                ? colActive
                : colReg),
        buildFontFamilyButton(
            "ShareTechMono",
            "Share Tech Mono",
            Icons.format_align_right,
            widget.item.get(widget.propItem.name) == "ShareTechMono"
                ? colActive
                : colReg),
      ],
    );
  }
}
