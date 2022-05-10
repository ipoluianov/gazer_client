class UnitAddRequest {
  String unitType;
  String unitName;
  String config;
  UnitAddRequest(this.unitType, this.unitName, this.config);
  Map<String, dynamic> toJson() => {
    'type': unitType,
    'name': unitName,
    'config': config,
  };
}

class UnitAddResponse {
  String unitId;
  UnitAddResponse(this.unitId);

  factory UnitAddResponse.fromJson(Map<String, dynamic> json) {
    return UnitAddResponse(json['id']);
  }
}
