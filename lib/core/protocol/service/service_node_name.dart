class ServiceNodeNameRequest {
  ServiceNodeNameRequest();
  Map<String, dynamic> toJson() => {
  };
}

class ServiceNodeNameResponse {
  String name;
  ServiceNodeNameResponse(this.name);

  factory ServiceNodeNameResponse.fromJson(Map<String, dynamic> json) {
    return ServiceNodeNameResponse(json['name']);
  }
}
