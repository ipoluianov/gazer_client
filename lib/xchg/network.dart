import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:base32/base32.dart';

class XchgNetworkHost {
  String address;
  String name;
  String ethAddress;
  String solAddress;

  XchgNetworkHost(this.address, this.name, this.ethAddress, this.solAddress);

  factory XchgNetworkHost.fromJson(Map<String, dynamic> json) {
    return XchgNetworkHost(json['address'], json['name'], json['eth_addr'], json['sol_addr']);
  }

  Map<String, dynamic> toJson() => {
        'address': address,
        'name': name,
        'eth_addr': ethAddress,
        'sol_addr': solAddress,
      };
}

class XchgNetworkRange {
  String prefix;
  List<XchgNetworkHost> hosts;
  XchgNetworkRange(this.prefix, this.hosts);

  factory XchgNetworkRange.fromJson(Map<String, dynamic> json) {
    return XchgNetworkRange(json['prefix']??"", List<XchgNetworkHost>.from(json['hosts'].map((model) => XchgNetworkHost.fromJson(model))));
  }

  Map<String, dynamic> toJson() => {
        'prefix': prefix,
        'hosts': hosts,
      };
}

Future<XchgNetwork?> loadNetworkFromInternet() async {
  XchgNetwork? network;
  var response = await http.get(Uri.parse('https://xchgx.net/network.json'));
  if (response.statusCode == 200) {
    //print(response.body);
    network = XchgNetwork.fromJson(jsonDecode(response.body));
  }
  return network;
}

class XchgNetwork {
  String name = "";
  String ethAddress = "";
  String solAddress = "";
  List<XchgNetworkRange> ranges = [];
  List<XchgNetworkHost> gateways = [];

  XchgNetwork(this.name, this.ethAddress, this.solAddress, this.ranges, this.gateways);

  factory XchgNetwork.empty() {
    return XchgNetwork("", "", "", [], []);
  }


  factory XchgNetwork.fromJson(Map<String, dynamic> json) {
    return XchgNetwork(json['prefix']??"", json['eth_addr']??"", json['sol_addr']??"", List<XchgNetworkRange>.from(json['ranges'].map((model) => XchgNetworkRange.fromJson(model))),
    List<XchgNetworkHost>.from(json['gateways'].map((model) => XchgNetworkHost.fromJson(model))));
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'eth_addr': ethAddress,
        'sol_addr': solAddress,
        'ranges': ranges,
        'gateways': gateways,
      };

  List<String> getNodesAddressesByAddress(String address) {
    List<String> result = [];

    XchgNetworkRange? preferredRange;
    int preferredRangeScore = 0;

    var addressHex = base32.decodeAsHexString(address.toUpperCase()).toLowerCase();
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
