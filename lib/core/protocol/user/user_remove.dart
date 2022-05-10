class UserRemoveRequest {
  String userName;
  UserRemoveRequest(this.userName);
  Map<String, dynamic> toJson() => {
    'user_name': userName,
  };
}

class UserRemoveResponse {
  UserRemoveResponse();

  factory UserRemoveResponse.fromJson(Map<String, dynamic> json) {
    return UserRemoveResponse();
  }
}
