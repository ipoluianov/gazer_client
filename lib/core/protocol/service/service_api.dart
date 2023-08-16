class ServiceApiRequest {
  ServiceApiRequest();
  Map<String, dynamic> toJson() => {};
}

class ServiceApiResponse {
  String product;
  String version;
  String buildTime;
  //List<String> functions;
  ServiceApiResponse(this.product, this.version, this.buildTime);

  factory ServiceApiResponse.fromJson(Map<String, dynamic> json) {
    return ServiceApiResponse(
        json['product'], json['version'], json['build_time']
        //json['functions'].cast<String>(),
        );
  }
}
