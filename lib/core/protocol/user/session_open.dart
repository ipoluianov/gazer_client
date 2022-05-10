class SessionOpenRequest {
  String userName;
  String password;
  SessionOpenRequest(this.userName, this.password);
  Map<String, dynamic> toJson() => {
    'user_name': userName,
    'password': password,
  };
}

class SessionOpenResponse {
  String sessionToken;
  SessionOpenResponse(this.sessionToken);

  factory SessionOpenResponse.fromJson(Map<String, dynamic> json) {
    return SessionOpenResponse(json['session_token']);
  }
}
