class UserSetPasswordRequest {
  String userName;
  String password;
  UserSetPasswordRequest(this.userName, this.password);
  Map<String, dynamic> toJson() => {
    'user_name': userName,
    'password': password,
  };
}

class UserSetPasswordResponse {
  UserSetPasswordResponse();

  factory UserSetPasswordResponse.fromJson(Map<String, dynamic> json) {
    return UserSetPasswordResponse();
  }
}
