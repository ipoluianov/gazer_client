import 'dart:convert';
import 'dart:typed_data';

class ResGetRequest {
  String id;
  int offset;
  int size;
  ResGetRequest(this.id, this.offset, this.size);
  Map<String, dynamic> toJson() => {
    'id': id,
    'offset': offset,
    'size': size,
  };
}

class ResGetResponse {
  String id;
  String name;
  String type;
  Uint8List content;
  int size;
  String hash;

  ResGetResponse(this.id, this.name, this.type, this.content, this.size, this.hash);

  factory ResGetResponse.fromJson(Map<String, dynamic> json) {
    Uint8List cn = Uint8List(0);

    {
      String? cnString = json['content'];
      if (cnString != null) {
        cn = const Base64Decoder().convert(cnString);
      }
    }

    return ResGetResponse(json['id'], json['name'], json['type'], cn, json['size'], json['hash']);
  }
}
