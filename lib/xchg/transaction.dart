import 'dart:typed_data';
import 'package:base32/base32.dart';
import 'package:gazer_client/xchg/utils.dart';

class Transaction {
  int frameType = 0; // offset: 8
  int transactionId = 0; // offset: 16
  int sessionId = 0; // offset: 24
  int offset = 0; // offset: 32
  int totalSize = 0; // offset: 36
  String srcAddress = ""; // offset: 40
  String destAddress = ""; // offset: 70
  int billingCounter = 0;
  int billingLimit = 0;
  Uint8List data = Uint8List(0); // offset: 128

  bool complete = false;
  String error = "";
  Uint8List response = Uint8List(0);
  DateTime dtBegin = DateTime.now();
  Uint8List result = Uint8List(0);

  // Runtime
  String srcRouterAddr = "";
  String transportType = "";

  int receivedDataLen = 0;

  factory Transaction.fromBinary(Uint8List frame, int offset, int size) {
    frame = frame.sublist(offset);
    Transaction tr = Transaction(0, "", "", 0, 0, 0, 0, Uint8List(0));
    tr.frameType = frame[8];
    tr.transactionId = frame.buffer.asUint64List(16)[0];
    tr.sessionId = frame.buffer.asUint64List(24)[0];
    tr.offset = frame.buffer.asUint32List(32)[0];
    tr.totalSize = frame.buffer.asUint32List(36)[0];

    tr.srcAddress = "#" +
        base32.encode(Uint8List.fromList(frame.sublist(40, 70))).toLowerCase();
    tr.destAddress = "#" +
        base32.encode(Uint8List.fromList(frame.sublist(70, 100))).toLowerCase();

    tr.billingCounter = frame.buffer.asUint32List(100)[0];
    tr.billingLimit = frame.buffer.asUint32List(104)[0];

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
    Uint8List result = Uint8List(frameLen);
    result.fillRange(0, frameLen, 0);

    result.buffer.asUint32List(0)[0] = frameLen;
    result.buffer.asUint32List(4)[0] = 0; // CRC32
    result[8] = frameType;

    result.buffer.asUint64List(16)[0] = transactionId;
    result.buffer.asUint64List(24)[0] = sessionId;
    result.buffer.asUint32List(32)[0] = offset;
    result.buffer.asUint32List(36)[0] = totalSize;

    var srcAddressBS =
        base32.decode(srcAddress.replaceAll("#", "").toUpperCase());
    var destAddressBS =
        base32.decode(destAddress.replaceAll("#", "").toUpperCase());

    copyBytes(result, 40, srcAddressBS);
    copyBytes(result, 70, destAddressBS);
    copyBytes(result, 128, data);

    return result;
  }

  Uint8List int32bytes(int value) =>
      Uint8List(4)..buffer.asInt32List()[0] = value;
  Uint8List int64bytes(int value) =>
      Uint8List(8)..buffer.asInt64List()[0] = value;
}
