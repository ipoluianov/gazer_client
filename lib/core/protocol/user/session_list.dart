class SessionListRequest {
  String userName;
  SessionListRequest(this.userName);
  Map<String, dynamic> toJson() => {
        'user_name': userName,
      };
}

class SessionListItemResponse {
  String sessionToken;
  String userName;
  int sessionOpenTime;
  SessionListItemResponse(this.sessionToken, this.userName, this.sessionOpenTime);

  factory SessionListItemResponse.fromJson(Map<String, dynamic> json) {
    return SessionListItemResponse(json['session_token'], json['user_name'], json['session_open_time']);
  }
}

class SessionListResponse {
  List<SessionListItemResponse> items;
  SessionListResponse(this.items);

  factory SessionListResponse.fromJson(Map<String, dynamic> json) {
    return SessionListResponse(
      List<SessionListItemResponse>.from(
          json["items"] != null ? json["items"].map(
          (model) => SessionListItemResponse.fromJson(model),
        ) : [],
      ),
    );
  }
}
