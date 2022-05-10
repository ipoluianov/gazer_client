class UnitListRequest {
  UnitListRequest();
  Map<String, dynamic> toJson() => {
  };
}

class UnitListResponse {
  String id;
  String name;
  String type;
  String typeForDisplay;
  String config;
  bool enable;

  UnitListResponse(this.id, this.name, this.type, this.typeForDisplay, this.config, this.enable);

  factory UnitListResponse.fromJson(Map<String, dynamic> json) {
    return UnitListResponse(json['id'], json['name'], json['type'], json['type_for_display'], json['config'], json['enable']);
  }
}
