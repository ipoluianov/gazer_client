import 'dart:convert';
import 'dart:typed_data';

class ResGetByPathRequest {
  String path;
  int offset;
  int size;
  ResGetByPathRequest(this.path, this.offset, this.size);
  Map<String, dynamic> toJson() => {
        'path': path,
        'offset': offset,
        'size': size,
      };
}

class ResGetByPathResponse {
  String id;
  String name;
  String type;
  Uint8List content;
  int size;
  String hash;

  ResGetByPathResponse(
      this.id, this.name, this.type, this.content, this.size, this.hash);

  factory ResGetByPathResponse.fromJson(Map<String, dynamic> json) {
    Uint8List cn = Uint8List(0);

    {
      String? cnString = json['content'];
      if (cnString != null) {
        cn = const Base64Decoder().convert(cnString);
      }
    }

    return ResGetByPathResponse(
        json['id'], json['name'], json['type'], cn, json['size'], json['hash']);
  }
}
