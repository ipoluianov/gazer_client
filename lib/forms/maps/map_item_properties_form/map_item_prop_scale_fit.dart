import 'package:flutter/material.dart';
import 'package:gazer_client/forms/maps/map_form/main/map_item.dart';

class MapItemPropScaleFit extends StatefulWidget {
  final IPropContainer item;
  final MapItemPropItem propItem;

  const MapItemPropScaleFit(this.item, this.propItem, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemPropScaleFitSt();
  }
}

class MapItemPropScaleFitSt extends State<MapItemPropScaleFit> {
  late String value;
  TextEditingController txtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    value = widget.item.get(widget.propItem.name);
    txtController.text = value;
  }

  Color colorOfButton(String value) {
    Color result = Colors.transparent;
    String currentValue = widget.item.get(widget.propItem.name);
    if (value == currentValue) {
      result = Colors.blueAccent.withOpacity(0.5);
    }
    return result;
  }

  Color colorOfButtonText(String value) {
    Color result = Colors.white;
    String currentValue = widget.item.get(widget.propItem.name);
    if (value != currentValue) {
      result = Colors.blueAccent;
    }
    return result;
  }

  Widget makeButton(String value) {
    return Container(
      padding: const EdgeInsets.only(left: 3),
      child: OutlinedButton(
        onPressed: () {
          widget.item.set(widget.propItem.name, value);
        },
        child: Text(
          value,
          style: TextStyle(
            color: colorOfButtonText(value),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: colorOfButton(value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          makeButton("cover"),
          makeButton("contain"),
          makeButton("fill"),
        ],
      ),
    );
  }
}
