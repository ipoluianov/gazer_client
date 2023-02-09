import 'dart:html';
import 'dart:js_util';

import 'package:gazer_client/runlang/context.dart';

import 'library.dart';
import 'line.dart';

typedef FunctionUniFunc = List<dynamic> Function(List<dynamic>);

class Program {
  int currentLine = 0;
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
  }

  void addFunction(String name, FunctionUniFunc f) {
    parentFunctions[name] = f;
  }

  void debug(List<dynamic> args) {
    print(args);
  }

  void addLine(String line) {
    Line l = Line();
    String currentLexem = "";
    for (int i = 0; i < line.length; i++) {
      if (line[i] == " " ||
          line[i] == "(" ||
          line[i] == ")" ||
          line[i] == ",") {
        if (currentLexem.isNotEmpty) {
          l.lexems.add(currentLexem);
        }
        continue;
      }
      currentLexem += line[i];
    }
    if (currentLexem.isNotEmpty) {
      l.lexems.add(currentLexem);
    }
    if (l.lexems.isNotEmpty) {
      lines.add(l);
    }
  }

  void compile(String code) {
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
    }
  }

  List<dynamic> runFn(String functionName, List<dynamic> args) {
    List<dynamic> result = [];
    if (functions.containsKey(functionName)) {
      currentLine = functions[functionName]!;
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
      fnEnd();
      return;
    }
    if (l0 == "dump") {
      fnDump();
      return;
    }

    fnSet();
  }

  void fnCall(List<String> resulrPlaces, List<String> funcCallBody) {
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
    } else {
      if (externalExists) {}
    }
  }
}
