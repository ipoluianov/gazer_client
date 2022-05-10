class UnitRemoveRequest {
  List<String> units;
  UnitRemoveRequest(this.units);
  Map<String, dynamic> toJson() => {
    'ids': units,
  };
}

class UnitRemoveResponse {
  UnitRemoveResponse();
  factory UnitRemoveResponse.fromJson(Map<String, dynamic> json) {
    return UnitRemoveResponse();
  }
}
