import 'dart:math';

import 'package:base32/base32.dart';

class XchgNetworkHost {
  String address;
  String name;

  XchgNetworkHost(this.address, this.name);

  factory XchgNetworkHost.fromJson(Map<String, dynamic> json) {
    return XchgNetworkHost(json['address'], json['name']);
  }

  Map<String, dynamic> toJson() => {
        'address': address,
        'name': name,
      };
}

class XchgNetworkRange {
  String prefix;
  List<XchgNetworkHost> hosts;
  XchgNetworkRange(this.prefix, this.hosts);

  factory XchgNetworkRange.fromJson(Map<String, dynamic> json) {
    return XchgNetworkRange(
        json['prefix'] ?? "",
        List<XchgNetworkHost>.from(
            json['hosts'].map((model) => XchgNetworkHost.fromJson(model))));
  }

  Map<String, dynamic> toJson() => {
        'prefix': prefix,
        'hosts': hosts,
      };
}

class XchgNetwork {
  String name = "";
  int timestamp = 0;
  List<String> initialPoints = [];
  List<XchgNetworkRange> ranges = [];

  /////////////////////////
  String debugSource = "";
  /////////////////////////

  XchgNetwork(this.name, this.timestamp, this.initialPoints, this.ranges);

  factory XchgNetwork.empty() {
    return XchgNetwork("", 0, [], []);
  }

  factory XchgNetwork.localRouter() {
    return XchgNetwork("LocalRouter", 0, [
      "127.0.0.1:8084"
    ], [
      XchgNetworkRange("0", [XchgNetworkHost("127.0.0.1:8084", "0")]),
      XchgNetworkRange("1", [XchgNetworkHost("127.0.0.1:8084", "1")]),
      XchgNetworkRange("2", [XchgNetworkHost("127.0.0.1:8084", "2")]),
      XchgNetworkRange("3", [XchgNetworkHost("127.0.0.1:8084", "3")]),
      XchgNetworkRange("4", [XchgNetworkHost("127.0.0.1:8084", "4")]),
      XchgNetworkRange("5", [XchgNetworkHost("127.0.0.1:8084", "5")]),
      XchgNetworkRange("6", [XchgNetworkHost("127.0.0.1:8084", "6")]),
      XchgNetworkRange("7", [XchgNetworkHost("127.0.0.1:8084", "7")]),
      XchgNetworkRange("8", [XchgNetworkHost("127.0.0.1:8084", "8")]),
      XchgNetworkRange("9", [XchgNetworkHost("127.0.0.1:8084", "9")]),
      XchgNetworkRange("a", [XchgNetworkHost("127.0.0.1:8084", "a")]),
      XchgNetworkRange("b", [XchgNetworkHost("127.0.0.1:8084", "b")]),
      XchgNetworkRange("c", [XchgNetworkHost("127.0.0.1:8084", "c")]),
      XchgNetworkRange("d", [XchgNetworkHost("127.0.0.1:8084", "d")]),
      XchgNetworkRange("e", [XchgNetworkHost("127.0.0.1:8084", "e")]),
      XchgNetworkRange("f", [XchgNetworkHost("127.0.0.1:8084", "f")]),
    ]);
  }

  factory XchgNetwork.fromJson(Map<String, dynamic> json) {
    return XchgNetwork(
      json['name'] ?? "",
      json['timestamp'] ?? 0,
      List<String>.from(json['initial_points'].map((model) => model)),
      List<XchgNetworkRange>.from(
          json['ranges'].map((model) => XchgNetworkRange.fromJson(model))),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'timestamp': timestamp,
        'initial_points': ranges,
        'ranges': ranges,
      };

  String getRandomNode() {
    int totalCount = 0;
    for (var range in ranges) {
      for (var _ in range.hosts) {
        totalCount++;
      }
    }
    Random rnd = Random(DateTime.now().microsecondsSinceEpoch);
    int randomNumber = rnd.nextInt(totalCount - 1);
    int counter = 0;
    for (var range in ranges) {
      for (var node in range.hosts) {
        if (counter == randomNumber) {
          return node.address;
        }
        counter++;
      }
    }
    return "";
  }

  List<String> getNodesAddressesByAddress(String address) {
    List<String> result = [];

    XchgNetworkRange? preferredRange;
    int preferredRangeScore = 0;

    if (address.startsWith("#")) {
      address = address.substring(1);
    }

    var addressHex =
        base32.decodeAsHexString(address.toUpperCase()).toLowerCase();
    for (var range in ranges) {
      int rangeScore = 0;
      for (int i = 0; i < addressHex.length && i < range.prefix.length; i++) {
        if (addressHex[i] == range.prefix[i]) {
          rangeScore++;
        }
      }
      if (rangeScore > preferredRangeScore) {
        preferredRange = range;
        preferredRangeScore = rangeScore;
      }
    }

    if (preferredRange != null) {
      for (var host in preferredRange.hosts) {
        result.add(host.address);
      }
    }

    return result;
  }
}
