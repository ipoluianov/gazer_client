class ServiceInfoRequest {
  ServiceInfoRequest();
  Map<String, dynamic> toJson() => {};
}

class ServiceInfoResponse {
  String nodeName;
  String version;
  String buildTime;
  ServiceInfoResponse(this.nodeName, this.version, this.buildTime);

  factory ServiceInfoResponse.fromJson(Map<String, dynamic> json) {
    return ServiceInfoResponse(
      json['node_name'],
      json['version'],
      json['build_time'],
      //json['functions'].cast<String>(),
    );
  }
}
