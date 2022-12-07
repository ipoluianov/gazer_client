import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/protocol/service/service_info.dart';
import 'package:gazer_client/core/protocol/user/session_list.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/forms/mores/user_form/session_card.dart';
import 'package:gazer_client/widgets/error_widget/error_block.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:gazer_client/widgets/title_widget/title_widget.dart';

class UserForm extends StatefulWidget {
  final UserFormArgument arg;
  const UserForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UserFormSt();
  }
}

class UserFormSt extends State<UserForm> {
  bool loaded = false;
  bool loading = false;
  String errorMessage = "";

  @override
  void initState() {
    super.initState();
    loadSessionList();
  }

  List<SessionListItemResponse> sessionList = [];

  void loadSessionList() {
    if (loading) {
      return;
    }
    loading = true;
    Repository()
        .client(widget.arg.connection)
        .sessionList(widget.arg.userName)
        .then((value) {
      setState(() {
        sessionList = value.items;
        loading = false;
        loaded = true;
        errorMessage = "";
      });
    }).catchError((e) {
      setState(() {
        loading = false;
        errorMessage = e.toString();
      });
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
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    "User [${widget.arg.userName}]",
                    style: const TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(6),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(6),
                            child: Text("User: " + widget.arg.userName)),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                "/user_set_password",
                                arguments: UserSetPasswordFormArgument(
                                  widget.arg.connection,
                                  widget.arg.userName,
                                ),
                              );
                            },
                            child: const Text("Change Password"),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).pushNamed(
                                "/user_edit",
                                arguments: UserEditFormArgument(
                                  widget.arg.connection,
                                  widget.arg.userName,
                                ),
                              );
                            },
                            child: const Text("Edit"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  child: const Text(
                    "Sessions:",
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                ),
                Wrap(
                  children: sessionList.map<Widget>(
                    (e) {
                      return SessionCard(widget.arg.connection, e, () {}, () {
                        Repository()
                            .client(widget.arg.connection)
                            .sessionRemove(e.sessionToken)
                            .then((value) {
                          loadSessionList();
                        });
                      });
                    },
                  ).toList(),
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
            "User [" + widget.arg.userName + "]",
            actions: <Widget>[
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
