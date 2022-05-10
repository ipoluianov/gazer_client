dynamic defaultValue(String type, String defValueString, String format) {
  dynamic result;
  if (type == "num") {
    try {
      if (format == "0") {
        result = int.parse(defValueString);
      } else {
        result = double.parse(defValueString);
      }
    } catch (ex) {
      result = 0.0;
    }
  }
  if (type == "text" || type == "string") {
    result = defValueString;
  }
  if (type == "bool") {
    if (defValueString == "1" || defValueString == "true" || defValueString == "True") {
      result = true;
    } else {
      result = false;
    }
  }
  return result;
}
