class DataItemWriteRequest {
  String itemName;
  String value;
  DataItemWriteRequest(this.itemName, this.value);
  Map<String, dynamic> toJson() => {
    'item_name': itemName,
    'value': value,
  };
}

class DataItemWriteResponse {
  DataItemWriteResponse();

  factory DataItemWriteResponse.fromJson(Map<String, dynamic> json) {
    return DataItemWriteResponse();
  }
}
