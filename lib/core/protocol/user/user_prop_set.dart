class UserPropSetItemRequest {
  String propName;
  String propValue;
  UserPropSetItemRequest(this.propName, this.propValue);
  Map<String, dynamic> toJson() => {
    'prop_name': propName,
    'prop_value': propValue,
  };
}

class UserPropSetRequest {
  String unitName;
  List<UserPropSetItemRequest> props;
  UserPropSetRequest(this.unitName, this.props);
  Map<String, dynamic> toJson() => {
    'user_name': unitName,
    'props': props,
  };
}

class UserPropSetResponse {
  UserPropSetResponse();

  factory UserPropSetResponse.fromJson(Map<String, dynamic> json) {
    return UserPropSetResponse();
  }
}
