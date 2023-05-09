import 'dart:io';
import 'dart:typed_data';

import 'package:gazer_client/xchg/peer.dart';

import 'package:base32/base32.dart';

Future<void> sendFrame(
    List<Uint8List> frames, Peer peer, bool onlyLocalRouter) async {
  try {
    if (peer.network != null) {
      for (var frame in frames) {
        var destAddr = base32
            .encode(Uint8List.fromList(frame.sublist(70, 70 + 30)))
            .toLowerCase();
        var nodes = peer.network!.getNodesAddressesByAddress(destAddr);
        if (onlyLocalRouter) {
          nodes = peer.network!.getLocalNodes();
          //print("LOCAL ROUTER");
        } else {
          //print("REMOTE ROUTER");
        }
        for (var addr in nodes) {
          if (addr.contains("x01")) {
            print("---------------- Address: $addr");
          }
          await peer.httpCall(addr, "w", frame).catchError((err) {
            print("write error: $err");
          });
          //break;
        }
      }
    }
  } catch (ex) {
    print("send Frame error");
  }
}
