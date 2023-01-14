import 'dart:async';

import '../workspace/workspace.dart';
import 'history_node.dart';

class History {
  Map<String, HistoryNode> nodes = {};

  History() {
    // CleanUp
    Timer.periodic(const Duration(milliseconds: 5000), (timer) {
      for (var nKey in nodes.keys) {
        nodes[nKey]!.cleanUp();
      }
    });

    // Request Values & History
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      for (var nodeKey in nodes.keys) {
        nodes[nodeKey]!.request();
      }
    });
  }

  HistoryNode getNode(Connection conn) {
    HistoryNode node = HistoryNode(conn);
    if (nodes.containsKey(conn.id)) {
      var n = nodes[conn.id];
      if (n != null) {
        node = n;
      }
    } else {
      nodes[conn.id] = node;
    }
    return node;
  }
}
