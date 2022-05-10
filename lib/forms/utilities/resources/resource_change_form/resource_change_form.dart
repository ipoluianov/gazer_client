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

class ResourceChangeForm extends StatefulWidget {
  final ResourceChangeFormArgument arg;
  const ResourceChangeForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ResourceChangeFormSt();
  }
}

class ResourceChangeFormSt extends State<ResourceChangeForm> {
  @override
  void initState() {
    super.initState();
    name = widget.arg.resInfo.getProp("name");
    textEditingControllerName.text = name;
    description = widget.arg.resInfo.getProp("description");
    textEditingControllerDescription.text = description;
  }

  String name = "";
  TextEditingController textEditingControllerName = TextEditingController();

  String description = "";
  TextEditingController textEditingControllerDescription = TextEditingController();

  bool loaded = false;
  bool loading = false;
  String errorMessage = "";

  void load() {
    /*if (loading) {
      return;
    }
    loading = true;
    Repository().client(widget.arg.connection).resGet1(id, offset, size).(widget.arg.id).then((value) {
      setState(() {
        _response = value;
      });
    }).catchError((e){
      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    });*/
  }

  Widget buildContent(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        child: Column(
          children: [
            TextField(
              controller: textEditingControllerName,
              onChanged: (newValue) {
                name = newValue;
              },
              decoration: const InputDecoration(
                label: Text("Name"),
              ),
            ),
            TextField(
              controller: textEditingControllerDescription,
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

  void save() {
    var client = Repository().client(widget.arg.connection);
    client.resPropSet(widget.arg.id, {"name": name, "description": description}).then((value) {
      Navigator.of(context).pop();
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
            "Rename " + (widget.arg.resInfo.type.endsWith("_folder") ? "Folder" : widget.arg.typeName),
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
