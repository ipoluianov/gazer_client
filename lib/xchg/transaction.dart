import 'dart:typed_data';
import 'package:base32/base32.dart';

class Transaction {
  int frameType = 0;
  // Reserved

  int transactionId = 0;
  int sessionId = 0;
  int offset = 0;
  int totalSize = 0;
  String srcAddress = "";
  String destAddress = "";
  Uint8List data = Uint8List(0);

  bool complete = false;
  String error = "";
  Uint8List response = Uint8List(0);
  DateTime dtBegin = DateTime.now();
  Uint8List result = Uint8List(0);

  int receivedDataLen = 0;

  factory Transaction.fromBinary(Uint8List frame, int offset, int size) {
    frame = frame.sublist(offset);
    Transaction tr = Transaction(0, "", "", 0, 0, 0, 0, Uint8List(0));
    tr.frameType = frame[8];
    tr.transactionId = frame.buffer.asUint64List(16)[0];
    tr.sessionId = frame.buffer.asUint64List(24)[0];
    tr.offset = frame.buffer.asUint32List(32)[0];
    tr.totalSize = frame.buffer.asUint32List(36)[0];

    tr.srcAddress =
        base32.encode(Uint8List.fromList(frame.sublist(40, 70))).toLowerCase();
    tr.destAddress =
        base32.encode(Uint8List.fromList(frame.sublist(70, 100))).toLowerCase();

    tr.data = frame.sublist(128, size);
    return tr;
  }

  Transaction(
      int frameType_,
      String srcAddr_,
      String destAddr_,
      int transactrionId_,
      int sessionId_,
      int offset_,
      int totalSize_,
      Uint8List data_) {
    frameType = frameType_;
    srcAddress = srcAddr_;
    destAddress = destAddr_;
    transactionId = transactrionId_;
    sessionId = sessionId_;
    offset = offset_;
    totalSize = totalSize_;
    data = data_;
  }

  List<int> serialize() {
    int frameLen = 128 + data.length;
    List<int> result = [];
    result.addAll(int32bytes(frameLen));
    result.addAll(int32bytes(0)); // CRC32

    result.add(frameType);
    result.add(0x00);
    result.add(0x00);
    result.add(0x00);

    result.add(0x00);
    result.add(0x00);
    result.add(0x00);
    result.add(0x00);

    result.addAll(int64bytes(transactionId));
    result.addAll(int64bytes(sessionId));
    result.addAll(int32bytes(offset));
    result.addAll(int32bytes(totalSize));

    var srcAddressBS =
        base32.decode(srcAddress.replaceAll("#", "").toUpperCase());
    var destAddressBS =
        base32.decode(destAddress.replaceAll("#", "").toUpperCase());

    result.addAll(srcAddressBS);
    result.addAll(destAddressBS);

    result.addAll([
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0
    ]);

    result.addAll(data);
    return result;
  }

  Uint8List int32bytes(int value) =>
      Uint8List(4)..buffer.asInt32List()[0] = value;
  Uint8List int64bytes(int value) =>
      Uint8List(8)..buffer.asInt64List()[0] = value;
}
