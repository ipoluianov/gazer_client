class ServiceSetNodeNameRequest {
  String name;
  ServiceSetNodeNameRequest(this.name);
  Map<String, dynamic> toJson() =>
      {
        'name': name,
      };
}

class ServiceSetNodeNameResponse {
  ServiceSetNodeNameResponse();

  factory ServiceSetNodeNameResponse.fromJson(Map<String, dynamic> json) {
    return ServiceSetNodeNameResponse();
  }
}
