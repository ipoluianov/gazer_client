import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/protocol/resource/resource_list.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:gazer_client/widgets/title_widget/title_widget.dart';

import '../../../../widgets/error_dialog/error_dialog.dart';

class ResourceInfoForm extends StatefulWidget {
  final ResourceInfoFormArgument arg;
  const ResourceInfoForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ResourceInfoFormSt();
  }
}

class ResourceInfoFormSt extends State<ResourceInfoForm> {
  @override
  void initState() {
    super.initState();
    id = widget.arg.resInfo.id;
    textEditingControllerId.text = id;
    name = widget.arg.resInfo.getProp("name");
    textEditingControllerName.text = name;
    description = widget.arg.resInfo.getProp("description");
    textEditingControllerDescription.text = description;
  }

  String id = "";
  TextEditingController textEditingControllerId = TextEditingController();

  String name = "";
  TextEditingController textEditingControllerName = TextEditingController();

  String description = "";
  TextEditingController textEditingControllerDescription =
      TextEditingController();

  bool loaded = false;
  bool loading = false;
  String errorMessage = "";

  Widget buildContent(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        child: Column(
          children: [
            TextField(
              controller: textEditingControllerId,
              readOnly: true,
              decoration: const InputDecoration(
                label: Text("Id"),
              ),
            ),
            TextField(
              controller: textEditingControllerName,
              readOnly: true,
              onChanged: (newValue) {
                name = newValue;
              },
              decoration: const InputDecoration(
                label: Text("Name"),
              ),
            ),
            TextField(
              controller: textEditingControllerDescription,
              readOnly: true,
              onChanged: (newValue) {
                description = newValue;
              },
              decoration: const InputDecoration(
                label: Text("Description"),
              ),
            ),
          ],
        ),
      ),
    );
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
            widget.arg.resInfo.type.endsWith("_folder")
                ? "Folder"
                : widget.arg.typeName,
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
