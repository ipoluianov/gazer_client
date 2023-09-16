import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';

import '../../../xchg/billing_for_address.dart';
import 'billing_form_item.dart';

class BillingForm extends StatefulWidget {
  final BillingFormArgument arg;
  const BillingForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BillingFormSt();
  }
}

class BillingFormSt extends State<BillingForm> {
  @override
  void initState() {
    super.initState();
    _timerTick = Timer.periodic(const Duration(milliseconds: 500), (t) {
      updateItems();
    });
  }

  @override
  void dispose() {
    _timerTick.cancel();
    super.dispose();
  }

  late Timer _timerTick;

  List<BillingFromRouter> items = [];

  void updateItems() {
    List<BillingFromRouter> loadedItems = [];
    var billingDB = Repository().client(widget.arg.connection).billingDB();
    for (var q in billingDB.entries.values) {
      for (var w in q.billingInfoFromRouters.values) {
        loadedItems.add(w);
      }
    }

    setState(() {
      items = loadedItems;
    });
  }

  Widget buildAddressBlock(
      String address, String name, String buttonText, Color buttonColor) {
    var usingLocalRouter =
        Repository().client(widget.arg.connection).usingLocalRouter();
    var billingDB = Repository().client(widget.arg.connection).billingDB();
    List<BillingFromRouter> loadedItems = [];
    var isPremium = false;
    for (var q in billingDB.entries.values) {
      for (var w in q.billingInfoFromRouters.values) {
        if (w.address == address) {
          loadedItems.add(w);
          if (w.limit >= 1000000000) {
            isPremium = true;
          }
        }
      }
    }
    loadedItems.sort((i, j) {
      return i.router.compareTo(j.router);
    });
    return BillingFormItem(address, loadedItems, name, usingLocalRouter,
        isPremium, buttonText, buttonColor);
  }

  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    List<Widget> innerWidgets = [];

    innerWidgets.add(
      buildAddressBlock(
        Repository().client(widget.arg.connection).address,
        "REMOTE NODE",
        "Buy PREMIUM",
        Colors.green,
      ),
    );
    innerWidgets.add(
      buildAddressBlock(
        Repository().client(widget.arg.connection).localAddress(),
        "This Client",
        "buy premium\r\nfor THIS CLIENT",
        Colors.blue,
      ),
    );

    Widget innerWidget = Container(
      padding: const EdgeInsets.only(top: 50),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: innerWidgets,
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        bool narrow = constraints.maxWidth < constraints.maxHeight;
        bool showLeft = !narrow;
        bool showBottom = narrow;

        return Scaffold(
          appBar: TitleBar(
            widget.arg.connection,
            "PREMIUM",
            actions: <Widget>[
              buildHomeButton(context),
            ],
          ),
          body: Container(
            color: DesignColors.mainBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LeftNavigator(showLeft),
                      Expanded(
                        child: innerWidget,
                      ),
                    ],
                  ),
                ),
                BottomNavigator(showBottom),
              ],
            ),
          ),
        );
      },
    );
  }
}
