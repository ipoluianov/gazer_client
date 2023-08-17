import 'dart:convert';
import 'dart:math';

import 'package:gazer_client/xchg/network_container.dart';

import 'network.dart';

class BillingFromRouter {
  String address = "";
  String router = "";
  DateTime dt = DateTime(0);

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
  double percents = 0;
  bool usingLocalRouter = false;
  bool isPremium = false;
}

class BillingForAddress {
  String address = "";
  Map<String, BillingFromRouter> billingInfoFromRouters = {};
  DateTime latestRequest = DateTime(0);
  void update(XchgNetwork? network) {
    if (network == null) {
      return;
    }
    if (DateTime.now().difference(latestRequest) < const Duration(seconds: 5)) {
      return;
    }
    latestRequest = DateTime.now();
    var routers = network.getNodesAddressesByAddress(address);
    for (var router in routers) {
      httpGet("http://$router/api/billing?addr=${address.replaceAll("#", "")}",
              1000)
          .then((value) {
        //print(value);

        var jsonObject = jsonDecode(value);
        var billingObject = BillingFromRouter.fromJson(jsonObject);
        billingObject.router = router;
        billingObject.address = address;
        billingObject.dt = DateTime.now();
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

  void clear() {
    for (var entry in entries.entries) {
      List<String> routersToRemove = [];
      for (var billingFromRouter
          in entry.value.billingInfoFromRouters.entries) {
        if (DateTime.now().difference(billingFromRouter.value.dt) >
            const Duration(seconds: 60)) {
          routersToRemove.add(billingFromRouter.key);
        }
      }
      for (String routerToRemove in routersToRemove) {
        entry.value.billingInfoFromRouters.remove(routerToRemove);
      }
    }
  }

  BillingSummary getSummaryForAddresses(XchgNetwork? network,
      String clientAddress, String serverAddress, bool usingLocalRouter) {
    clear();
    BillingSummary result = BillingSummary();

    if (usingLocalRouter) {
      result.clientAddress = clientAddress;
      result.serverAddress = serverAddress;
      result.limit = 1000000000;
      result.counter = 0;
      result.percents = 0;
      result.usingLocalRouter = true;
      result.isPremium = false;
      return result;
    }

    BillingForAddress billingForClient = get(network, clientAddress);
    BillingForAddress billingForServer = get(network, serverAddress);

    double percentsClient = 2;
    bool premiumDetected = false;
    for (var bi in billingForClient.billingInfoFromRouters.values) {
      double p = 0;
      if (bi.limit > 0) {
        if (bi.limit == 1000000000) {
          premiumDetected = true;
        }
        p = bi.counter.toDouble() / bi.limit.toDouble();
        if (p < percentsClient) {
          percentsClient = p;
        }
      }
    }
    double percentsServer = 2;
    for (var bi in billingForServer.billingInfoFromRouters.values) {
      double p = 0;
      if (bi.limit > 0) {
        if (bi.limit == 1000000000) {
          premiumDetected = true;
        }
        p = bi.counter.toDouble() / bi.limit.toDouble();
        if (p < percentsServer) {
          percentsServer = p;
        }
      }
    }

    if (percentsClient > 1) {
      percentsClient = -1;
    }

    if (percentsServer > 1) {
      percentsServer = -1;
    }

    double percents = max(percentsClient, percentsServer);
    result.clientAddress = clientAddress;
    result.serverAddress = serverAddress;
    result.percents = percents * 100;
    //result.usingLocalRouter = false;
    result.isPremium = premiumDetected;
    return result;
  }
}
