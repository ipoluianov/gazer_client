class ServiceInfoRequest {
  ServiceInfoRequest();
  Map<String, dynamic> toJson() => {};
}

class ServiceInfoResponse {
  String nodeName;
  String version;
  String buildTime;
  String guestKey;

  ServiceInfoResponse(
      this.nodeName, this.version, this.buildTime, this.guestKey);

  factory ServiceInfoResponse.fromJson(Map<String, dynamic> json) {
    return ServiceInfoResponse(
      json['node_name'],
      json['version'],
      json['build_time'],
      json.containsKey('guest_key') ? json['guest_key'] : "",
      //json['functions'].cast<String>(),
    );
  }
}
