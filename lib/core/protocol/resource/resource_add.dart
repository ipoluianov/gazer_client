import 'dart:typed_data';

class ResAddRequest {
  String name;
  String type;
  String content;
  ResAddRequest(this.name, this.type, this.content);
  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type,
    'content': content,
  };
}

class ResAddResponse {
  String id;
  ResAddResponse(this.id);

  factory ResAddResponse.fromJson(Map<String, dynamic> json) {
    return ResAddResponse(json['id']);
  }
}
