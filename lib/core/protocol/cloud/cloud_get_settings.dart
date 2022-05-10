class CloudGetSettingsRequest {
  CloudGetSettingsRequest();
  Map<String, dynamic> toJson() => {};
}

class CloudGetSettingsItemResponse {
  String function;
  bool allow;
  CloudGetSettingsItemResponse(this.function, this.allow);

  factory CloudGetSettingsItemResponse.fromJson(Map<String, dynamic> json) {
    return CloudGetSettingsItemResponse(json['function'], json['allow']);
  }
}

class CloudGetSettingsResponse {
  List<CloudGetSettingsItemResponse> items;

  CloudGetSettingsResponse(this.items);

  factory CloudGetSettingsResponse.fromJson(Map<String, dynamic> json) {
    return CloudGetSettingsResponse(
      List<CloudGetSettingsItemResponse>.from(json['items'].map(
          (model) => CloudGetSettingsItemResponse.fromJson(json['items']))),
    );
  }
}
