class ServiceLookupRequest {
  String entity;
  String parameters;
  ServiceLookupRequest(this.entity, this.parameters);
  Map<String, dynamic> toJson() => {
        'entity': entity,
        'parameters': parameters,
      };
}

class ServiceLookupColumnResponse {
  String name;
  String displayName;
  bool hidden;
  ServiceLookupColumnResponse(this.name, this.displayName, this.hidden);
  factory ServiceLookupColumnResponse.fromJson(Map<String, dynamic> json) {
    return ServiceLookupColumnResponse(json['name'], json['display_name'], json['hidden']);
  }
}

class ServiceLookupRowResponse {
  List<String> cells;
  ServiceLookupRowResponse(this.cells);
  factory ServiceLookupRowResponse.fromJson(Map<String, dynamic> json) {
    return ServiceLookupRowResponse(json['cells'].cast<String>());
  }
}

class ServiceLookupLookupResponse {
  String entity; //    string         `json:"entity"`
  String keyColumn; // string         `json:"key_column"`
  List<ServiceLookupColumnResponse>
      columns; //   []ResultColumn `json:"columns"`
  List<ServiceLookupRowResponse> rows; //      []ResultRow    `json:"rows"`
  ServiceLookupLookupResponse(
      this.entity, this.keyColumn, this.columns, this.rows);
  factory ServiceLookupLookupResponse.fromJson(Map<String, dynamic> json) {
    return ServiceLookupLookupResponse(
      json['entity'],
      json['key_column'],
      List<ServiceLookupColumnResponse>.from(
        json['columns']
            .map((model) => ServiceLookupColumnResponse.fromJson(model)),
      ),
      List<ServiceLookupRowResponse>.from(
        json['rows'].map((model) => ServiceLookupRowResponse.fromJson(model)),
      ),
    );
  }
}

class ServiceLookupResponse {
  ServiceLookupLookupResponse result;
  ServiceLookupResponse(this.result);

  factory ServiceLookupResponse.fromJson(Map<String, dynamic> json) {
    return ServiceLookupResponse(
      ServiceLookupLookupResponse.fromJson(json['result']),
    );
  }
}
