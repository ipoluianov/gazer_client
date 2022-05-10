class UnitTypeCategoriesRequest {
  UnitTypeCategoriesRequest();
  Map<String, dynamic> toJson() => {
      };
}

class UnitTypeCategoriesItemResponse {
  String name;
  String displayName;
  String image;
  UnitTypeCategoriesItemResponse(this.name, this.displayName, this.image);
  factory UnitTypeCategoriesItemResponse.fromJson(Map<String, dynamic> json) {
    return UnitTypeCategoriesItemResponse(
      json['name'],
      json['display_name'],
      json['image'],
    );
  }
}

class UnitTypeCategoriesResponse {
  List<UnitTypeCategoriesItemResponse> items;
  UnitTypeCategoriesResponse(this.items);

  factory UnitTypeCategoriesResponse.fromJson(Map<String, dynamic> json) {
    return UnitTypeCategoriesResponse(
      List<UnitTypeCategoriesItemResponse>.from(
        json['items']
            .map((model) => UnitTypeCategoriesItemResponse.fromJson(model)),
      ),
    );
  }
}
