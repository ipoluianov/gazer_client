class UnitStateRequest {
  String unitId;
  UnitStateRequest(this.unitId);
  Map<String, dynamic> toJson() => {
    'id': unitId,
  };
}

class UnitStateValuesResponseItemValue {
  late String value;
  late String uom;
  late int time;
  UnitStateValuesResponseItemValue(this.value, this.uom, this.time);
  factory UnitStateValuesResponseItemValue.fromJson(Map<String, dynamic> json) {
    return UnitStateValuesResponseItemValue(json['v'], json['u'], json['t']);
  }
}

class UnitStateValuesResponseItem {
  int id;
  String name;
  UnitStateValuesResponseItemValue value;

  UnitStateValuesResponseItem(this.id, this.name, this.value);

  factory UnitStateValuesResponseItem.makeDefault() {
    return UnitStateValuesResponseItem(0, "", UnitStateValuesResponseItemValue("", "", 0));
  }
}

class UnitStateResponse {
  String unitId;
  String unitName;
  String type;
  String typeName;
  String status;
  String mainItem;
  String value;
  String uom;
  final List<UnitStateValuesResponseItem> items;

  UnitStateResponse(this.unitId, this.unitName, this.type, this.typeName,
      this.status, this.mainItem, this.value, this.uom, this.items);

  factory UnitStateResponse.fromJson(Map<String, dynamic> json) {
    List<UnitStateValuesResponseItem> i =
    List<UnitStateValuesResponseItem>.from(
      json['items'].map(
            (model) =>
            UnitStateValuesResponseItem(
              model['id'],
              model['name'],
              UnitStateValuesResponseItemValue.fromJson(model['value']),
            ),
      ),
    );

    return UnitStateResponse(
        json['id'],
        json['name'],
        json['type'],
        json['type_name'],
        json['status'],
        json['main_item'],
        json['value'],
        json['uom'],
        i);
  }
}
