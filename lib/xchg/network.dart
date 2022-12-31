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
