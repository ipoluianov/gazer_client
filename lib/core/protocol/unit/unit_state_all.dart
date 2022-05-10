class UnitStateAllRequest {
  UnitStateAllRequest();
  Map<String, dynamic> toJson() => {
      };
}

class UnitStateAllItemResponse {
  String unitId;
  String unitName;
  String type;
  String typeName;
  String status;
  String mainItem;
  String value;
  String uom;

  UnitStateAllItemResponse(this.unitId, this.unitName, this.type, this.typeName,
      this.status, this.mainItem, this.value, this.uom);

  factory UnitStateAllItemResponse.fromJson(Map<String, dynamic> json) {
    return UnitStateAllItemResponse(
        json['id'],
        json['name'],
        json['type'],
        json['type_name'],
        json['status'],
        json['main_item'],
        json['value'],
        json['uom']);
  }
}

class UnitStateAllResponse {
  List<UnitStateAllItemResponse> items;
  UnitStateAllResponse(this.items);

  factory UnitStateAllResponse.fromJson(Map<String, dynamic> json) {
    return UnitStateAllResponse(List<UnitStateAllItemResponse>.from(
      json['items'].map((model) => UnitStateAllItemResponse.fromJson(model)),
    ));
  }
}

