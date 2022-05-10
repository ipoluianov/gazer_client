class DataItemHistoryRequest {
  String itemName;
  int dtBegin;
  int dtEnd;
  DataItemHistoryRequest(this.itemName, this.dtBegin, this.dtEnd);
  Map<String, dynamic> toJson() => {
        'name': itemName,
        'dt_begin': dtBegin,
        'dt_end': dtEnd,
      };
}

class DataItemHistoryResultItemResponse {
  String value;
  int dt;
  String uom;
  DataItemHistoryResultItemResponse(this.value, this.dt, this.uom);

  factory DataItemHistoryResultItemResponse.fromJson(Map<String, dynamic> json) {
    return DataItemHistoryResultItemResponse(json['v'], json['t'], json['u']);
  }
}

class DataItemHistoryResultResponse {
  int id;
  int dtBegin;
  int dtEnd;
  List<DataItemHistoryResultItemResponse> items;
  DataItemHistoryResultResponse(this.id, this.dtBegin, this.dtEnd, this.items);

  factory DataItemHistoryResultResponse.fromJson(Map<String, dynamic> json) {
    return DataItemHistoryResultResponse(
        json['id'],
        json['dt_begin'],
        json['dt_end'],
        List<DataItemHistoryResultItemResponse>.from(
          json['items'].map((model) => DataItemHistoryResultItemResponse.fromJson(model)),
        ));
  }
}

class DataItemHistoryResponse {
  DataItemHistoryResultResponse result;
  DataItemHistoryResponse(this.result);

  factory DataItemHistoryResponse.fromJson(Map<String, dynamic> json) {
    return DataItemHistoryResponse(DataItemHistoryResultResponse.fromJson(json['history']));
  }
}
