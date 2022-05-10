class UserAddRequest {
  String userName;
  String password;
  UserAddRequest(this.userName, this.password);
  Map<String, dynamic> toJson() => {
    'user_name': userName,
    'password': password,
  };
}

class UserAddResponse {
  UserAddResponse();

  factory UserAddResponse.fromJson(Map<String, dynamic> json) {
    return UserAddResponse();
  }
}
