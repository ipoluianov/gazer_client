import 'package:gazer_client/runlang/utils.dart';

List<dynamic> libAdd(List<dynamic> args) {
  List<dynamic> result = [];
  if (args.length != 2) {
    throw "wrong arguments";
  }

  if (args[0] is int && args[1] is int) {
    result.add(args[0] + args[1]);
    return result;
  }

  if (args[0] is double && args[1] is double) {
    result.add(args[0] + args[1]);
    return result;
  }
  throw "wrong type";
}

List<dynamic> libSub(List<dynamic> args) {
  List<dynamic> result = [];
  if (args.length != 2) {
    throw "wrong arguments";
  }

  if (args[0] is int && args[1] is int) {
    result.add(args[0] - args[1]);
    return result;
  }

  if (args[0] is double && args[1] is double) {
    result.add(args[0] - args[1]);
    return result;
  }
  throw "wrong type";
}

List<dynamic> libMul(List<dynamic> args) {
  List<dynamic> result = [];
  if (args.length != 2) {
    throw "wrong arguments";
  }

  if (args[0] is int && args[1] is int) {
    result.add(args[0] * args[1]);
    return result;
  }

  if (args[0] is double && args[1] is double) {
    result.add(args[0] * args[1]);
    return result;
  }
  throw "wrong type";
}

List<dynamic> libDiv(List<dynamic> args) {
  List<dynamic> result = [];
  if (args.length != 2) {
    throw "wrong arguments";
  }

  if (args[0] is int && args[1] is int) {
    result.add(args[0] / args[1]);
    return result;
  }

  if (args[0] is double && args[1] is double) {
    result.add(args[0] / args[1]);
    return result;
  }
  throw "wrong type";
}

List<dynamic> libPrint(List<dynamic> args) {
  List<dynamic> result = [];
  print(args);
  return result;
}

List<dynamic> libInt64(List<dynamic> args) {
  List<dynamic> result = [];
  if (args.length != 1) {
    throw "wrong arguments";
  }

  dynamic c = int.parse([0].toString());
  if (c is int) {
    result.add(c);
    return result;
  }

  throw "cannot convert";
}

List<dynamic> libDouble(List<dynamic> args) {
  List<dynamic> result = [];
  if (args.length != 1) {
    throw "wrong arguments";
  }

  dynamic c = double.parse(args[0].toString());
  if (c is int) {
    result.add(c);
    return result;
  }

  throw "cannot convert";
}

List<dynamic> libString(List<dynamic> args) {
  List<dynamic> result = [];
  if (args.length != 1) {
    throw "wrong arguments";
  }

  dynamic c = args[0].toString();
  if (c is String) {
    result.add(c);
    return result;
  }

  throw "cannot convert";
}
