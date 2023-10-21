import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/gazer_local_client.dart';
import '../../core/gazer_style.dart';
import '../../core/protocol/unit/unit_state_all.dart';
import '../../core/tools/place_holders.dart';
import '../../widgets/map_viewer/map_viewer.dart';
import '../maps/map_form/main/map_view.dart';
import 'home_item.dart';

class HomeItemMap extends HomeItem {
  HomeItemMap(super.arg, super.config, {super.key});

  @override
  State<StatefulWidget> createState() {
    return HomeItemMapState();
  }
}

class HomeItemMapState extends State<HomeItemMap> {
  late Timer timerUpdate_;

  late MapView map;
  String mapId = "45bdd0f7-145e-4771-8cfd-95ef98476570";

  void load() {
    map.initMapInstance(widget.arg.connection);
    map.instance.loadFromResource(mapId, {}).then((value) {
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
      map.tick();
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
          widget.buildH1(
            "Map",
          ),
          buildContentMapArea(context, map)
        ],
      ),
    );
  }
}
