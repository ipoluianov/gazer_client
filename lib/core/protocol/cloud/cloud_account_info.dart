class CloudAccountInfoRequest {
  CloudAccountInfoRequest();
  Map<String, dynamic> toJson() => {
  };
}

class CloudAccountInfoResponse {
  String email;
  int maxNodesCount;
  CloudAccountInfoResponse(this.email, this.maxNodesCount);

  factory CloudAccountInfoResponse.fromJson(Map<String, dynamic> json) {
    return CloudAccountInfoResponse(json['email'], json['max_nodes_count']);
  }
}
