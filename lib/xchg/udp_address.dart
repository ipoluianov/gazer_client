import 'dart:io';

class UdpAddress {
  InternetAddress address;
  int port;

  UdpAddress(this.address, this.port);

  @override
  String toString() {
    return address.toString() + "$port";
  }
}
