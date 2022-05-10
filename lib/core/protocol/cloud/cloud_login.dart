class CloudLoginRequest {
  String userName;
  String password;
  CloudLoginRequest(this.userName, this.password);
  Map<String, dynamic> toJson() => {
    'user_name': userName,
    'password': password,
  };
}

class CloudLoginResponse {
  CloudLoginResponse();
  factory CloudLoginResponse.fromJson(Map<String, dynamic> json) {
    return CloudLoginResponse();
  }
}
