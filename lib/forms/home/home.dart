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
    initDefault();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      //load();
      save();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  bool loading = false;
  bool loaded = false;
  HomeConfig currentConfig = HomeConfig([]);

  bool saved = false;

  void load() {
    if (loading || loaded) {
      return;
    }

    var client = Repository().client(widget.arg.connection);
    client.resGetByPath("/home/currentConfig", 0, 100000).then((value) {
      print("res: $value");
      loaded = true;
    }).catchError((err) {
      print("Error: $err");
      loading = false;
    });

    loading = true;
  }

  void save() {
    print(saveToString());
    if (saved) return;
    //asdada = 4;

    String content = saveToString();

    var client = Repository().client(widget.arg.connection);
    client
        .resSetByPath(
      "home_currentConfig",
      "",
      Uint8List.fromList(content.codeUnits),
    )
        .then((value) {
      print("save res: $value");
    }).catchError((err) {
      print("save Error: $err");
    });
    saved = true;
  }

  void loadConfig(String config) {
    currentConfig = HomeConfig.fromJson(jsonDecode(config));
  }

  void initDefault() {
    loadConfig(
        "{\"items\":[{\"props\": [ {\"name\":\"type\", \"value\":\"node_info\"}]}]}");
  }

  String saveToString() {
    return jsonEncode(currentConfig.toJson());
  }

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
    List<Widget> result = [];
    for (var item in currentConfig.items) {
      if (item.get("type") == "node_info") {
        result.add(buildItem(HomeItemNodeInfo(widget.arg, "")));
      }
    }
    return result;
    /*return [
      buildItem(HomeItemNodeInfo(widget.arg, "")),
      buildItem(HomeItemMap(widget.arg, "")),
    ];*/
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
