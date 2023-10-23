import 'dart:typed_data';

class ResSetByPathRequest {
  String path;
  String type;
  String content;
  ResSetByPathRequest(this.path, this.type, this.content);
  Map<String, dynamic> toJson() => {
        'path': path,
        'type': type,
        'content': content,
      };
}

class ResSetByPathResponse {
  String id;
  ResSetByPathResponse(this.id);

  factory ResSetByPathResponse.fromJson(Map<String, dynamic> json) {
    return ResSetByPathResponse(json['id']);
  }
}
