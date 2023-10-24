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
import '../../widgets/borders/border_01_item.dart';
import 'home_item.dart';
import 'home_item_map.dart';
import 'home_item_node_info.dart';

class HomeAddItem extends StatefulWidget {
  final HomeAddItemArgument arg;
  const HomeAddItem(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomeAddItemSt();
  }
}

class HomeAddItemEntry {
  String typeName;
  String displayName;
  HomeAddItemEntry(this.typeName, this.displayName);
}

class HomeAddItemSt extends State<HomeAddItem> {
  final ScrollController _scrollController = ScrollController();

  List<HomeAddItemEntry> items = [];

  @override
  void initState() {
    super.initState();
    items.add(HomeAddItemEntry("node_info", "Node Info"));
    items.add(HomeAddItemEntry("map", "Map"));
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

  List<Widget> itemsWidgets() {
    List<Widget> result = [];
    for (var item in items) {
      result.add(
        Container(
          margin: const EdgeInsets.all(10),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                HomeConfigItem newItem =
                    HomeConfigItem([HomeConfigItemProp("type", item.typeName)]);
                Navigator.of(context).pop(newItem);
              },
              child: Stack(
                children: [
                  SizedBox(
                    width: 300,
                    height: 70,
                    child: Border01Painter.build(false),
                  ),
                  SizedBox(
                    //margin: const EdgeInsets.all(10),
                    width: 300,
                    height: 70,
                    child: Center(
                      child: Text(
                        item.displayName,
                        style: TextStyle(color: DesignColors.fore()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
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
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(20),
                              child: Text(
                                "Add Item",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontFamily: "BrunoAce",
                                  fontSize: 36,
                                ),
                              ),
                            ),
                            DesignColors.buildScrollBar(
                              controller: _scrollController,
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: Wrap(
                                  children: itemsWidgets(),
                                ),
                              ),
                            ),
                          ],
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
