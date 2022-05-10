import 'dart:convert';

class UnitItemsValuesRequest {
  late String unitName;
  UnitItemsValuesRequest(this.unitName);

  Map<String, dynamic> toJson() => {
        'name': unitName,
      };
}

class UnitItemsValuesResponseItemValue {
  late String value;
  late String uom;
  late int time;
  UnitItemsValuesResponseItemValue(this.value, this.uom, this.time);
  factory UnitItemsValuesResponseItemValue.fromJson(Map<String, dynamic> json) {
    return UnitItemsValuesResponseItemValue(json['v'], json['u'], json['t']);
  }
}

class UnitItemsValuesResponseItem {
  int id;
  String name;
  UnitItemsValuesResponseItemValue value;

  UnitItemsValuesResponseItem(this.id, this.name, this.value);

  factory UnitItemsValuesResponseItem.makeDefault() {
    return UnitItemsValuesResponseItem(0, "", UnitItemsValuesResponseItemValue("", "", 0));
  }
}

class UnitItemsValuesResponse {
  final List<UnitItemsValuesResponseItem> items;

  UnitItemsValuesResponse({
    required this.items,
  });

  factory UnitItemsValuesResponse.fromJson(Map<String, dynamic> json, bool filtered) {
    List<UnitItemsValuesResponseItem> i =
        List<UnitItemsValuesResponseItem>.from(
          json['items'].map(
        (model) => UnitItemsValuesResponseItem(
          model['id'],
          model['name'],
          UnitItemsValuesResponseItemValue.fromJson(model['value']),
          //model['cloud_channels'].cast<String>(),
          //model['cloud_channels_names'].cast<String>(),
        ),
      ),
    );

    return UnitItemsValuesResponse(items: i);
  }
}
