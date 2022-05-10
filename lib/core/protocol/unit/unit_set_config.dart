class UnitSetConfigRequest {
  String unitId;
  String unitName;
  String config;
  UnitSetConfigRequest(this.unitId, this.unitName, this.config);
  Map<String, dynamic> toJson() => {
    'id': unitId,
    'name': unitName,
    'config': config,
  };
}

class UnitSetConfigResponse {
  UnitSetConfigResponse();

  factory UnitSetConfigResponse.fromJson(Map<String, dynamic> json) {
    return UnitSetConfigResponse();
  }
}
