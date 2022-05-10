class UserListRequest {
  UserListRequest();
  Map<String, dynamic> toJson() => {
  };
}

class UserListResponse {
  List<String> items;
  UserListResponse(this.items);

  factory UserListResponse.fromJson(Map<String, dynamic> json) {
    return UserListResponse(List<String>.from(json["items"].toList()));
  }
}
