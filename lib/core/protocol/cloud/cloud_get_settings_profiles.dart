class CloudGetSettingsProfilesRequest {
  CloudGetSettingsProfilesRequest();
  Map<String, dynamic> toJson() => {};
}

class CloudGetSettingsProfilesResponseItem {
  String code;
  String name;
  List<String> functions;
  CloudGetSettingsProfilesResponseItem(this.code, this.name, this.functions);

  factory CloudGetSettingsProfilesResponseItem.fromJson(Map<String, dynamic> json) {
    return CloudGetSettingsProfilesResponseItem(json['code'], json['name'], json['functions'].cast<String>());
  }
}

class CloudGetSettingsProfilesResponse {
  List<CloudGetSettingsProfilesResponseItem> items;

  CloudGetSettingsProfilesResponse(this.items);

  factory CloudGetSettingsProfilesResponse.fromJson(Map<String, dynamic> json) {
    return CloudGetSettingsProfilesResponse(
      List<CloudGetSettingsProfilesResponseItem>.from(json['items'].map(
              (model) => CloudGetSettingsProfilesResponseItem.fromJson(json['items']))),
    );
  }
}
