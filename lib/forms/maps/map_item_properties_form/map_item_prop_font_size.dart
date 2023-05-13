import 'package:flutter/material.dart';
import 'package:gazer_client/forms/maps/map_form/main/map_item.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/styles.dart';

class MapItemPropFontSize extends StatefulWidget {
  final IPropContainer item;
  final MapItemPropItem propItem;

  const MapItemPropFontSize(this.item, this.propItem, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemPropFontSizeSt();
  }
}

class MapItemPropFontSizeSt extends State<MapItemPropFontSize> {
  late String value;

  TextEditingController txtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    value = widget.item.get(widget.propItem.name);
    txtController.text = value;
  }

  Widget buildFontSizeButton(String data, IconData iconData, Color color) {
    return Container(
      width: 46,
      height: 30,
      margin: const EdgeInsets.all(2),
      padding: EdgeInsets.zero,
      child: OutlinedButton(
        onPressed: () {
          widget.item.set(widget.propItem.name, data);
          txtController.text = data;
        },
        child: Text(
          data,
          style: TextStyle(
            color: color,
            fontSize: 12,
          ),
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
        TextField(
          controller: txtController,
          decoration: textInputDecoration(),
          onChanged: (text) {
            widget.item.set(widget.propItem.name, text);
            //widget.onChanged();
          },
        ),
        buildFontSizeButton("16", Icons.format_align_left,
            widget.item.get(widget.propItem.name) == "16" ? colActive : colReg),
        buildFontSizeButton("20", Icons.format_align_right,
            widget.item.get(widget.propItem.name) == "20" ? colActive : colReg),
        buildFontSizeButton("32", Icons.format_align_right,
            widget.item.get(widget.propItem.name) == "32" ? colActive : colReg),
        buildFontSizeButton("48", Icons.format_align_right,
            widget.item.get(widget.propItem.name) == "48" ? colActive : colReg),
        buildFontSizeButton("72", Icons.format_align_right,
            widget.item.get(widget.propItem.name) == "72" ? colActive : colReg),
      ],
    );
  }
}
