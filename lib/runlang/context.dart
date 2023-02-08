import 'package:gazer_client/runlang/utils.dart';

import 'block.dart';

class Context {
  int returnToLine = 0;
  String functionName = "";
  Map<String, dynamic> vars = {};
  List<Block> stackIfWhile = [];
  List<String> resultPlaces = [];
  List<dynamic> lastCallResult = [];

  Context(this.returnToLine);

  dynamic get(String name) {
    if (name.isEmpty) {
      throw "empty lexem";
    }
    dynamic constValue = parseConstant(name);
    if (constValue != null) {
      return constValue;
    }
    if (vars.containsKey(name)) {
      return vars[name];
    }
    return null;
  }

  void set(String name, dynamic value) {
    vars[name] = value;
  }

  bool calcCondition(List<String> cond) {
    if (cond.length != 3) {
      throw "wrong condition";
    }

    var p1 = cond[0];
    var op = cond[1];
    var p2 = cond[2];
    var pv1 = get(p1);
    var pv2 = get(p2);
    if (pv1 is int && pv2 is int) {
      switch (op) {
        case "<":
          return pv1 < pv2;
        case "<=":
          return pv1 <= pv2;
        case "==":
          return pv1 == pv2;
        case ">=":
          return pv1 >= pv2;
        case ">":
          return pv1 > pv2;
      }
    }
    if (pv1 is double && pv2 is double) {
      switch (op) {
        case "<":
          return pv1 < pv2;
        case "<=":
          return pv1 <= pv2;
        case "==":
          return pv1 == pv2;
        case ">=":
          return pv1 >= pv2;
        case ">":
          return pv1 > pv2;
      }
    }

    throw "wrong condition";
  }
}
