class DataItemSetSourceRequest {
  String itemName;
  String source;
  DataItemSetSourceRequest(this.itemName, this.source);
  Map<String, dynamic> toJson() => {
    'item_name': itemName,
    'source': source,
  };
}

class DataItemSetSourceResponse {
  DataItemSetSourceResponse();

  factory DataItemSetSourceResponse.fromJson(Map<String, dynamic> json) {
    return DataItemSetSourceResponse();
  }
}
