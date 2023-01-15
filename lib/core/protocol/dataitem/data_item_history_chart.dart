import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:gazer_client/core/gazer_local_client.dart';

import 'data_item_list.dart';

class DataItemHistoryChartItemRequest {
  String name;
  int dtBegin;
  int dtEnd;
  int groupTimeRange;
  String outFormat;

  DataItemHistoryChartItemRequest(
      this.name, this.dtBegin, this.dtEnd, this.groupTimeRange, this.outFormat);
  Map<String, dynamic> toJson() => {
        'name': name,
        'dt_begin': dtBegin,
        'dt_end': dtEnd,
        'group_time_range': groupTimeRange,
      };
}

class DataItemHistoryChartRequest {
  List<DataItemHistoryChartItemRequest> items;

  DataItemHistoryChartRequest(this.items);
  Map<String, dynamic> toJson() {
    List<dynamic> result = [];

    for (var item in items) {
      result.add(item.toJson());
    }

    return {'items': result};
  }
}

class DataItemHistoryChartItemValueResponse {
  int datetimeFirst;
  int datetimeLast;
  double firstValue;
  double lastValue;
  double minValue;
  double maxValue;
  double avgValue;
  double sumValue;
  int countOfValues;
  List<int> qualities;
  bool hasGood;
  bool hasBad;
  String uom;

  DataItemHistoryChartItemValueResponse(
      this.datetimeFirst,
      this.datetimeLast,
      this.firstValue,
      this.lastValue,
      this.minValue,
      this.maxValue,
      this.avgValue,
      this.sumValue,
      this.countOfValues,
      this.qualities,
      this.hasGood,
      this.hasBad,
      this.uom);

  factory DataItemHistoryChartItemValueResponse.fromJson(
      Map<String, dynamic> json) {
    return DataItemHistoryChartItemValueResponse(
      (double.tryParse("${json['tf']}") ?? 0).toInt(),
      (double.tryParse("${json['tl']}") ?? 0).toInt(),
      double.tryParse("${json['vf']}") ?? 0,
      double.tryParse("${json['vl']}") ?? 0,
      double.tryParse("${json['vd']}") ?? 0,
      double.tryParse("${json['vu']}") ?? 0,
      double.tryParse("${json['va']}") ?? 0,
      double.tryParse("${json['vs']}") ?? 0,
      json['c'],
      [],
      json['has_good'],
      json['has_bad'],
      json['uom'],
    );
  }
}

class DataItemHistoryChartItemResponse {
  String name;
  int dtBegin;
  int dtEnd;
  int groupTimeRange;
  DataItemInfo currentValue;

  List<DataItemHistoryChartItemValueResponse> items;

  DataItemHistoryChartItemResponse(this.name, this.dtBegin, this.dtEnd,
      this.groupTimeRange, this.items, this.currentValue);

  factory DataItemHistoryChartItemResponse.fromJson(Map<String, dynamic> json) {
    return DataItemHistoryChartItemResponse(
        json['name'],
        json['dt_begin'],
        json['dt_end'],
        json['group_time_range'],
        List<DataItemHistoryChartItemValueResponse>.from(
          json['items'].map(
              (model) => DataItemHistoryChartItemValueResponse.fromJson(model)),
        ),
        DataItemInfo.fromJson(json['value']));
  }
}

class DataItemHistoryChartResponse {
  List<DataItemHistoryChartItemResponse> items;

  DataItemHistoryChartResponse(this.items);

  factory DataItemHistoryChartResponse.fromJson(Map<String, dynamic> json) {
    if (json['items'] == null) {
      return DataItemHistoryChartResponse([]);
    }
    return DataItemHistoryChartResponse(
      List<DataItemHistoryChartItemResponse>.from(
        json['items']
            .map((model) => DataItemHistoryChartItemResponse.fromJson(model)),
      ),
    );
  }
}
