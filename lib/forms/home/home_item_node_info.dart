import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/repository.dart';

import '../../core/gazer_local_client.dart';
import '../../core/gazer_style.dart';
import '../../core/protocol/unit/unit_state_all.dart';
import 'home_item.dart';

class HomeItemNodeInfo extends HomeItem {
  const HomeItemNodeInfo(super.arg, super.config, {super.key});

  @override
  State<StatefulWidget> createState() {
    return HomeItemNodeInfoState();
  }

  @override
  String title() {
    return "Node Information";
  }
}

class HomeItemNodeInfoState extends State<HomeItemNodeInfo> {
  late Timer timerUpdate_;

  @override
  void initState() {
    super.initState();
    timerUpdate_ = Timer.periodic(const Duration(seconds: 1), (timer) {
      load();
    });
  }

  @override
  void dispose() {
    timerUpdate_.cancel();
    super.dispose();
  }

  bool loading = false;
  bool loaded = false;
  List<UnitStateAllItemResponse> items = [];

  String loadingError = "";
  String nodeName = "";

  void load() {
    setState(() {
      loading = true;
    });
    GazerLocalClient client = Repository().client(widget.arg.connection);
    client.unitsStateAll().then((value) {
      if (mounted) {
        setState(() {
          items = value.items;
          loading = false;
          loaded = true;
          loadingError = "";
        });
      }
    }).catchError((err) {
      if (mounted) {
        setState(() {
          loadingError = err.toString();
          loading = false;
        });
      }
    });
  }

  Widget buildCommonInfo(BuildContext context) {
    var textStyle = const TextStyle(fontFamily: "RobotoMono");
    var serviceInfo =
        Repository().client(widget.arg.connection).lastServiceInfo;
    String address = Repository().client(widget.arg.connection).address;
    if (serviceInfo != null) {
      nodeName = serviceInfo.nodeName;
      int? dtNano = int.tryParse(serviceInfo.time);
      DateTime nodeTime = DateTime.fromMicrosecondsSinceEpoch(0);
      if (dtNano != null) {
        nodeTime = DateTime.fromMicrosecondsSinceEpoch(dtNano ~/ 1000);
      }
      return Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: DesignColors.fore1(),
              width: 3,
            ),
          ),
        ),
        padding: const EdgeInsets.only(left: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${serviceInfo.nodeName}", style: textStyle),
            Text("Version: ${serviceInfo.version}", style: textStyle),
            Text("Time: $nodeTime", style: textStyle),
            Text("Address: $address", style: textStyle),
          ],
        ),
      );
    }
    return const Text("-------------");
  }

  Widget buildUnits(BuildContext context) {
    List<Widget> widgets = [];

    for (var unit in items) {
      String itemShortName = unit.mainItem.replaceAll("${unit.unitId}/", "");

      widgets.add(
        Container(
          //color: DesignColors.back2(),
          margin: const EdgeInsets.only(
            left: 0,
            top: 0,
            bottom: 12,
            right: 6,
          ),
          constraints: const BoxConstraints(minWidth: 300, maxWidth: 300),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                width: 3,
                color: colorByUOM(unit.uom),
              ),
            ),
          ),
          padding: const EdgeInsets.only(left: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                unit.unitName,
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: DesignColors.fore(),
                  fontSize: 16,
                ),
              ),
              Text(
                "$itemShortName = ${unit.value} ${unit.uom}",
                style: TextStyle(
                  overflow: TextOverflow.ellipsis,
                  color: colorByUOM(unit.uom),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: Wrap(
        children: widgets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var serviceInfo =
        Repository().client(widget.arg.connection).lastServiceInfo;
    if (serviceInfo != null) {
      nodeName = serviceInfo.nodeName;
    }
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widget.buildH1(
            "NODE '$nodeName'",
          ),
          buildCommonInfo(context),
          widget.buildH1("UNITS"),
          buildUnits(context),
        ],
      ),
    );
  }
}
