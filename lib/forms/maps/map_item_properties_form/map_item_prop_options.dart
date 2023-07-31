import 'package:flutter/material.dart';
import 'package:gazer_client/forms/maps/map_form/main/map_item.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/styles.dart';

class MapItemPropOptions extends StatefulWidget {
  final IPropContainer item;
  final MapItemPropItem propItem;

  const MapItemPropOptions(this.item, this.propItem, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemPropOptionsSt();
  }
}

class MapItemPropOptionsSt extends State<MapItemPropOptions> {
  late String value;

  @override
  void initState() {
    super.initState();
    value = widget.item.get(widget.propItem.name);
  }

  Widget buildOptionButton(
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

  List<Widget> buttons() {
    List<String> options = [];

    options = widget.propItem.type.split(":");
    options.removeAt(0);

    Color colActive = Colors.amber;
    Color colReg = Colors.white.withOpacity(0.5);

    List<Widget> result = [];
    for (int i = 0; i < options.length; i++) {
      result.add(buildOptionButton(
          options[i],
          options[i],
          Icons.abc,
          widget.item.get(widget.propItem.name) == options[i]
              ? colActive
              : colReg));
    }
    return result;
  }

//
  @override
  Widget build(BuildContext context) {
    Color colActive = Colors.amber;
    Color colReg = Colors.white.withOpacity(0.5);
    return Wrap(
      children: buttons(),
    );
  }
}
