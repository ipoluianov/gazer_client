class UnitStartRequest {
  List<String> units;
  UnitStartRequest(this.units);
  Map<String, dynamic> toJson() => {
    'ids': units,
  };
}

class UnitStartResponse {
  UnitStartResponse();
  factory UnitStartResponse.fromJson(Map<String, dynamic> json) {
    return UnitStartResponse();
  }
}
