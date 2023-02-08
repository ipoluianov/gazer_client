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
}
