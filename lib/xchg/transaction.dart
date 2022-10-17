import 'dart:typed_data';

class Transaction {
  int frameType = 0;
  int status = 0;
  // Reserved

  int transactionId = 0;
  int sessionId = 0;
  int offset = 0;
  int totalSize = 0;
  Uint8List data = Uint8List(0);

  bool complete = false;
  String error = "";
  Uint8List response = Uint8List(0);
  DateTime dtBegin = DateTime.now();
  Uint8List result = Uint8List(0);

  int receivedDataLen = 0;

  factory Transaction.fromBinary(Uint8List frame, int offset, int size) {
    frame = frame.sublist(offset);
    Transaction tr = Transaction();
    tr.frameType = frame[0];
    tr.status = frame[1];
    tr.transactionId = frame.buffer.asUint64List(8)[0];
    tr.sessionId = frame.buffer.asUint64List(16)[0];
    tr.offset = frame.buffer.asUint32List(32)[0];
    tr.totalSize = frame.buffer.asUint32List(36)[0];
    tr.data = frame.sublist(40, size);
    return tr;
  }

  Transaction();
  List<int> serialize() {
    int frameLen = 40 + data.length;
    List<int> result = [];
    
    result.add(frameType);
    result.add(status);
    result.add(0x00);
    result.add(0x00);

    result.add(0x00);
    result.add(0x00);
    result.add(0x00);
    result.add(0x00);

    result.addAll(int64bytes(transactionId));
    result.addAll(int64bytes(sessionId));
    result.addAll(int64bytes(0));
    result.addAll(int32bytes(offset));
    result.addAll(int32bytes(totalSize));
    result.addAll(data);
    return result;
  }

  Uint8List int32bytes(int value) =>
      Uint8List(4)..buffer.asInt32List()[0] = value;
  Uint8List int64bytes(int value) =>
      Uint8List(8)..buffer.asInt64List()[0] = value;
}
