class DataItemPropGetRequest {
  String itemName;
  DataItemPropGetRequest(this.itemName);
  Map<String, dynamic> toJson() => {
        'item_name': itemName,
      };
}

class DataItemPropGetItemResponse {
  String propName;
  String propValue;
  DataItemPropGetItemResponse(this.propName, this.propValue);

  factory DataItemPropGetItemResponse.fromJson(Map<String, dynamic> json) {
    return DataItemPropGetItemResponse(
      json['prop_name'],
      json['prop_value'],
    );
  }
}

class DataItemPropGetResponse {
  List<DataItemPropGetItemResponse> props;
  DataItemPropGetResponse(this.props);

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


  factory DataItemPropGetResponse.fromJson(Map<String, dynamic> json) {
    return DataItemPropGetResponse(
      List<DataItemPropGetItemResponse>.from(
        json['props'].map((model) => DataItemPropGetItemResponse.fromJson(model)),
      ),
    );
  }
}
