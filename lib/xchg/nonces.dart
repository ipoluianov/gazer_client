import 'dart:math';
import 'dart:typed_data';

class Nonces {
  int currentIndex = 0;
  int complexity = 0;
  List<Uint8List> nonces = [];
  Nonces(int size) {
    for (int i = 0; i < size; i++) {
      nonces.add(Uint8List(0));
    }
  }

  void fillNonce(int index) {
    if (index >= 0 && index < nonces.length) {
     Uint8List nonce = Uint8List(16);
      nonce.buffer.asInt32List()[0] = index;
      nonce[4] = complexity;
      var rnd = Random();
      for (var i = 5; i < 16; i++) {
        nonce[i] = rnd.nextInt(255);
      }
      nonces[index] = nonce;
    }
  }

  Uint8List next() {
    fillNonce(currentIndex);
    var result = nonces[currentIndex];
    currentIndex++;
    if (currentIndex >= nonces.length) {
      currentIndex = 0;
    }
    return result;
  }

  bool check(Uint8List nonce) {
    if (nonce.length != 16) {
      return false;
    }

    int index = nonce.buffer.asInt32List()[0];
    if (index < 0 || index >= nonces.length) {
      return false;
    }

    Uint8List originalNonce = nonces[index];
    for (int i = 0; i < 16; i++)
    {
      if (originalNonce[i] != nonce[i]) {
        return false;
      }
    }

    fillNonce(index);

    return true;
  }

  Uint8List int32bytes(int value) =>
      Uint8List(4)..buffer.asInt32List()[0] = value;
}
