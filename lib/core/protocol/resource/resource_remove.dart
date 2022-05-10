import 'dart:typed_data';

class ResRemoveRequest {
  String id;
  ResRemoveRequest(this.id);
  Map<String, dynamic> toJson() => {
    'id': id,
  };
}

class ResRemoveResponse {
  ResRemoveResponse();

  factory ResRemoveResponse.fromJson(Map<String, dynamic> json) {
    return ResRemoveResponse();
  }
}
