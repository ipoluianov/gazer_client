import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/repository.dart';

import '../../core/gazer_local_client.dart';
import '../../core/protocol/unit/unit_state.dart';
import 'home_item.dart';

class HomeItemUnitItems extends HomeItem {
  const HomeItemUnitItems(super.arg, super.config, {super.key});

  @override
  State<StatefulWidget> createState() {
    return HomeItemUnitItemsState();
  }
}

class HomeItemUnitItemsState extends State<HomeItemUnitItems> {
  late Timer timerUpdate_;

  @override
  void initState() {
    super.initState();
    updateUnitInfo();
    timerUpdate_ = Timer.periodic(const Duration(seconds: 1), (timer) {
      updateItems();
    });
  }

  @override
  void dispose() {
    timerUpdate_.cancel();
    super.dispose();
  }

  bool unitInfoLoading = false;
  bool unitInfoLoaded = false;

  String unitName = "";
  String mainItem = "";

  void updateUnitInfo() {
    if (unitInfoLoading || unitInfoLoaded) return;
    unitInfoLoading = true;

    unitName = widget.config;
    Repository()
        .client(widget.arg.connection)
        .unitPropGet(widget.config)
        .then((value) {
      setState(() {
        mainItem = value.getProp("main_item");
      });
      unitInfoLoaded = true;
      unitInfoLoading = false;
      updateItems();
    }).catchError((err) {
      unitInfoLoaded = false;
      unitInfoLoading = false;
    });
  }

  bool unitStateLoading = false;
  bool unitStateLoaded = false;

  late UnitStateResponse unitState;
  List<UnitStateValuesResponseItem> filteredItems = [];

  void updateItems() {
    if (unitStateLoading) return;
    if (!unitInfoLoaded) {
      return;
    }
    unitStateLoading = true;

    GazerLocalClient client = Repository().client(widget.arg.connection);
    client.unitsState(widget.config).then((value) {
      if (mounted) {
        setState(() {
          unitName = value.unitName;
          unitState = value;
          unitStateLoaded = true;
          filteredItems = unitState.items.where((i) {
            return !i.name.contains('/.service/');
          }).toList();
        });
        unitStateLoading = false;
      }
    }).catchError((err) {
      unitStateLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (unitStateLoading || !unitStateLoaded) return Text("loading ...");
    return Column(
      //crossAxisAlignment: CrossAxisAlignment.start,
      children: filteredItems.map((e) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(e.name),
            Row(
              children: [
                Text(e.value.value),
                Text(" ${e.value.uom}"),
              ],
            ),
          ],
        );
      }).toList(),
    );
  }
}
