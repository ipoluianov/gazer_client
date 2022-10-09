import 'package:pointycastle/asymmetric/api.dart';

import 'network.dart';
import 'transaction.dart';

class RemotePeer {
  String remoteAddress;
  String authData;
  RSAPrivateKey privateKey;
  XchgNetwork network;
  Map<int, Transaction> outgoingTransactions = {};
  int nextTransactionId = 1;
  Nonces nonces;

  RemotePeer(this.remoteAddress, this.authData, this.privateKey, this.network) {
    nonces
  }
}
