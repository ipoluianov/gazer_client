class CloudSetSettingsItemRequest {
  String function;
  bool allow;
  CloudSetSettingsItemRequest(this.function, this.allow);

  factory CloudSetSettingsItemRequest.fromJson(Map<String, dynamic> json) {
    return CloudSetSettingsItemRequest(json['function'], json['allow']);
  }
}

class CloudSetSettingsRequest {
  List<CloudSetSettingsItemRequest> items;
  CloudSetSettingsRequest(this.items);
  Map<String, dynamic> toJson() => {
    'items': items.toList(),
  };
}

class CloudSetSettingsResponse {
  CloudSetSettingsResponse();
  factory CloudSetSettingsResponse.fromJson(Map<String, dynamic> json) {
    return CloudSetSettingsResponse();
  }
}
