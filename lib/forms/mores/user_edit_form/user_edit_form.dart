import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/protocol/service/service_info.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/widgets/error_widget/error_block.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:gazer_client/widgets/title_widget/title_widget.dart';

class UserEditForm extends StatefulWidget {
  final UserEditFormArgument arg;
  const UserEditForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UserEditFormSt();
  }
}

class UserEditFormSt extends State<UserEditForm> {

  @override
  void initState() {
    super.initState();
    load();
    _textEditingControllerUserName.text = widget.arg.userName;
  }

  final TextEditingController _textEditingControllerUserName = TextEditingController();
  final TextEditingController _textEditingControllerDisplayName = TextEditingController();
  String displayName = "";


  bool loaded = false;
  bool loading = false;
  String errorMessage = "";

  void load() {
    if (loading) {
      return;
    }
    loading = true;
    Repository().client(widget.arg.connection).userPropGet(widget.arg.userName).then((value) {
      setState(() {
        for (var prop in value.props) {
          if (prop.propName == "display_name") {
            _textEditingControllerDisplayName.text = prop.propValue;
          }
        }
        errorMessage = "";
        loading = false;
        loaded = true;
      });
    }).catchError((e){
      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    });

  }

  void save() {
    Repository().client(widget.arg.connection).userPropSet(widget.arg.userName, {
      "display_name" : displayName
    }).then((value) {
      Navigator.of(context).pop();
    });
  }

  Widget buildContent(BuildContext context) {
    if (loading) {
      return const Text("loading ...");
    }

    if (errorMessage.isNotEmpty) {
      return ErrorBlock(errorMessage);
    }

    return Expanded(
      child: Scrollbar(
        isAlwaysShown: true,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  readOnly: true,
                  controller: _textEditingControllerUserName,
                  decoration: const InputDecoration(
                    label: Text("User Name"),
                    hintText: "User Name",
                  ),
                ),
                TextField(
                  controller: _textEditingControllerDisplayName,
                  decoration: const InputDecoration(
                    label: Text("Display Name"),
                    hintText: "Display Name",
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      displayName = newValue;
                    });
                  },
                ),
              ],
            ),
          ),
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
            widget.arg.connection, "Edit user",
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
