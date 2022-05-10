import 'dart:convert';
import 'dart:typed_data';

class ResListRequest {
  String type;
  String filter;
  int offset;
  int maxCount;
  ResListRequest(this.type, this.filter, this.offset, this.maxCount);
  Map<String, dynamic> toJson() => {
        'type': type,
        'filter': filter,
        'offset': offset,
        'max_count': maxCount,
      };
}

class ResListItemItemPropResponse {
  String propName;
  String propValue;
  ResListItemItemPropResponse(this.propName, this.propValue);

  factory ResListItemItemPropResponse.fromJson(Map<String, dynamic> json) {
    return ResListItemItemPropResponse(
      json['n'],
      json['v'],
    );
  }
}

class ResListItemItemResponse {
  String id;
  String type;
  List<ResListItemItemPropResponse> props;
  Uint8List thumbnail;

  ResListItemItemResponse(this.id, this.type, this.props, this.thumbnail);

  String getProp(String name) {
    String result = "";
    for (var prop in props) {
      if (prop.propName == name) {
        result = prop.propValue;
        break;
      }
    }
    return result;
  }

  factory ResListItemItemResponse.fromJson(Map<String, dynamic> json) {
    Uint8List th = Uint8List(0);
    String? thString = json['thumbnail'];
    if (thString != null) {
      th = const Base64Decoder().convert(thString);
    }
    return ResListItemItemResponse(
        json['id'],
        json['type'],
        json['p'] != null ? List<ResListItemItemPropResponse>.from(
          json['p'].map((model) => ResListItemItemPropResponse.fromJson(model)),
        ) : [],
        th);
  }
}

class ResListItemResponse {
  int totalCount;
  int inFilterCount;
  List<ResListItemItemResponse> items;

  ResListItemResponse(this.totalCount, this.inFilterCount, this.items);

  factory ResListItemResponse.fromJson(Map<String, dynamic> json) {
    return ResListItemResponse(
        json['total_count'],
        json['in_filter_count'],
        List<ResListItemItemResponse>.from(
          json['items'].map((model) => ResListItemItemResponse.fromJson(model)),
        ));
  }
}

class ResListResponse {
  ResListItemResponse item;
  ResListResponse(this.item);

  factory ResListResponse.fromJson(Map<String, dynamic> json) {
    return ResListResponse(ResListItemResponse.fromJson(json['items']));
  }
}
