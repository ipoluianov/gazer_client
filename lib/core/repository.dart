import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/core/history/history.dart';
import 'package:gazer_client/core/items_watcher/items_watcher.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

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
