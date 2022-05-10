class CloudRegisteredNodesRequest {
  CloudRegisteredNodesRequest();
  Map<String, dynamic> toJson() => {};
}

class CloudRegisteredNodesItemResponse {
  String id;
  String name;
  String currentRepeater;
  CloudRegisteredNodesItemResponse(this.id, this.name, this.currentRepeater);

  factory CloudRegisteredNodesItemResponse.fromJson(Map<String, dynamic> json) {
    return CloudRegisteredNodesItemResponse(
        json['id'], json['name'], json['current_repeater']);
  }
}

class CloudRegisteredNodesResponse {
  List<CloudRegisteredNodesItemResponse> items;

  CloudRegisteredNodesResponse(this.items);

  factory CloudRegisteredNodesResponse.fromJson(Map<String, dynamic> json) {
    return CloudRegisteredNodesResponse(
      json['items'].map<CloudRegisteredNodesItemResponse>(
        (model) => CloudRegisteredNodesItemResponse.fromJson(model),
      ).toList(),
    );
  }
}
