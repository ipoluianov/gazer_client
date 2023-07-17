import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/forms/maps/map_form/main/map_item.dart';
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
    String value = widget.item.get(widget.propItem.name);
    Color? colorPreview = colorFromHex(value);
    if (value.contains("{")) {
      colorPreview = DesignColors.paletteColor(value);
    }

    return Row(
      children: [
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
        /*Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(left: 3),
          decoration: BoxDecoration(
              color: colorPreview ?? Colors.transparent,
              border: Border.all(color: Colors.white30, width: 1)),
        ),*/
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
            ),
            //color: Colors.amber,
          ),
          //padding: const EdgeInsets.only(left: 1),
          child: IconButton(
            iconSize: 38,
            padding: EdgeInsets.zero,
            icon: Icon(Icons.square, color: colorPreview ?? Colors.transparent),
            color: Colors.white.withOpacity(0.5),
            onPressed: () {
              originalColorBeforeDialog = widget.item.get(widget.propItem.name);
              pickerColor =
                  colorFromHex(originalColorBeforeDialog) ?? Colors.blueAccent;
              if (originalColorBeforeDialog.contains("{")) {
                pickerColorSpecialCode = originalColorBeforeDialog;
              }
              showColorDialog("Select color .1");
            },
            //child: const Text("..."),
          ),
        ),
        Container(
          //width: 30,
          //padding: const EdgeInsets.only(left: 0),
          child: IconButton(
            icon: const Icon(Icons.clear),
            color: Colors.white.withOpacity(0.5),
            onPressed: () {
              setCurrentColor("");
            },
            //child: const Text("X"),
          ),
        ),
      ],
    );
  }

  Color pickerColor = const Color(0x00000000);
  String pickerColorSpecialCode = "";
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

  Widget buildColorButton(Color color, Function setState, bool inverse,
      {String specialCode = "", String specialName = ""}) {
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
              pickerColorSpecialCode = specialCode;
              if (specialCode != "") {
                setCurrentColor(specialCode);
              } else {
                setCurrentColor(colorToHex(color));
              }
            });
          },
          child: SizedBox(
            height: 50,
            child: Center(
              child: Text(
                specialName != "" ? specialName : colorToHex(color),
                style: TextStyle(color: inverse ? Colors.white : Colors.black),
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
      result.add(buildColorButton(colorHex("FF1BE5FD"), setState, false));
      result.add(buildColorButton(colorHex("FF02FC81"), setState, false));
      result.add(buildColorButton(colorHex("FFF90B1A"), setState, false));
      result.add(buildColorButton(colorHex("FFDD00FF"), setState, false));
    }
    if (column == 1) {
      result.add(buildColorButton(colorHex("FF063137"), setState, true));
      result.add(buildColorButton(colorHex("FF01371D"), setState, true));
      result.add(buildColorButton(colorHex("FF360206"), setState, true));
      result.add(buildColorButton(colorHex("FF2F0037"), setState, true));
    }
    if (column == 2) {
      result.add(buildColorButton(colorHex("FFFFFF00"), setState, false));
      result.add(buildColorButton(colorHex("FFFF8000"), setState, false));
      result.add(buildColorButton(colorHex("FF000080"), setState, true));
      result.add(buildColorButton(colorHex("FF0000FF"), setState, false));
    }
    if (column == 3) {
      result.add(buildColorButton(colorHex("FFFF0000"), setState, false));
      result.add(buildColorButton(colorHex("FF800000"), setState, true));
      result.add(buildColorButton(colorHex("FF00FF00"), setState, false));
      result.add(buildColorButton(colorHex("FF008000"), setState, false));
    }
    if (column == 4) {
      result.add(buildColorButton(colorHex("FF000000"), setState, true));
      result.add(buildColorButton(colorHex("FF404040"), setState, true));
      result.add(buildColorButton(colorHex("FF808080"), setState, false));
      result.add(buildColorButton(colorHex("FFFFFFFF"), setState, false));
    }
    if (column == 5) {
      result.add(buildColorButton(DesignColors.fore(), setState, true,
          specialCode: "{fore}", specialName: "FORE"));
      result.add(buildColorButton(DesignColors.fore1(), setState, true,
          specialCode: "{fore1}", specialName: "FORE1"));
      result.add(buildColorButton(DesignColors.back(), setState, true,
          specialCode: "{back}", specialName: "BACK"));
      result.add(buildColorButton(DesignColors.back1(), setState, true,
          specialCode: "{back1}", specialName: "BACK1"));
    }
    return result;
  }

  Widget colorPickerPalette(BuildContext context, Function setState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
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
        Row(
          children: colorsByColumn(3, setState),
        ),
        Row(
          children: colorsByColumn(4, setState),
        ),
        Row(
          children: colorsByColumn(5, setState),
        ),
      ],
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
                  child: const Text("Palette"),
                ),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      colorPickerCurrentTypeIndex = 1;
                    });
                  },
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
                  child: const Text("Free"),
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

  Widget colorDialogContentOriginal(BuildContext context, Function setState) {
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
                  child: const Text("Palette"),
                ),
              ),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      colorPickerCurrentTypeIndex = 1;
                    });
                  },
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
                  child: const Text("Free"),
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
            backgroundColor: DesignColors.back(),
            shadowColor: DesignColors.fore(),
            title: Text(text),
            content: SingleChildScrollView(
              child: colorDialogContent(context, setState),
            ),
            actions: <Widget>[
              ElevatedButton(
                child: const SizedBox(
                  width: 100,
                  height: 30,
                  child: Center(
                    child: Text('OK'),
                  ),
                ),
                onPressed: () {
                  if (pickerColorSpecialCode != "") {
                    setCurrentColor(pickerColorSpecialCode);
                  } else {
                    setCurrentColor(colorToHex(pickerColor));
                  }
                  Navigator.of(context).pop();
                },
              ),
              OutlinedButton(
                child: const SizedBox(
                  width: 100,
                  height: 30,
                  child: Center(
                    child: Text('Cancel'),
                  ),
                ),
                onPressed: () {
                  setCurrentColor(originalColorBeforeDialog);
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
