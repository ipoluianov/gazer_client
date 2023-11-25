import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';

import '../../../core/repository.dart';
import 'more_button.dart';

class MoreForm extends StatefulWidget {
  final MoreFormArgument arg;
  const MoreForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MoreFormSt();
  }
}

class MoreFormSt extends State<MoreForm> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  Widget buildHeader(BuildContext context, String header) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          padding: EdgeInsets.only(bottom: 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.green,
                width: 3,
              ),
            ),
          ),
          child: Text(
            header,
            style: TextStyle(
              fontSize: 24,
              color: DesignColors.fore(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> buildRemoteAccess(BuildContext context) {
    List<Widget> result = [
      MoreButton(() {
        Navigator.pushNamed(context, "/guest_access",
            arguments: GuestAccessFormArgument(widget.arg.connection));
      }, "Share\r\nGUEST Access",
          const Icon(cupertino.CupertinoIcons.share, size: 48), 0),
      MoreButton(() {
        Navigator.pushNamed(context, "/access",
            arguments: AccessFormArgument(widget.arg.connection));
      }, "Share\r\nFULL Access", const Icon(Icons.shield_outlined, size: 48),
          1),
      MoreButton(() {
        Navigator.pushNamed(context, "/billing",
            arguments: BillingFormArgument(widget.arg.connection));
      }, "PREMIUM", const Icon(Icons.auto_awesome, size: 48), 2),
    ];
    return [buildHeader(context, "Remote Access"), Wrap(children: result)];
  }

  List<Widget> buildNodeSettings(BuildContext context) {
    List<Widget> result = [
      MoreButton(() {
        Repository().client(widget.arg.connection).serviceInfo().then((value) {
          _textFieldController.text = value.nodeName;
          _displayNodeNameDialog(context).then((value) {
            incrementTitleKey();
          });
        }).catchError((err) {});
      }, "Rename node", const Icon(Icons.abc, size: 48), 4),
    ];
    return [buildHeader(context, "Node Settings"), Wrap(children: result)];
  }

  List<Widget> buildAppInfo(BuildContext context) {
    List<Widget> result = [
      MoreButton(() {
        Navigator.pushNamed(context, "/tools_menu",
            arguments: ToolsFormArgument());
      }, "Tools", const Icon(Icons.apps, size: 48), 3),
      MoreButton(() {
        Navigator.pushNamed(context, "/appearance",
            arguments: AppearanceFormArgument(widget.arg.connection));
      }, "Appearance", const Icon(Icons.settings, size: 48), 3),
      MoreButton(() {
        Navigator.pushNamed(context, "/about",
            arguments: AboutFormArgument(widget.arg.connection));
      }, "About", const Icon(Icons.info_outline, size: 48), 5),
    ];
    return [buildHeader(context, "Application"), Wrap(children: result)];
  }

  List<Widget> buildContent(BuildContext context) {
    List<Widget> result = [];
    result.addAll(buildNodeSettings(context));
    result.addAll(buildRemoteAccess(context));
    result.addAll(buildAppInfo(context));
    return result;
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
            "More",
            actions: <Widget>[
              buildHomeButton(context),
            ],
            key: Key(getCurrentTitleKey()),
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
                      Expanded(
                        child: DesignColors.buildScrollBar(
                          controller: _scrollController,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: buildContent(context),
                            ),
                          ),
                        ),
                      ),
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

  String txtNodeName = "";
  final TextEditingController _textFieldController = TextEditingController();

  int currentTitleKey = 0;
  void incrementTitleKey() {
    setState(() {
      currentTitleKey++;
    });
  }

  String getCurrentTitleKey() {
    return "units_" + currentTitleKey.toString();
  }

  Future<void> _displayNodeNameDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: DesignColors.back(),
            shadowColor: DesignColors.fore(),
            title: const Text('Rename node'),
            content: TextField(
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  txtNodeName = value;
                });
              },
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: "Node Name"),
            ),
            actions: <Widget>[
              OutlinedButton(
                child: const SizedBox(
                  width: 70,
                  child: Center(child: Text('OK')),
                ),
                onPressed: () {
                  setState(() {
                    Repository()
                        .client(widget.arg.connection)
                        .serviceSetNodeName(txtNodeName)
                        .then((value) {
                      Navigator.pop(context);
                    });
                  });
                },
              ),
              OutlinedButton(
                child: const SizedBox(
                  width: 70,
                  child: Center(child: Text('Cancel')),
                ),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
            ],
          );
        });
  }
}
