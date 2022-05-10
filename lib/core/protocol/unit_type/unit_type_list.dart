import 'dart:typed_data';

class UnitTypeListRequest {
  String category;// string `json:"category"`
  String filter;//   string `json:"filter"`
  int offset;//   int    `json:"offset"`
  int maxCount;// int    `json:"max_count"`

  UnitTypeListRequest(this.category, this.filter, this.offset, this.maxCount);
  Map<String, dynamic> toJson() => {
    'category': category,
    'filter': filter,
    'offset': offset,
    'max_count': maxCount,
  };
}

class UnitTypeListItemResponse {
  String type;//        string `json:"type"`
  String category;//    string `json:"category"`
  String displayName;// string `json:"display_name"`
  String help;//        string `json:"help"`
  String description;// string `json:"description"`
  String Image;//       []byte `json:"image"`

  UnitTypeListItemResponse(this.type, this.category, this.displayName, this.help, this.description, this.Image);

  factory UnitTypeListItemResponse.fromJson(Map<String, dynamic> json) {
    return UnitTypeListItemResponse(json['type'],json['category'],json['display_name'],json['help'],json['description'],json['image'],);
  }
}

class UnitTypeListResponse {
  int totalCount;//                        `json:"total_count"`
  int inFilterCount;//                        `json:"in_filter_count"`
  List<UnitTypeListItemResponse> types;//         []UnitTypeListResponseItem `json:"types"`

  UnitTypeListResponse(this.totalCount, this.inFilterCount, this.types);

  factory UnitTypeListResponse.fromJson(Map<String, dynamic> json) {
    return UnitTypeListResponse(json['total_count'],json['in_filter_count'], List<UnitTypeListItemResponse>.from(
      json['types']
          .map((model) => UnitTypeListItemResponse.fromJson(model)),
    ),);
  }
}
