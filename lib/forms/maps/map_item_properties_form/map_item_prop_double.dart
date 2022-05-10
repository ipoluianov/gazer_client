import 'package:flutter/material.dart';
import 'package:gazer_client/forms/maps/map_form/map_item.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/styles.dart';

class MapItemPropDouble extends StatefulWidget {
  final IPropContainer item;
  final MapItemPropItem propItem;

  const MapItemPropDouble(this.item, this.propItem, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemPropDoubleSt();
  }
}

class MapItemPropDoubleSt extends State<MapItemPropDouble> {
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
        Expanded(
          child: SizedBox(
            height: 30,
            child: TextField(
              controller: txtController,
              decoration: textInputDecoration(),
              onChanged: (text) {
                double? valueDouble = double.tryParse(text);
                if (valueDouble != null) {
                  widget.item.setDouble(widget.propItem.name, valueDouble);
                }
                //widget.onChanged();
              },
            ),
          ),
        ),
      ],
    );
  }
}
