import 'dart:math';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/tools/hex_colors.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/maps/map_form/main/map_item.dart';

class TimeChartPropContainer extends IPropContainer {
  late Map<String, String> props;
  final Connection connection;
  String _id = "";

  TimeChartPropContainer(this.connection) {
    props = {};
  }

  @override
  String id() {
    return _id;
  }

  void generateAndSetNewId() {
    Random rnd = Random();
    var intRandom = rnd.nextInt(1000000);
    var dt = DateTime.now().microsecondsSinceEpoch;
    _id = dt.toString() + intRandom.toString();
  }

  @override
  void set(String name, String value) {
    props[name] = value;
  }

  @override
  String get(String name) {
    if (props.containsKey(name)) {
      if (props[name] == null) {
        return "";
      }
      return props[name]!;
    }
    return "";
  }

  @override
  Connection getConnection() {
    return connection;
  }

  @override
  List<MapItemPropPage> propList() {
    return [];
  }

  @override
  void setDouble(String name, double value) {
    props[name] = value.toString();
  }

  double getDouble(String name) {
    var val = get(name);
    if (val != "") {
      double? res = double.tryParse(val);
      if (res != null) {
        return res;
      }
      return 0;
    }
    return 0;
  }

  bool getBool(String name) {
    var val = get(name);
    return val == "1";
  }

  Color getColor(String name) {
    var val = get(name);
    if (val != "") {
      return colorFromHex(val);
    }
    return Colors.transparent;
  }

  void initDefaultProperties() {
    for (var itemPropPage in propList()) {
      for (var itemPropGroup in itemPropPage.groups) {
        for (var itemProp in itemPropGroup.props) {
          set(itemProp.name, itemProp.defaultValue);
        }
      }
    }
  }
}
