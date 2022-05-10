class SessionRemoveRequest {
  String sessionToken;
  SessionRemoveRequest(this.sessionToken);
  Map<String, dynamic> toJson() => {
    'session_token': sessionToken,
  };
}

class SessionRemoveResponse {
  SessionRemoveResponse();

  factory SessionRemoveResponse.fromJson(Map<String, dynamic> json) {
    return SessionRemoveResponse();
  }
}
