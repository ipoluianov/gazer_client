import 'dart:typed_data';

class Nonces {
  List<Uint8List> nonces = [];
  Nonces() {
    for ( int i = 0; i < 100; i++) {
      nonces.add(Uint8List(0));
    }
  }

  Uint8List generateNewNonce() {

  }
}
