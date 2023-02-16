import 'dart:io';
import 'dart:typed_data';

import 'package:gazer_client/xchg/peer.dart';
import 'package:gazer_client/xchg/udp_address.dart';

import 'package:base32/base32.dart';

Future<void> sendFrame(
    UdpAddress? address, List<Uint8List> frames, Peer peer) async {
  if (address != null) {
    requestUDP1(address, frames, peer);
  } else {
    if (peer.network != null) {
      for (var frame in frames) {
        var destAddr = base32
            .encode(Uint8List.fromList(frame.sublist(70, 70 + 30)))
            .toLowerCase();
        for (var addr in peer.network!.getNodesAddressesByAddress(destAddr)) {
          peer.httpCall(addr, "w", frame, 1000).catchError((ex) {
            print("WRITE err = $ex");
          }).catchError((err) {
            print("sendFrame exception: $err");
          });
          //break;
        }
      }
    }
  }
}

Future<void> requestUDP1(
    UdpAddress address, List<Uint8List> frames, Peer peer) async {
  InternetAddress bindAddr = InternetAddress.anyIPv4;

  if (address.address.rawAddress.length == 16) {
    if (address.address.rawAddress[10] == 255 &&
        address.address.rawAddress[11] == 255) {
      address = UdpAddress(
          InternetAddress.fromRawAddress(
              address.address.rawAddress.sublist(12)),
          address.port);
    }
  }

  var udpSocket = await RawDatagramSocket.bind(bindAddr, 0);
  //udpSocket.broadcastEnabled = true;
  udpSocket.listen(
      (event) {
        if (event == RawSocketEvent.write) {
          for (var fr in frames) {
            for (var i = 0; i < 10; i++) {
              var sentBytes = udpSocket.send(fr, address.address, address.port);
              if (sentBytes == fr.length) {
                break;
              }
              print("Sent Error $sentBytes");
            }
          }
        }
        if (event == RawSocketEvent.read) {
          Datagram? dg = udpSocket.receive();
          if (dg != null) {
            peer.processFrame(UdpAddress(dg.address, dg.port), "UDP", dg.data);
            //result = UdpResponse(UdpAddress(dg.address, dg.port), dg.data);
          }
        }

        if (event == RawSocketEvent.closed) {
          udpSocket.close();
        }
        if (event == RawSocketEvent.readClosed) {
          udpSocket.close();
        }
      },
      cancelOnError: true,
      onDone: () {
        udpSocket.close();
      },
      onError: (err) {
        udpSocket.close();
      });

  await Future.delayed(const Duration(milliseconds: 3000));
  udpSocket.close();
}
