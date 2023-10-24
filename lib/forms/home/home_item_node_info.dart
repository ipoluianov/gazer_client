import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/gazer_local_client.dart';
import '../../core/gazer_style.dart';
import '../../core/protocol/unit/unit_state_all.dart';
import '../../core/tools/place_holders.dart';
import 'home_item.dart';

class HomeItemNodeInfo extends HomeItem {
  HomeItemNodeInfo(super.arg, super.config, super.onEdit, super.onRemove,
      super.onUp, super.onDown,
      {super.key});

  @override
  State<StatefulWidget> createState() {
    return HomeItemNodeInfoState();
  }
}

class HomeItemNodeInfoState extends State<HomeItemNodeInfo> {
  late Timer timerUpdate_;

  @override
  void initState() {
    super.initState();
    load();
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

  Widget loadingPlaceHolder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade500,
      highlightColor: Colors.grey.shade100,
      period: const Duration(milliseconds: 1000),
      enabled: true,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: const [
            ContentPlaceholder(
              lineType: ContentLineType.threeLines,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildUnit(String unitName, String itemName, String value, String uom) {
    return Container(
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
            color: colorByUOM(uom),
          ),
        ),
      ),
      padding: const EdgeInsets.only(left: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            unitName,
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              color: DesignColors.fore(),
              fontSize: 16,
            ),
          ),
          Text(
            "$itemName = $value $uom",
            style: TextStyle(
              overflow: TextOverflow.ellipsis,
              color: colorByUOM(uom),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget loadingItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade800,
      highlightColor: Colors.grey.shade400,
      period: const Duration(milliseconds: 1000),
      enabled: true,
      child: buildUnit("Unit Name", "Item Name", "Value", "UOM"),
    );
  }

  Widget buildUnits(BuildContext context) {
    List<Widget> widgets = [];
    List<UnitStateAllItemResponse> itemsToDisplay = [];

    if (loaded) {
      itemsToDisplay = items;
    } else {
      for (int i = 0; i < 6; i++) {
        widgets.add(loadingItem());
      }
    }

    for (var unit in itemsToDisplay) {
      String itemShortName = unit.mainItem.replaceAll("${unit.unitId}/", "");

      widgets
          .add(buildUnit(unit.unitName, itemShortName, unit.value, unit.uom));
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
          widget.buildH1(context, "NODE '$nodeName'", true, false, true),
          buildCommonInfo(context),
          widget.buildH1(context, "UNITS", false, false, false),
          buildUnits(context),
        ],
      ),
    );
  }
}
