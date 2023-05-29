import 'dart:convert';

import 'package:gazer_client/xchg/network_container.dart';

import 'network.dart';

class BillingFromRouter {
  String address = "";
  String router = "";

  int counter = 0;
  int limit = 0;

  BillingFromRouter(this.counter, this.limit);

  factory BillingFromRouter.fromJson(Map<String, dynamic> json) {
    return BillingFromRouter(
      json['counter'],
      json['limit'],
    );
  }
}

class BillingSummary {
  String clientAddress = "";
  String serverAddress = "";
  int counter = 0;
  int limit = 0;
}

class BillingForAddress {
  String address = "";
  Map<String, BillingFromRouter> billingInfoFromRouters = {};
  DateTime latestRequest = DateTime(0);
  void update(XchgNetwork? network) {
    if (network == null) {
      return;
    }
    if (DateTime.now().difference(latestRequest) < const Duration(seconds: 3)) {
      return;
    }
    latestRequest = DateTime.now();
    var routers = network!.getNodesAddressesByAddress(address);
    for (var router in routers) {
      httpGet("http://$router/api/billing?addr=${address.replaceAll("#", "")}",
              1000)
          .then((value) {
        //print(value);

        var jsonObject = jsonDecode(value);
        var billingObject = BillingFromRouter.fromJson(jsonObject);
        billingObject.router = router;
        billingObject.address = address;
        billingInfoFromRouters[router] = billingObject;
      }).catchError((err) {
        print("Billing request error: $err");
      });
    }
  }
}

class BillingDB {
  Map<String, BillingForAddress> entries = {};
  BillingForAddress get(XchgNetwork? network, String address) {
    BillingForAddress result = BillingForAddress();
    result.address = address;
    if (entries.containsKey(address)) {
      result = entries[address]!;
    } else {
      entries[address] = result;
    }
    result.update(network);
    return result;
  }

  BillingSummary getSummaryForAddresses(
      XchgNetwork? network, String clientAddress, String serverAddress) {
    BillingSummary result = BillingSummary();
    BillingForAddress billingForClient = get(network, clientAddress);
    BillingForAddress billingForServer = get(network, serverAddress);
    for (var bi in billingForClient.billingInfoFromRouters.values) {
      result.limit += bi.limit;
      result.counter += bi.counter;
    }
    for (var bi in billingForServer.billingInfoFromRouters.values) {
      result.limit += bi.limit;
      result.counter += bi.counter;
    }
    result.clientAddress = clientAddress;
    result.serverAddress = serverAddress;
    return result;
  }
}
