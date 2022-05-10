class UnitTypeConfigMetaRequest {
  String unitType;
  UnitTypeConfigMetaRequest(this.unitType);
  Map<String, dynamic> toJson() => {
        'type': unitType,
      };
}

class UnitTypeConfigMetaResponse {
  String unitType;
  String unitTypeConfigMeta;

  UnitTypeConfigMetaResponse(this.unitType, this.unitTypeConfigMeta);

  factory UnitTypeConfigMetaResponse.fromJson(Map<String, dynamic> json) {
    return UnitTypeConfigMetaResponse(
      json['type'],
      json['config_meta'],
    );
  }
}
