class CloudUpdateNodeRequest {
  String nodeId;
  String name;
  CloudUpdateNodeRequest(this.nodeId, this.name);
  Map<String, dynamic> toJson() => {
    'node_id': nodeId,
    'name': name,
  };
}

class CloudUpdateNodeResponse {
  CloudUpdateNodeResponse();
  factory CloudUpdateNodeResponse.fromJson(Map<String, dynamic> json) {
    return CloudUpdateNodeResponse();
  }
}
