class UnitPropGetRequest {
  String unitId;
  UnitPropGetRequest(this.unitId);
  Map<String, dynamic> toJson() => {
    'unit_id': unitId,
  };
}

class UnitPropGetItemResponse {
  String propName;
  String propValue;
  UnitPropGetItemResponse(this.propName, this.propValue);

  factory UnitPropGetItemResponse.fromJson(Map<String, dynamic> json) {
    return UnitPropGetItemResponse(
      json['prop_name'],
      json['prop_value'],
    );
  }
}

class UnitPropGetResponse {
  List<UnitPropGetItemResponse> props;
  UnitPropGetResponse(this.props);

  String getProp(String name) {
    String result = "";
    for (var prop in props) {
      if (prop.propName == name) {
        result = prop.propValue;
        break;
      }
    }
    return result;
  }

  factory UnitPropGetResponse.fromJson(Map<String, dynamic> json) {
    return UnitPropGetResponse(
      List<UnitPropGetItemResponse>.from(
        json['props'].map((model) => UnitPropGetItemResponse.fromJson(model)),
      ),
    );
  }
}
