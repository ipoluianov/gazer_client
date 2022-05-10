import 'dart:convert';
import 'dart:typed_data';

class ResGetThumbnailRequest {
  String id;
  ResGetThumbnailRequest(this.id);
  Map<String, dynamic> toJson() => {
    'id': id,
  };
}

class ResGetThumbnailItemResponse {
  String id;
  String name;
  String type;
  Uint8List content;
  ResGetThumbnailItemResponse(this.id, this.name, this.type, this.content);

  factory ResGetThumbnailItemResponse.fromJson(Map<String, dynamic> json) {
    var info = json['info'];
    Uint8List th = Uint8List(0);
    Uint8List cn = Uint8List(0);

    {
      String? cnString = json['content'];
      if (cnString != null) {
        cn = const Base64Decoder().convert(cnString);
      }
    }

    return ResGetThumbnailItemResponse(info['id'], info['name'], info['type'], cn);
  }
}

class ResGetThumbnailResponse {
  ResGetThumbnailItemResponse item;
  ResGetThumbnailResponse(this.item);

  factory ResGetThumbnailResponse.fromJson(Map<String, dynamic> json) {
    return ResGetThumbnailResponse(ResGetThumbnailItemResponse.fromJson(json['item']));
  }
}
