import 'dart:typed_data';

class ResSetRequest {
  String id;
  String suffix;
  int offset;
  String content;
  ResSetRequest(this.id, this.suffix, this.offset, this.content);
  Map<String, dynamic> toJson() => {
    'id': id,
    'suffix': suffix,
    'content': content,
    'offset': offset,
  };
}

class ResSetResponse {
  ResSetResponse();

  factory ResSetResponse.fromJson(Map<String, dynamic> json) {
    return ResSetResponse();
  }
}
