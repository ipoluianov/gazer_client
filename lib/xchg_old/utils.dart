import 'dart:typed_data';

class CallResult {
  Uint8List data = Uint8List(0);
  String error = "";

  CallResult();

  factory CallResult.createError(String err) {
    CallResult res = CallResult();
    res.data = Uint8List(0);
    res.error = err;
    return res;
  }

  bool isError() {
    return error.isNotEmpty;
  }
}