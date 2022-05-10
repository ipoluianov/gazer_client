import 'dart:convert';

import '../gazer_local_client.dart';

class GazerError {
  final String message;
  GazerError(this.message);
  factory GazerError.fromJson(Map<String, dynamic> json) {
    return GazerError(json['error']);
  }
}

String parseException(Exception ex) {
  String result = ex.toString();
  if (ex is GazerClientException) {
    try {
      var gazerError = GazerError.fromJson(jsonDecode((ex.message)));
      result = gazerError.message;
    } catch (e) {
      result = ex.toString();
    }
    return result;
  }
  return ex.toString();
}
