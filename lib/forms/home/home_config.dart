class HomeConfigItemProp {
  String name = "";
  String value = "";
  HomeConfigItemProp(this.name, this.value);
  factory HomeConfigItemProp.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey("name")) {
      return HomeConfigItemProp("", "");
    }
    if (!json.containsKey("value")) {
      return HomeConfigItemProp("", "");
    }

    return HomeConfigItemProp(json["name"], json["value"]);
  }
  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
      };
}

class HomeConfigItem {
  List<HomeConfigItemProp> props = [];
  HomeConfigItem(this.props);
  factory HomeConfigItem.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey("props")) {
      return HomeConfigItem([]);
    }
    var its = List<HomeConfigItemProp>.from(
        json["props"].map((model) => HomeConfigItemProp.fromJson(model)));
    return HomeConfigItem(its);
  }
  Map<String, dynamic> toJson() => {
        'props': props.map((e) => e.toJson()).toList(),
      };

  String get(String name) {
    for (var p in props) {
      if (p.name == name) {
        return p.value;
      }
    }
    return "";
  }
}

class HomeConfig {
  List<HomeConfigItem> items = [];
  HomeConfig(this.items);

  factory HomeConfig.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey("items")) {
      return HomeConfig([]);
    }
    var its = List<HomeConfigItem>.from(
        json["items"].map((model) => HomeConfigItem.fromJson(model)));

    return HomeConfig(its);
  }
  Map<String, dynamic> toJson() =>
      {"items": items.map((e) => e.toJson()).toList()};
}
