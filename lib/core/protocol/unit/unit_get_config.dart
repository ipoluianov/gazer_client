class UnitGetConfigRequest {
  String unitId;
  UnitGetConfigRequest(this.unitId);
  Map<String, dynamic> toJson() => {
    'id': unitId,
  };
}

class UnitGetConfigResponse {
  String unitId;
  String unitName;
  String unitType;
  String unitConfig;
  String unitConfigMeta;

  UnitGetConfigResponse(this.unitId, this.unitName, this.unitType, this.unitConfig, this.unitConfigMeta);

  factory UnitGetConfigResponse.fromJson(Map<String, dynamic> json) {
    return UnitGetConfigResponse(json['id'], json['name'], json['type'], json['config'], json['config_meta']);
  }
}
