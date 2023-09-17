import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';

import '../../../core/repository.dart';
import 'home_item.dart';
import 'home_item_node_info.dart';
import 'home_item_unit_items.dart';

class HomeForm extends StatefulWidget {
  final HomeFormArgument arg;
  const HomeForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeFormSt();
  }
}

class HomeFormSt extends State<HomeForm> {
  final ScrollController _scrollController = ScrollController();

  Widget buildItem(HomeItem innerItem) {
    List<Widget> ws = [];
    ws.add(
      Container(
        constraints: const BoxConstraints(minHeight: 6),
        color: Colors.transparent,
      ),
    );
    ws.add(innerItem);

    return Container(
      margin: const EdgeInsets.only(top: 10, bottom: 20, left: 10, right: 10),
      //constraints: BoxConstraints(maxWidth: 500),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: ws,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> items() {
    return [
      buildItem(HomeItemNodeInfo(widget.arg, "")),
    ];
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
            "Node",
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
                            child: Wrap(
                              children: items(),
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
                child: const Text('OK'),
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
                child: const Text('CANCEL'),
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
