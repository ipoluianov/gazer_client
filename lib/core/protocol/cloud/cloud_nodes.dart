class CloudNodesRequest {
  CloudNodesRequest();
  Map<String, dynamic> toJson() => {};
}

class CloudNodesResponseItem {
  String nodeId;
  String name;
  CloudNodesResponseItem(this.nodeId, this.name);

  factory CloudNodesResponseItem.fromJson(Map<String, dynamic> json) {
    return CloudNodesResponseItem(json['node_id'], json['name']);
  }
}

class CloudNodesResponse {
  List<CloudNodesResponseItem> items;

  CloudNodesResponse(this.items);

  factory CloudNodesResponse.fromJson(Map<String, dynamic> json) {
    return CloudNodesResponse(
      List<CloudNodesResponseItem>.from(json['items'].map(
              (model) => CloudNodesResponseItem.fromJson(json['nodes']))),
    );
  }
}
