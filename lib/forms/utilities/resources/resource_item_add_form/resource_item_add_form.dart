import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/widgets/error_dialog/error_dialog.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:gazer_client/widgets/title_widget/title_widget.dart';

class ResourceItemAddForm extends StatefulWidget {
  final ResourceItemAddFormArgument arg;
  const ResourceItemAddForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ResourceItemAddFormSt();
  }
}

class ResourceItemAddFormSt extends State<ResourceItemAddForm> {
  @override
  void initState() {
    super.initState();
    //bloc.load();
  }

  InputDecoration textInputDecoration(String lbl) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 6),
      border: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.transparent),
      ),
      fillColor: Colors.black45,
      filled: true,
      label: Text(lbl),
      hoverColor: Colors.black12,
      constraints: const BoxConstraints(maxHeight: 40),
    );
  }

  String name = "";
  TextEditingController textEditingControllerName = TextEditingController();
  Widget buildContent(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Text(
                "Add ${widget.arg.typeName}",
                style: TextStyle(
                  fontSize: 20,
                  color: DesignColors.fore(),
                ),
              ),
            ),
            RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (event) {
                if (event.runtimeType == RawKeyDownEvent &&
                    (event.logicalKey == LogicalKeyboardKey.enter)) {
                  save();
                }
              },
              child: TextField(
                controller: textEditingControllerName,
                autofocus: true,
                onChanged: (newValue) {
                  name = newValue;
                },
                decoration: textInputDecoration("Name"),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: OutlinedButton.icon(
                onPressed: () {
                  save();
                },
                icon: const Icon(Icons.save),
                label: Container(
                  padding: EdgeInsets.all(20),
                  child: Text("Save"),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void save() {
    var client = Repository().client(widget.arg.connection);
    Uint8List list;
    String content = "";

    Uint8List bytes = Uint8List.fromList(content.codeUnits);

    client.resAdd(name, widget.arg.type, bytes).then((value) {
      var addResult = value;
      client.resPropSet(value.id, {"folder": widget.arg.folder}).then((value) {
        Navigator.of(context).pop(addResult);
      }).catchError((err) {
        showErrorDialog(context, "$err");
      });
    }).catchError((err) {
      showErrorDialog(context, "$err");
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool narrow = constraints.maxWidth < constraints.maxHeight;
        bool showLeft = !narrow;
        bool showBottom = narrow;

        return Scaffold(
          appBar: TitleBar(
            widget.arg.connection,
            "Add ${widget.arg.typeName}",
            actions: [
              buildHomeButton(context),
            ],
          ),
          body: Container(
            color: DesignColors.mainBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LeftNavigator(showLeft),
                      buildContent(context),
                    ],
                  ),
                ),
                BottomNavigator(showBottom),
              ],
            ),
          ),
        );
      },
    );
  }
}
