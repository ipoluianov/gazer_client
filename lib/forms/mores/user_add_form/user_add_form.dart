import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/protocol/service/service_info.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:gazer_client/widgets/title_widget/title_widget.dart';

class UserAddForm extends StatefulWidget {
  final UserAddFormArgument arg;
  const UserAddForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UserAddFormSt();
  }
}

class UserAddFormSt extends State<UserAddForm> {
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
  }

  final TextEditingController _textEditingControllerUserName = TextEditingController();
  final TextEditingController _textEditingControllerPassword = TextEditingController();
  String userName = "";
  String password = "";

  void save() {
    Repository().client(widget.arg.connection).userAdd(userName, password).then((value) {
      Navigator.of(context).pop();
    });
  }

  Widget buildContent(BuildContext context) {
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
                  controller: _textEditingControllerUserName,
                  decoration: const InputDecoration(
                    label: Text("User Name"),
                    hintText: "User Name",
                  ),
                  onChanged: (newValue) {
                    setState(() {
                      userName = newValue;
                    });
                  },
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
            "Add user",
            actions: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton.icon(
                  onPressed: () {
                    save();
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("Add User"),
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
