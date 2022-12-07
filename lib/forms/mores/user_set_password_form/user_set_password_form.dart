import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/protocol/service/service_info.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:gazer_client/widgets/title_widget/title_widget.dart';

class UserSetPasswordForm extends StatefulWidget {
  final UserSetPasswordFormArgument arg;
  const UserSetPasswordForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UserSetPasswordFormSt();
  }
}

class UserSetPasswordFormSt extends State<UserSetPasswordForm> {
  bool serviceInfoLoaded = false;
  late ServiceInfoResponse serviceInfo;
  void loadNodeInfo() {
    Repository().client(widget.arg.connection).serviceInfo().then((value) {
      setState(() {
        serviceInfo = value;
        serviceInfoLoaded = true;
      });
    });
  }

  String nodeName() {
    if (serviceInfoLoaded) {
      return serviceInfo.nodeName;
    }
    return widget.arg.connection.address;
  }

  @override
  void initState() {
    super.initState();
    loadNodeInfo();
    _textEditingControllerUserName.text = widget.arg.userName;
  }

  final TextEditingController _textEditingControllerUserName =
      TextEditingController();
  final TextEditingController _textEditingControllerPassword =
      TextEditingController();
  String password = "";

  void save() {
    Repository()
        .client(widget.arg.connection)
        .userSetPassword(widget.arg.userName, password)
        .then((value) {
      Navigator.of(context).pop();
    });
  }

  Widget buildContent(BuildContext context) {
    return Expanded(
      child: Scrollbar(
        thumbVisibility: true,
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
                  controller: _textEditingControllerPassword,
                  decoration: const InputDecoration(
                    label: Text("Password"),
                    hintText: "Password",
                  ),
                  obscureText: true,
                  onChanged: (newValue) {
                    setState(() {
                      password = newValue;
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
            widget.arg.connection,
            "Change user password",
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
