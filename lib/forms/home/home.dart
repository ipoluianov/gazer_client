import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';

import 'home_item.dart';
import 'home_item_map.dart';
import 'home_item_node_info.dart';

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

  late Timer _timer;

  @override
  void initState() {
    super.initState();
    load();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      load();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  bool loading = false;
  bool loaded = false;

  void load() {
    if (loading || loaded) {
      return;
    }

    loading = true;
  }

  void initDefault() {}

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
      buildItem(HomeItemMap(widget.arg, "")),
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

  int currentTitleKey = 0;
  void incrementTitleKey() {
    setState(() {
      currentTitleKey++;
    });
  }

  String getCurrentTitleKey() {
    return "units_$currentTitleKey";
  }
}
