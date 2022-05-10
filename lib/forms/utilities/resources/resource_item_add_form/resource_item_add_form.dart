import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
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

  String name = "";
  TextEditingController textEditingControllerName = TextEditingController();
  Widget buildContent(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        child: Column(
          children: [
            TextField(
              controller: textEditingControllerName,
              autofocus: true,
              onChanged: (newValue) {
                name = newValue;
              },
              decoration: const InputDecoration(
                label: Text("Name"),
              ),
            ),
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
      });
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
            "Add " + widget.arg.typeName,
            actions: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton.icon(
                  onPressed: () {
                    save();
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                ),
              ),
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
