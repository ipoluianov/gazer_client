class UnitPropSetItemRequest {
  String propName;
  String propValue;
  UnitPropSetItemRequest(this.propName, this.propValue);
  Map<String, dynamic> toJson() => {
    'prop_name': propName,
    'prop_value': propValue,
  };
}

class UnitPropSetRequest {
  String unitId;
  List<UnitPropSetItemRequest> props;
  UnitPropSetRequest(this.unitId, this.props);
  Map<String, dynamic> toJson() => {
    'unit_id': unitId,
    'props': props,
  };
}

class UnitPropSetResponse {
  UnitPropSetResponse();

  factory UnitPropSetResponse.fromJson(Map<String, dynamic> json) {
    return UnitPropSetResponse();
  }
}
