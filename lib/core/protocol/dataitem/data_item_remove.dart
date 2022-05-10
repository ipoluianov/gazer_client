class DataItemRemoveRequest {
  List<String> items;
  DataItemRemoveRequest(this.items);
  Map<String, dynamic> toJson() => {
    'items': items,
  };
}

class DataItemRemoveResponse {
  DataItemRemoveResponse();
  factory DataItemRemoveResponse.fromJson(Map<String, dynamic> json) {
    return DataItemRemoveResponse();
  }
}
