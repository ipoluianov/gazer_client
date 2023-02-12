import 'package:gazer_client/runlang/context.dart';

import 'block.dart';
import 'library.dart';
import 'line.dart';

typedef FunctionUniFunc = List<dynamic> Function(List<dynamic>);

class Program {
  String currentCode = "";
  int currentLine = 0;
  Map<String, dynamic> global = {};
  List<Line> lines = [];
  Context context = Context(0);
  Map<String, int> functions = {};
  List<Context> stack = [];
  Map<String, FunctionUniFunc> parentFunctions = {};
  bool debugMode = false;

  Program() {
    debugMode = false;
    context = Context(-1);
    parentFunctions["run.add"] = libAdd;
    parentFunctions["run.sub"] = libSub;
    parentFunctions["run.mul"] = libMul;
    parentFunctions["run.div"] = libDiv;

    parentFunctions["run.print"] = libPrint;

    parentFunctions["run.string"] = libString;
    parentFunctions["run.int64"] = libInt64;
    parentFunctions["run.double"] = libDouble;

    parentFunctions["run.abs"] = libAbs;
  }

  void addFunction(String name, FunctionUniFunc f) {
    parentFunctions[name] = f;
  }

  void debug(List<dynamic> args) {
    //print(args);
  }

  void addLine(String line) {
    Line l = Line();
    String currentLexem = "";
    for (int i = 0; i < line.length; i++) {
      if (line[i] == " " ||
          line[i] == "\t" ||
          line[i] == "(" ||
          line[i] == ")" ||
          line[i] == ",") {
        if (currentLexem.isNotEmpty) {
          l.lexems.add(currentLexem);
          currentLexem = "";
        }
        continue;
      }
      currentLexem += line[i];
    }
    if (currentLexem.isNotEmpty) {
      l.lexems.add(currentLexem);
    }
    if (l.lexems.isNotEmpty) {
      if (l.lexems[0] == "fn") {
        functions[l.lexems[1]] = lines.length;
      }
      lines.add(l);
    }
  }

  void clear() {
    lines = [];
    context = Context(-1);
    stack = [];
    currentLine = 0;
    functions = {};
  }

  bool compile(String code) {
    if (code == currentCode) {
      return false;
    }
    clear();
    currentCode = code;
    String currentLine = "";
    for (int i = 0; i < code.length; i++) {
      var ch = code[i];
      if (ch == '\r' || ch == '\n') {
        addLine(currentLine);
        currentLine = "";
        continue;
      }
      currentLine += code[i];
    }
    if (currentLine.isNotEmpty) {
      addLine(currentLine);
      currentLine = "";
    }
    return true;
  }

  List<dynamic> runFn(String functionName, List<dynamic> args) {
    List<dynamic> result = [];
    if (functions.containsKey(functionName)) {
      currentLine = lines.length;
      List<String> argsValues = [];
      for (var v in args) {
        if (v is String) {
          argsValues.add("\"" + v.toString() + "\"");
        } else {
          argsValues.add(v.toString());
        }
      }
      List<String> callBody = [];
      callBody.add(functionName);
      callBody.addAll(argsValues);
      fnCall([], callBody);
      runInternal();
      return context.lastCallResult;
    }
    return result;
  }

  void run() {
    currentLine = 0;
    runInternal();
  }

  void runInternal() {
    while (currentLine >= 0 && currentLine < lines.length) {
      execLine();
    }
    return;
  }

  void execLine() {
    if (lines[currentLine].lexems.isEmpty) {
      currentLine++;
      return;
    }
    var l0 = lines[currentLine].lexems[0];
    debug(["execLine", currentLine, lines[currentLine].lexems]);
    if (l0 == "return") {
      fnReturn();
      return;
    }
    if (l0 == "fn") {
      fnFn();
      return;
    }
    if (l0 == "if") {
      fnIf();
      return;
    }
    if (l0 == "while") {
      fnWhile();
      return;
    }
    if (l0 == "break") {
      fnBreak();
      return;
    }
    if (l0 == "}") {
      fnEnd(true);
      return;
    }
    if (l0 == "dump") {
      fnDump();
      return;
    }

    fnSet();
  }

  void fnCall(List<String> resultPlaces, List<String> funcCallBody) {
    var functionName = funcCallBody[0];
    bool internalExists = functions.containsKey(functionName);
    bool externalExists = parentFunctions.containsKey(functionName);

    if (!internalExists && !externalExists) {
      throw "unknown function " + functionName;
    }

    if (internalExists) {
      var functionLineIndex = functions[functionName]!;
      var ls = lines[functionLineIndex].lexems;
      var functionLineParameters = ls.sublist(2, ls.length - 1);
      var parameters = parseParameters(funcCallBody.sublist(1));
      var ctx = Context(currentLine + 1);
      ctx.functionName = functionName;

      for (int i = 0; i < functionLineParameters.length; i++) {
        ctx.vars[functionLineParameters[i]] = null;
        if (i < parameters.length) {
          ctx.vars[functionLineParameters[i]] = parameters[i];
        }
      }
      stack.add(context);
      context = ctx;
      currentLine = functionLineIndex + 1;
      var block = Block("fn", -1, "internal:" + functionName);
      ctx.resultPlaces = resultPlaces;
      context.stackIfWhile.add(block);
    } else {
      if (externalExists) {
        var parameters = parseParameters(funcCallBody.sublist(1));
        var extFunction = parentFunctions[functionName];
        var resultValues = extFunction!(parameters);
        for (int i = 0; i < resultPlaces.length; i++) {
          if (i < resultValues.length) {
            set(resultPlaces[i], resultValues[i]);
          }
        }
        currentLine++;
      }
    }
  }

  List<dynamic> parseParameters(List<String> parts) {
    List<dynamic> parameters = [];
    for (int i = 0; i < parts.length; i++) {
      var v = get(parts[i]);
      parameters.add(v);
    }
    return parameters;
  }

  void fnReturn() {
    List<dynamic> results = [];
    var ls = lines[currentLine].lexems;
    for (int i = 1; i < ls.length; i++) {
      var v = get(ls[i]);
      results.add(v);
    }
    exitFromFunction(results);
  }

  void exitFromFunction(List<dynamic> results) {
    currentLine = context.returnToLine;
    var contextOfFunction = context;
    context = stack[stack.length - 1];
    stack = stack.sublist(0, stack.length - 1);
    for (int i = 0; i < contextOfFunction.resultPlaces.length; i++) {
      if (i < results.length) {
        set(contextOfFunction.resultPlaces[i], results[i]);
      }
    }
    context.lastCallResult = results;
  }

  void skipBlock() {
    int opened = 1;
    currentLine++;
    while (currentLine < lines.length) {
      var ls = lines[currentLine].lexems;
      for (int i = 0; i < ls.length; i++) {
        if (ls[i] == "{") {
          opened++;
        }
        if (opened == 0) {
          break;
        }
        if (ls[i] == "}") {
          opened--;
        }
      }
      if (opened == 0) {
        break;
      }
      currentLine++;
    }
    currentLine++;
  }

  void fnFn() {
    skipBlock();
  }

  void fnIf() {
    var line = lines[currentLine].lexems.sublist(1);
    context.stackIfWhile.add(Block("if", currentLine + 1, lines.toString()));
    if (line[line.length - 1] == "{") {
      line = line.sublist(0, line.length - 1);
    }
    var cond = context.calcCondition(line);
    if (cond) {
      currentLine++;
      return;
    }
    skipBlock();
    currentLine--;
    fnEnd(false);
  }

  void fnWhile() {
    var firstExecution = true;
    if (context.stackIfWhile.isNotEmpty) {
      var last = context.stackIfWhile[context.stackIfWhile.length - 1];
      if (last.beginIndex == currentLine) {
        firstExecution = false;
      }
    }
    var line = lines[currentLine].lexems;
    if (firstExecution) {
      context.stackIfWhile.add(Block("while", currentLine, line.toString()));
    }

    if (line[line.length - 1] == "{") {
      line = line.sublist(0, line.length - 1);
    }

    var cond = context.calcCondition(line);
    if (!cond) {
      fnBreak();
      return;
    }
    currentLine++;
  }

  void fnBreak() {
    while (context.stackIfWhile.isNotEmpty) {
      var last = context.stackIfWhile[context.stackIfWhile.length - 1];
      context.stackIfWhile =
          context.stackIfWhile.sublist(0, context.stackIfWhile.length - 1);
      if (last.tp == "while") {
        currentLine = last.beginIndex;
        skipBlock();
        break;
      }
    }
  }

  void fnDump() {
    print("-------------");
    print("DUMP:");
    for (var key in context.vars.keys) {
      print("$key = ${context.vars[key]}");
    }
    currentLine++;
    print("-------------");
  }

  void fnEnd(bool skipElse) {
    if (context.stackIfWhile.isEmpty) {
      throw "no more instructions";
    }
    var el = context.stackIfWhile[context.stackIfWhile.length - 1];
    if (el.tp == "while") {
      currentLine = el.beginIndex;
      return;
    }
    if (el.tp == "fn") {
      context.stackIfWhile =
          context.stackIfWhile.sublist(0, context.stackIfWhile.length - 1);
      exitFromFunction([]);
      return;
    }
    if (el.tp == "if") {
      bool removeIfStatement = true;
      var ls = lines[currentLine].lexems;
      if (ls.length == 3 && ls[0] == "}" && ls[1] == "else" && ls[2] == "{") {
        if (skipElse) {
          skipBlock();
        } else {
          removeIfStatement = false;
          currentLine++; // in else
        }
      } else {
        currentLine++;
      }
      if (removeIfStatement) {
        context.stackIfWhile.removeLast();
      }
    }
  }

  bool isFunction(String name) {
    return functions.containsKey(name) || parentFunctions.containsKey(name);
  }

  void fnSet() {
    var ls = lines[currentLine].lexems;
    List<String> leftPart = [];
    for (int i = 0; i < ls.length; i++) {
      if (ls[i] == "=") {
        break;
      }
      leftPart.add(ls[i]);
    }
    List<String> rightPart = [];
    if (leftPart.length == ls.length) {
      leftPart = [];
      rightPart = ls;
    } else {
      rightPart = ls.sublist(leftPart.length + 1);
    }

    if (rightPart.isEmpty) {
      throw "no right part on operation";
    }

    if (leftPart.length == 1) {
      if (!isFunction(rightPart[0])) {
        if (rightPart.length == 3) {
          List<String> parameters = ["", "", ""];
          parameters[1] = rightPart[0];
          parameters[2] = rightPart[2];
          switch (rightPart[1]) {
            case "+":
              parameters[0] = "run.add";
              break;
            case "-":
              parameters[0] = "run.sub";
              break;
            case "*":
              parameters[0] = "run.mul";
              break;
            case "/":
              parameters[0] = "run.div";
              break;
          }
          if (parameters[0].isNotEmpty) {
            fnCall(leftPart, parameters);
            return;
          } else {
            throw "wrong operation";
          }
        }

        if (rightPart.length == 1) {
          var v = get(rightPart[0]);
          set(leftPart[0], v);
          currentLine++;
          return;
        }
      }
    }

    fnCall(leftPart, rightPart);
  }

  void set(String name, dynamic value) {
    if (name.startsWith("#")) {
      global[name] = value;
    }
    context.set(name, value);
  }

  dynamic get(String name) {
    if (name.startsWith("#")) {
      if (global.containsKey(name)) {
        return global[name];
      }
      return null;
    }

    return context.get(name);
  }
}
