import 'dart:typed_data';

class ResPropSetItemRequest {
  String propName;
  String propValue;
  ResPropSetItemRequest(this.propName, this.propValue);
  Map<String, dynamic> toJson() => {
    'prop_name': propName,
    'prop_value': propValue,
  };
}

class ResPropSetRequest {
  String id;
  List<ResPropSetItemRequest> props;
  ResPropSetRequest(this.id, this.props);
  Map<String, dynamic> toJson() => {
    'id': id,
    'props': props,
  };
}

class ResPropSetResponse {
  ResPropSetResponse();

  factory ResPropSetResponse.fromJson(Map<String, dynamic> json) {
    return ResPropSetResponse();
  }
}
