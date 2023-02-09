class Program {
  int currentLine = 0;
  List<Line> lines = [];
}

class Line {
  List<String> lexems = [];
}

class Context {
  int returnToLine = 0;
  String functionName = "";
  Map<String, dynamic> vars = {};
  List<Block> stackIfWhile = [];
  List<String> resultPlaces = [];
  List<dynamic> lastCallResult = [];

  Context() {
    
  }
}

class Block {
  String tp = "";
  String comment = "";
  int beginIndex = 0;
  Block(this.tp, this.beginIndex, this.comment);
}
