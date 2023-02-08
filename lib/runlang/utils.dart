dynamic parseConstant(String value) {
  if (value[0] == '-' || isDigit(value, 0)) {
    if (value.contains(".")) {
      return double.parse(value);
    } else {
      if (value.length > 1 && value[0] == "0" && value[1] == "x") {
        return hexDecode(value.substring(2));
      } else {
        return int.parse(value);
      }
    }
  }

  if (value[0] == '"' && value[value.length - 1] == '"') {
    return value.substring(1, value.length - 1);
  }
  return null;
}

bool isDigit(String s, int idx) => (s.codeUnitAt(idx) ^ 0x30) <= 9;

int hexDecode(String str) {
  str = str.toUpperCase();
  int result = 0;
  int pos = 1;
  for (var code in str.codeUnits.reversed) {
    pos = pos << 4;
    int v = 0;
    if (code >= 0x30 && code <= 39) {
      v = code - 0x30;
    } else {
      if (code >= 0x41 && code <= 0x46) {
        v = code - 0x41 + 10;
      } else {
        throw "wrong hex string";
      }
    }
    result = result + v * pos;
  }
  return result;
}
