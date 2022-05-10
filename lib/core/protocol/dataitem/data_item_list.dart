class DataItemListRequest {
  List<String> items;
  DataItemListRequest(this.items);
  Map<String, dynamic> toJson() => {
    'items': items,
  };
}

class DataItemInfo {
  int id;
  String name;
  String displayName;
  String value;
  int dt;
  String uom;
  DataItemInfo(this.id, this.name, this.displayName, this.value, this.dt, this.uom);

  factory DataItemInfo.fromJson(Map<String, dynamic> json) {
    return DataItemInfo(json['id'], json['name'], json['display_name'] ?? json['name'], json['v'], json['t'], json['u']);
  }

  factory DataItemInfo.makeDefault() {
    return DataItemInfo(0, "", "", "", 0, "");
  }
}

class DataItemListResponse {
  List<DataItemInfo> items;
  DataItemListResponse(this.items);

  factory DataItemListResponse.fromJson(Map<String, dynamic> json) {
    return DataItemListResponse(List<DataItemInfo>.from(json['items'].map((model) {
      return DataItemInfo.fromJson(model);
    }).toList()));
  }
}
