import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/core/history/history.dart';
import 'package:gazer_client/core/items_watcher/items_watcher.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:pointycastle/api.dart';
import 'package:pointycastle/asymmetric/api.dart';

import '../xchg/peer.dart';

enum NavIndex { home, units, charts, maps, more }

class Repository {
  static final Repository _singleton = Repository._internal();

  factory Repository() {
    return _singleton;
  }

  Map<String, GazerLocalClient> clients = {};
  String lastPath = "/";
  Connection lastSelectedConnection = Connection.makeDefault();
  History history = History();
  ItemsWatcher itemsWatcher = ItemsWatcher();
  NavIndex navIndex = NavIndex.units;
  //XchgConnection xchg = XchgConnection("gruvl3znuewl3gslgkz6aaebya4j5hvd2lcgu3i4lvj263ze", "pass");

  late AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> mainKeyPair;
  bool peerLoaded = false;
  Peer peerMainNet = Peer(null, false, "");
  Map<String, Peer> peers = {};

  void initPeer(AsymmetricKeyPair<RSAPublicKey, RSAPrivateKey> keyPair) {
    mainKeyPair = keyPair;
    peerMainNet = Peer(keyPair, false, "");
  }

  Peer peer(String networkId) {
    if (networkId.isEmpty) {
      return peerMainNet;
    }
    if (peers.containsKey(networkId)) {
      return peers[networkId]!;
    }
    var p = Peer(mainKeyPair, false, networkId);
    peers[networkId] = p;
    return p;
  }

  GazerLocalClient client(Connection conn) {
    String clientKey =
        "${conn.address} / ${conn.sessionKey} / ${conn.transport} / ${conn.networkId}";
    if (clients.containsKey(clientKey)) {
      GazerLocalClient? client = clients[clientKey];
      return client!;
    } else {
      GazerLocalClient client = GazerLocalClient(clientKey, conn.transport,
          conn.address, conn.sessionKey, conn.networkId);
      clients[clientKey] = client;
      print("Created client: $clientKey");
      return client;
    }
  }

  Repository._internal();
}

bool peerInited = false;

Future<void> loadPeer() async {
  if (peerInited) {
    return;
  }
  //await Future.delayed(Duration(milliseconds: 5000));

  try {
    var keyPair = await getKeyPair();
    await loadAppearance();
    DesignColors.setPalette(DesignColors.palette());
    Repository().initPeer(keyPair);
    peerInited = true;
  } catch (ex) {}
}
