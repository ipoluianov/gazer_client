import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/protocol/resource/resource_list.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/forms/home/home_config.dart';
import 'package:gazer_client/widgets/borders/border_01_item.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/gazer_local_client.dart';
import '../../core/gazer_style.dart';
import '../../core/navigation/route_generator.dart';
import '../../core/protocol/unit/unit_state_all.dart';
import '../../core/tools/place_holders.dart';
import '../../core/workspace/workspace.dart';
import '../../widgets/borders/border_02_titlebar.dart';
import '../../widgets/borders/border_03_item_details.dart';
import '../../widgets/borders/border_04_action_button.dart';
import '../../widgets/map_viewer/map_viewer.dart';
import '../maps/map_form/main/map_view.dart';
import 'home_item.dart';

class HomeItemMap extends HomeItem {
  HomeItemMap(super.arg, super.config, super.onEdit, super.onRemove, super.onUp,
      super.onDown,
      {super.key});

  @override
  State<StatefulWidget> createState() {
    return HomeItemMapState();
  }
}

class HomeItemMapState extends State<HomeItemMap> {
  late Timer timerUpdate_;

  late MapView map;
  //String mapId = "6fa151ee-db0f-4d08-b112-3f6b9974f903";

  void load() {
    map.initMapInstance(widget.arg.connection);
    map.instance.loadFromResource(widget.config.get("id"), {}).then((value) {
      print("loaded");
      map.entire();
    });
  }

  @override
  void initState() {
    super.initState();
    map = MapView(widget.arg.connection);
    load();
    timerUpdate_ = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      setState(() {
        map.tick();
      });
    });
  }

  @override
  void dispose() {
    timerUpdate_.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widget.buildH1(context, "Map", true, true, true),
          buildContentMapArea(context, map)
        ],
      ),
    );
  }
}

class HomeItemMapConfig extends StatefulWidget {
  final HomeConfigFormArgument arg;
  const HomeItemMapConfig(this.arg, {super.key});

  @override
  State<StatefulWidget> createState() {
    return HomeItemMapConfigState();
  }
}

class HomeItemMapConfigState extends State<HomeItemMapConfig> {
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

  ResListResponse? response;

  bool saved = false;

  void load() {
    if (loading || loaded) {
      return;
    }
    setState(() {
      loading = true;
    });

    var client = Repository().client(widget.arg.connection);
    client.resList("map", "", 0, 1000).then((value) {
      print("--------------------- res: $value");
      loaded = true;
      loading = false;
      setState(() {
        response = value;
      });
    }).catchError((err) {
      print("Error: $err");
      loading = false;
    });
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    List<Widget> result = [];
    if (response == null) {
      return const Text("HomeItemMapConfigState");
    }
    for (var i in response!.item.items) {
      result.add(
        Container(
          margin: const EdgeInsets.all(10),
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                widget.arg.item.set("id", i.id);
                Navigator.of(context).pop(widget.arg.item);
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
                        i.getProp("name"),
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
    return Expanded(
      child: DesignColors.buildScrollBar(
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  "Select map",
                  style: TextStyle(
                    color: Colors.blue,
                    fontFamily: "BrunoAce",
                    fontSize: 36,
                  ),
                ),
              ),
              Wrap(
                children: result,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
