class CloudRemoveNodeRequest {
  String nodeId;
  CloudRemoveNodeRequest(this.nodeId);
  Map<String, dynamic> toJson() => {
    'node_id': nodeId,
  };
}

class CloudRemoveNodeResponse {
  CloudRemoveNodeResponse();
  factory CloudRemoveNodeResponse.fromJson(Map<String, dynamic> json) {
    return CloudRemoveNodeResponse();
  }
}
