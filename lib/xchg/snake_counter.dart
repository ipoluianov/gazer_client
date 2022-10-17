import 'dart:typed_data';

class SnakeCounter {
  int size = 10;
  Uint8List data = Uint8List(0);
  int lastProcessed = -1;

  SnakeCounter(int initialSize, int initialValue) {
    size = initialSize;
    lastProcessed = -1;
    data = Uint8List(initialSize);
    for (int i = 0; i < data.length; i++) {
      data[i] = 1;
    }
    testAndDeclare(initialValue);
  }

  bool testAndDeclare(int counter) {
    if (counter < lastProcessed - data.length) {
      return false; // too less
    }

    if (counter > lastProcessed) {
      var shiftRange = counter - lastProcessed;
      Uint8List newData = Uint8List(data.length);
      for (int i = 0; i < newData.length; i++) {
        int b = 0;
        int oldAddressOfCell = i - shiftRange;
        if (oldAddressOfCell >= 0 && oldAddressOfCell < data.length) {
          b = data[oldAddressOfCell];
        }
        newData[i] = b;
      }
      data = newData;
      data[0] = 1;
      lastProcessed = counter;
      return true;
    }

    int index = lastProcessed - counter;
    if (index >= 0 && index < data.length) {
      if (data[index] == 0) {
        data[lastProcessed - counter] = 1;
        return true;
      }
    }

    return false; // already used
  }
}
