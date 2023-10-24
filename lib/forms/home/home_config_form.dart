import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/forms/home/home_config.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';

import '../../core/repository.dart';
import 'home_item.dart';
import 'home_item_map.dart';
import 'home_item_node_info.dart';

class HomeConfigForm extends StatefulWidget {
  final HomeConfigFormArgument arg;
  const HomeConfigForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeConfigFormSt();
  }
}

class HomeConfigFormSt extends State<HomeConfigForm> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildLoading(BuildContext context) {
    return Center(
      child: Container(
        color: Colors.black26,
        child: const Center(
            child: Text(
          "loading",
          style: TextStyle(
            color: Colors.blue,
            fontFamily: "BrunoAce",
            fontSize: 36,
          ),
        )),
      ),
    );
  }

  Widget buildContent() {
    if (widget.arg.item.get("type") == "map") {
      return HomeItemMapConfig(widget.arg);
    }
    return const Text("NO_CONFIG");
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
                            child: buildContent(),
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
