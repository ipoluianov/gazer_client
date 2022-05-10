
class DesignSettings {
  late Map<String, String> props = {};

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {};
    for (var propKey in props.keys) {
      result[propKey] = props[propKey];
    }
    return result;
  }

  String get(String name) {
    if (props.containsKey(name)) {
      if (props[name] != null) {
        return props[name]!;
      }
      return "";
    }
    return "";
  }

  void set(String name, String value) {
    props[name] = value;
  }

  static DesignSettings makeDefault() {
    return DesignSettings();
  }
}
