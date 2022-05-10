import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/protocol/service/service_info.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/forms/mores/users_form/user_card.dart';
import 'package:gazer_client/widgets/error_widget/error_block.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:gazer_client/widgets/title_widget/title_widget.dart';

class UsersForm extends StatefulWidget {
  final UsersFormArgument arg;
  const UsersForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UsersFormSt();
  }
}

class UsersFormSt extends State<UsersForm> {
  bool loading = false;
  bool loaded = false;
  String errorMessage = "";
  List<String> userList = [];

  @override
  void initState() {
    super.initState();
    loadUserList();
  }

  void loadUserList() {
    loading = true;
    Repository().client(widget.arg.connection).userList().then((value) {
      setState(() {
        userList = value.items;
        loaded = true;
        loading = false;
        errorMessage = "";
      });
    }).catchError((e){
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
        isAlwaysShown: true,
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Wrap(
              children: userList.map<Widget>(
                    (e) {
                  return UserCard(widget.arg.connection, e, () {
                    Navigator.of(context).pushNamed(
                      "/user",
                      arguments: UserFormArgument(
                        widget.arg.connection,
                        e,
                      ),
                    );
                  }, () {
                    Repository().client(widget.arg.connection).userRemove(e).then((value) {
                      loadUserList();
                    });
                  });
                },
              ).toList(),
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
            widget.arg.connection, "Users",
            actions: [
              buildActionButton(context, Icons.add, "Add User", () {
                Navigator.of(context).pushNamed("/user_add", arguments: UserAddFormArgument(widget.arg.connection));
              }),
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
