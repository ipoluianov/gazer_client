import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/forms/utilities/lookup_form/lookup_form.dart';
import 'package:gazer_client/forms/maps/map_form/map_item.dart';

import '../../../core/navigation/route_generator.dart';

class MapItemPropImage extends StatefulWidget {
  final IPropContainer item;
  final MapItemPropItem propItem;

  const MapItemPropImage(this.item, this.propItem, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemPropImageSt();
  }
}

class MapItemPropImageSt extends State<MapItemPropImage> {
  late String value;
  TextEditingController txtController = TextEditingController();
  Uint8List imageBytes = Uint8List(0);

  @override
  void initState() {
    super.initState();
    value = widget.item.get(widget.propItem.name);
    txtController.text = value;
    imageBytes = base64Decode(widget.item.get(widget.propItem.name));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(children: [
        SizedBox(
          width: 100,
          height: 64,
          child: imageBytes.isNotEmpty ? Image.memory(imageBytes, fit: BoxFit.contain) : Container(color: Colors.black54),
        ),
        Expanded(child: Container()),
        OutlinedButton(
            onPressed: () {
              widget.item.set(widget.propItem.name, "");
              setState(() {
                imageBytes = Uint8List(0);
              });
            },
            child: const Text("X")),
        OutlinedButton(
            onPressed: () {
              FilePicker.platform.pickFiles().then((value) {
                if (value != null) {
                  File file = File(value.files.first.name);
                  file.readAsBytes().then((value) {
                    widget.item.set(widget.propItem.name, base64Encode(value));
                    setState(() {
                      imageBytes = value;
                    });
                  });
                } else {
                  // User canceled the picker
                }
              });
            },
            child: const Text("...")),
      ]),
    );
  }
}
