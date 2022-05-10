class DataItemPropSetItemRequest {
  String propName;
  String propValue;
  DataItemPropSetItemRequest(this.propName, this.propValue);
  Map<String, dynamic> toJson() => {
    'prop_name': propName,
    'prop_value': propValue,
  };
}

class DataItemPropSetRequest {
  String itemName;
  List<DataItemPropSetItemRequest> props;
  DataItemPropSetRequest(this.itemName, this.props);
  Map<String, dynamic> toJson() => {
    'item_name': itemName,
    'props': props,
  };
}

class DataItemPropSetResponse {
  DataItemPropSetResponse();

  factory DataItemPropSetResponse.fromJson(Map<String, dynamic> json) {
    return DataItemPropSetResponse();
  }
}
