import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gazer_client/forms/maps/map_form/main/map_item.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/styles.dart';

class MapItemPropMultiline extends StatefulWidget {
  final IPropContainer item;
  final MapItemPropItem propItem;

  const MapItemPropMultiline(this.item, this.propItem, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemPropMultilineSt();
  }
}

class MapItemPropMultilineSt extends State<MapItemPropMultiline> {
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
    return Row(children: [
      Expanded(
        child: Container(),
      ),
      Container(
        padding: const EdgeInsets.only(left: 1),
        child: OutlinedButton(
          onPressed: () {
            originalTextBeforeDialog = widget.item.get(widget.propItem.name);
            textFieldController.text = originalTextBeforeDialog;
            showColorDialog("Text editor");
          },
          child: const Text("..."),
        ),
      ),
    ]);
  }

  String pickerText = "";
  String originalTextBeforeDialog = "";

  void changeText(String text) {
    setState(() {
      pickerText = text;
      setCurrentText(text);
    });
  }

  void setCurrentText(String colorString) {
    widget.item.set(widget.propItem.name, colorString);
    txtController.text = colorString;
  }

  int colorPickerCurrentTypeIndex = 0;

  Widget buildColorButton(String text, Function setState) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(2),
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              pickerText = text;
              setCurrentText(text);
            });
          },
          child: SizedBox(
            height: 50,
            child: Center(
              child: Text(
                text,
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
  }

  TextEditingController textFieldController = TextEditingController();

  Widget textDialogContent(BuildContext context, Function setState) {
    return SizedBox(
      width: 400,
      child: TextField(
        controller: textFieldController,
        minLines: 10,
        maxLines: 10,
        onChanged: (text) {
          setState(() {
            pickerText = text;
            widget.item.set(widget.propItem.name, text);
          });
        },
      ),
    );
  }

  Future<void> showColorDialog(String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            title: Text(text),
            content: SingleChildScrollView(
              child: textDialogContent(context, setState),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  setCurrentText(originalTextBeforeDialog);
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  //setCurrentText(pickerText);
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
