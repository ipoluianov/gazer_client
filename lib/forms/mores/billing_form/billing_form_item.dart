import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/design.dart';
import '../../../widgets/borders/border_01_item.dart';
import '../../../xchg/billing_for_address.dart';

class BillingFormItem extends StatefulWidget {
  final String address;
  final List<BillingFromRouter> items;
  final String displayName;
  final bool usingLocalRouter;
  final bool isPremium;
  const BillingFormItem(this.address, this.items, this.displayName,
      this.usingLocalRouter, this.isPremium,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BillingFormItemState();
  }
}

class BillingFormItemState extends State<BillingFormItem>
    with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return buildUnit();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildUnit() {
    double iconSize = 72;

    Widget iconLocal = Container(
      padding: const EdgeInsets.only(right: 20),
      child: Icon(
        Icons.radar,
        size: iconSize,
        color: widget.usingLocalRouter ? Colors.green : Colors.white10,
      ),
    );

    Widget iconPremium = Container(
      padding: const EdgeInsets.only(right: 20),
      child: Icon(
        Icons.auto_awesome,
        size: iconSize,
        color: widget.isPremium ? Colors.green : Colors.white10,
      ),
    );

    Color logColor = Colors.green;
    List<String> log = [];
    if (widget.usingLocalRouter) {
      log.add("Using Local Router");
    }
    if (widget.isPremium) {
      log.add("Premium Level Is Detected");
    }

    if (!widget.usingLocalRouter && !widget.isPremium) {
      log.add("Limited");
      logColor = Colors.deepOrange;
    }

    String addressForRequest = widget.address.replaceAll("#", "");

    Widget buyPremiumButton = ElevatedButton(
      onPressed: () {
        var url = Uri.parse(
            "https://gazer.cloud/action/buy-premium/?addr=$addressForRequest");
        launchUrl(url);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green,
      ),
      child: const Padding(
        padding: EdgeInsets.all(10),
        child: Text(
          "Buy PREMIUM",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: "RobotoMono",
          ),
        ),
      ),
    );

    if (widget.isPremium) {
      buyPremiumButton = const Padding(
        padding: EdgeInsets.all(10),
        child: Text(
          "",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontFamily: "RobotoMono",
          ),
        ),
      );
    }

    return Container(
      // color: Colors.black26,
      child: Container(
        padding: const EdgeInsets.all(10),
        width: 480,
        height: 360,
        child: Stack(
          children: [
            Border01Painter.build(false),
            Column(
              //mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    widget.address,
                    overflow: TextOverflow.fade,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: DesignColors.fore()),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      children: widget.items.map((e) {
                        return Text("${e.router} = ${e.counter} / ${e.limit}",
                            style: const TextStyle(color: Colors.grey));
                      }).toList(),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      iconPremium,
                      iconLocal,
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: log.map((e) {
                      return Text(
                        e,
                        style: TextStyle(color: logColor, fontSize: 16),
                      );
                    }).toList(),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    widget.displayName,
                    style: TextStyle(
                      color: DesignColors.fore(),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: buyPremiumButton,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
