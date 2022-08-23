import 'dart:typed_data';

class Transaction {
  int frameType = 0;
  int sid = 0;
  int transactionId = 0;
  int sessionId = 0;
  Uint8List data = Uint8List(0);

  bool complete = false;
  String error = "";
  Uint8List response = Uint8List(0);

  factory Transaction.fromBinary(Uint8List frame, int offset, int size) {
    frame = frame.sublist(offset);
    Transaction tr = Transaction();
    tr.frameType = frame[2];
    tr.sid = frame.buffer.asUint64List(8)[0];
    tr.transactionId = frame.buffer.asUint64List(16)[0];
    tr.sessionId = frame.buffer.asUint64List(24)[0];
    tr.data = frame.sublist(32, size);
    return tr;
  }

  Transaction();
  List<int> serialize() {
    int frameLen = 32 + data.length;
    List<int> result = [];
    result.add(0xAA);
    result.add(0x01);
    result.add(frameType);
    result.add(0x00);
    result.addAll(int32bytes(frameLen));
    result.addAll(int64bytes(sid));
    result.addAll(int64bytes(transactionId));
    result.addAll(int64bytes(sessionId));
    result.addAll(data);
    return result;
  }

  Uint8List int32bytes(int value) =>
      Uint8List(4)..buffer.asInt32List()[0] = value;
  Uint8List int64bytes(int value) =>
      Uint8List(8)..buffer.asInt64List()[0] = value;
}
