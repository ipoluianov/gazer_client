import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gazer_client/forms/maps/map_form/map_item.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/styles.dart';

class MapItemPropColor extends StatefulWidget {
  final IPropContainer item;
  final MapItemPropItem propItem;

  const MapItemPropColor(this.item, this.propItem, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemPropColorSt();
  }
}

class MapItemPropColorSt extends State<MapItemPropColor> {
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
        child: TextField(
          controller: txtController,
          decoration: textInputDecoration(),
          onChanged: (text) {
            setState(() {
              widget.item.set(widget.propItem.name, text);
            });
            //widget.onChanged();
          },
        ),
      ),
      Container(
        width: 24,
        height: 24,
        margin: EdgeInsets.only(left: 3),
        decoration: BoxDecoration(
            color: colorFromHex(widget.item.get(widget.propItem.name)) ??
                Colors.transparent,
            border: Border.all(color: Colors.white30, width: 1)),
      ),
      Container(
        padding: EdgeInsets.only(left: 3),
        child: OutlinedButton(
          onPressed: () {
            setCurrentColor("");
          },
          child: const Text("X"),
        ),
      ),
      Container(
        padding: const EdgeInsets.only(left: 1),
        child: OutlinedButton(
          onPressed: () {
            originalColorBeforeDialog = widget.item.get(widget.propItem.name);
            pickerColor =
                colorFromHex(originalColorBeforeDialog) ?? Colors.blueAccent;
            showColorDialog("Select color");
          },
          child: const Text("..."),
        ),
      ),
    ]);
  }

  Color pickerColor = const Color(0x00000000);
  String originalColorBeforeDialog = "";

  void changeColor(Color color) {
    setState(() {
      pickerColor = color;
      setCurrentColor(colorToHex(color));
    });
  }

  void setCurrentColor(String colorString) {
    widget.item.set(widget.propItem.name, colorString);
    txtController.text = colorString;
  }

  int colorPickerCurrentTypeIndex = 0;

  Widget colorPickerFree(BuildContext context) {
    return ColorPicker(
      pickerColor: pickerColor,
      onColorChanged: changeColor,
    );
  }

  Widget buildColorButton(Color color, Function setState) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(2),
        child: OutlinedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(color),
          ),
          onPressed: () {
            setState(() {
              pickerColor = color;
              setCurrentColor(colorToHex(color));
            });
          },
          child: SizedBox(
            height: 50,
            child: Center(
              child: Text(
                colorToHex(color),
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color colorHex(String colHex) {
    Color? c = colorFromHex(colHex);
    return c ?? Colors.transparent;
  }

  List<Widget> colorsByColumn(int column, Function setState) {
    List<Widget> result = [];
    if (column == 0) {
      result.add(buildColorButton(Colors.red, setState));
      result.add(buildColorButton(Colors.blueAccent, setState));
      result.add(buildColorButton(Colors.yellowAccent, setState));
    }
    if (column == 1) {
      result.add(buildColorButton(Colors.green, setState));
      result.add(buildColorButton(Colors.white, setState));
      result.add(buildColorButton(Colors.cyan, setState));
    }
    if (column == 2) {
      result.add(buildColorButton(Colors.teal, setState));
      result.add(buildColorButton(Colors.deepPurpleAccent, setState));
      result.add(buildColorButton(Colors.purpleAccent, setState));
    }
    if (column == 3) {
      result.add(buildColorButton(colorHex("FF000000"), setState));
      result.add(buildColorButton(colorHex("FF333333"), setState));
      result.add(buildColorButton(colorHex("FF555555"), setState));
    }
    return result;
  }

  Widget colorPickerPalette(BuildContext context, Function setState) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.all(10),
                child: SizedBox(
                  width: 200,
                  height: 50,
                  child: Container(
                    color: pickerColor,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: colorsByColumn(0, setState),
          ),
          Row(
            children: colorsByColumn(1, setState),
          ),
          Row(
            children: colorsByColumn(2, setState),
          ),
        ],
      ),
    );
  }

  Widget colorPicker(BuildContext context, Function setState) {
    if (colorPickerCurrentTypeIndex == 0) {
      return colorPickerPalette(context, setState);
    }
    if (colorPickerCurrentTypeIndex == 1) {
      return colorPickerFree(context);
    }
    return colorPickerPalette(context, setState);
  }

  Widget colorDialogContent(BuildContext context, Function setState) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(6),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      colorPickerCurrentTypeIndex = 0;
                    });
                  },
                  child: const Text("Palette"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        colorPickerCurrentTypeIndex == 0
                            ? Colors.blueAccent
                            : Colors.transparent),
                    foregroundColor: MaterialStateProperty.all(
                        colorPickerCurrentTypeIndex == 0
                            ? Colors.white
                            : Colors.blueAccent),
                  ),
                ),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      colorPickerCurrentTypeIndex = 1;
                    });
                  },
                  child: const Text("Free"),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(
                        colorPickerCurrentTypeIndex == 1
                            ? Colors.blueAccent
                            : Colors.transparent),
                    foregroundColor: MaterialStateProperty.all(
                        colorPickerCurrentTypeIndex == 1
                            ? Colors.white
                            : Colors.blueAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 1,
          child: Container(
            color: Colors.white38,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(6),
          child: colorPicker(context, setState),
        ),
        SizedBox(
          width: 400,
          child: Container(),
        ),
      ],
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
              child: colorDialogContent(context, setState),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const Text('Cancel'),
                onPressed: () {
                  setCurrentColor(originalColorBeforeDialog);
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: const Text('OK'),
                onPressed: () {
                  setCurrentColor(colorToHex(pickerColor));
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
