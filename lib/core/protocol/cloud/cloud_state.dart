class CloudStateRequest {
  CloudStateRequest();
  Map<String, dynamic> toJson() => {};
}

class CloudStateItemResponse {
  String name;
  bool allow;
  int value;
  CloudStateItemResponse(
      this.name,
      this.allow,
      this.value,
      );

  factory CloudStateItemResponse.fromJson(Map<String, dynamic> json) {
    return CloudStateItemResponse(
      json['name'],
      json['allow'],
      json['value'],
    );
  }
}

class CloudStateResponse {
  String userName;
  String nodeId;
  bool connected;
  bool loggedIn;
  String loginStatus;
  String connectionStatus;
  String iAmStatus;
  String currentRepeater;
  String sessionKey;
  List<CloudStateItemResponse> counters;
  CloudStateResponse(
      this.userName,
      this.nodeId,
      this.connected,
      this.loggedIn,
      this.loginStatus,
      this.connectionStatus,
      this.iAmStatus,
      this.currentRepeater,
      this.sessionKey,
      this.counters,
      );

  factory CloudStateResponse.fromJson(Map<String, dynamic> json) {
    return CloudStateResponse(
      json['user_name'],
      json['node_id'],
      json['connected'],
      json['logged_in'],
      json['login_status'],
      json['connection_status'],
      json['i_am_status'],
      json['current_repeater'],
      json['session_key'],
      List<CloudStateItemResponse>.from(json["Counters"].map<CloudStateItemResponse>((model) => CloudStateItemResponse.fromJson(model))),
    );
  }
}

/*
	UserName         string `json:"user_name"`
	NodeId           string `json:"node_id"`
	Connected        bool   `json:"connected"`
	LoggedIn         bool   `json:"logged_in"`
	LoginStatus      string `json:"login_status"`
	ConnectionStatus string `json:"connection_status"`
	IAmStatus        string `json:"i_am_status"`
	CurrentRepeater  string `json:"current_repeater"`
	SessionKey       string `json:"session_key"`
* */
