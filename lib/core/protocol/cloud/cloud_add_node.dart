class CloudAddNodeRequest {
  String name;
  CloudAddNodeRequest(this.name);
  Map<String, dynamic> toJson() => {
    'name': name,
  };
}

class CloudAddNodeResponse {
  String nodeId;
  CloudAddNodeResponse(this.nodeId);

  factory CloudAddNodeResponse.fromJson(Map<String, dynamic> json) {
    return CloudAddNodeResponse(json['node_id']);
  }
}
