class UnitStopRequest {
  List<String> units;
  UnitStopRequest(this.units);
  Map<String, dynamic> toJson() => {
    'ids': units,
  };
}

class UnitStopResponse {
  UnitStopResponse();
  factory UnitStopResponse.fromJson(Map<String, dynamic> json) {
    return UnitStopResponse();
  }
}
