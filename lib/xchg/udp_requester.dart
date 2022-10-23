import 'dart:io';
import 'dart:typed_data';

import 'package:gazer_client/xchg/udp_address.dart';

class UDPFrame {
  UdpAddress address = UdpAddress(InternetAddress.anyIPv4, 0);
  Uint8List data = Uint8List(0);
  bool error = false;
}

