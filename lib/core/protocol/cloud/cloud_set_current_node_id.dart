class CloudSetCurrentNodeIdRequest {
  String nodeId;
  CloudSetCurrentNodeIdRequest(this.nodeId);
  Map<String, dynamic> toJson() => {
    'node_id': nodeId,
  };
}

class CloudSetCurrentNodeIdResponse {
  CloudSetCurrentNodeIdResponse();
  factory CloudSetCurrentNodeIdResponse.fromJson(Map<String, dynamic> json) {
    return CloudSetCurrentNodeIdResponse();
  }
}
