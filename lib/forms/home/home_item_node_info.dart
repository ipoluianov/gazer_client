import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/repository.dart';

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
      setState(() {});
    });
  }

  @override
  void dispose() {
    timerUpdate_.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var serviceInfo =
        Repository().client(widget.arg.connection).lastServiceInfo;
    String address = Repository().client(widget.arg.connection).address;
    if (serviceInfo != null) {
      int? dtNano = int.tryParse(serviceInfo.time);
      DateTime nodeTime = DateTime.fromMicrosecondsSinceEpoch(0);
      if (dtNano != null) {
        nodeTime = DateTime.fromMicrosecondsSinceEpoch(dtNano ~/ 1000);
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Name: ${serviceInfo.nodeName}"),
          Text("Version: ${serviceInfo.version}"),
          Text("Time: $nodeTime"),
          Text("Address: $address"),
        ],
      );
    }
    return const Text("-------------");
  }
}
