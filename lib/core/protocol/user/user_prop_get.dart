class UserPropGetRequest {
  String userName;
  UserPropGetRequest(this.userName);
  Map<String, dynamic> toJson() => {
    'user_name': userName,
  };
}

class UserPropGetItemResponse {
  String propName;
  String propValue;
  UserPropGetItemResponse(this.propName, this.propValue);

  factory UserPropGetItemResponse.fromJson(Map<String, dynamic> json) {
    return UserPropGetItemResponse(
      json['prop_name'],
      json['prop_value'],
    );
  }
}

class UserPropGetResponse {
  List<UserPropGetItemResponse> props;
  UserPropGetResponse(this.props);

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

  factory UserPropGetResponse.fromJson(Map<String, dynamic> json) {
    return UserPropGetResponse(
      List<UserPropGetItemResponse>.from(
        json['props'].map((model) => UserPropGetItemResponse.fromJson(model)),
      ),
    );
  }

  factory UserPropGetResponse.makeDefault() {
    return UserPropGetResponse([]);
  }
}
