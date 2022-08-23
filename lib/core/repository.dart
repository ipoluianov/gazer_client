import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/core/history/history.dart';
import 'package:gazer_client/core/items_watcher/items_watcher.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/core/xchg/xchg.dart';

import '../xchg/xchg_connection.dart';

enum NavIndex {
  units,
  charts,
  maps,
  more
}

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
  XchgConnection xchg = XchgConnection("gruvl3znuewl3gslgkz6aaebya4j5hvd2lcgu3i4lvj263ze", "pass");

  GazerLocalClient client(Connection conn) {
    String clientKey = conn.address + " / " + conn.sessionKey + " / " + conn.transport;
    if (clients.containsKey(clientKey)) {
      GazerLocalClient? client = clients[clientKey];
      return client!;
    } else {
      GazerLocalClient client = GazerLocalClient(clientKey, conn.transport, conn.address, conn.sessionKey);
      clients[clientKey] = client;
      print("Created client: $clientKey");
      return client;
    }
  }

  Repository._internal();
}
