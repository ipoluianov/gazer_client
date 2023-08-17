import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/protocol/service/service_info.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/widgets/borders/border_02_titlebar.dart';
import 'package:gazer_client/xchg/billing_for_address.dart';

import '../../core/navigation/route_generator.dart';

class TitleBar extends StatefulWidget implements PreferredSizeWidget {
  final Connection? connection;
  final String title;
  final String version;
  final List<Widget>? actions;
  const TitleBar(this.connection, this.title,
      {Key? key, this.actions, this.version = ""})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TitleBarSt();
  }

  @override
  Size get preferredSize {
    return const Size(0, 62);
  }
}

class TitleBarSt extends State<TitleBar> {
  bool serviceInfoLoaded = false;
  late ServiceInfoResponse serviceInfo;

  @override
  void initState() {
    super.initState();
    loadNodeInfo();
    _timerTick = Timer.periodic(const Duration(milliseconds: 500), (t) {
      tick();
    });
  }

  @override
  void dispose() {
    _timerTick.cancel();
    super.dispose();
  }

  void loadNodeInfo() {
    if (widget.connection != null) {
      Repository().client(widget.connection!).serviceInfo().then((value) {
        if (mounted) {
          setState(() {
            serviceInfo = value;
            serviceInfoLoaded = true;
          });
        }
      }).catchError((err) {});
    }
  }

  String nodeAddress() {
    if (widget.connection == null) {
      return "-";
    }
    return widget.connection!.address;
  }

  String nodeName() {
    if (widget.connection == null) {
      return "-";
    }
    if (serviceInfoLoaded) {
      return serviceInfo.nodeName;
    }
    return "-"; //widget.connection!.address;
  }

  String titleLine() {
    if (widget.connection != null) {
      return "${nodeName()} - ${widget.title}";
    }
    return widget.title;
  }

  late Timer _timerTick;
  int tickCounter_ = 0;
  void tick() {
    if (widget.connection != null) {
      Repository().client(widget.connection!).refreshState();
      setState(() {
        tickCounter_++;
      });
    }
  }

  Widget billing() {
    BillingSummary billingInfo = BillingSummary();

    String text = "";
    Color color = Colors.grey.withOpacity(0.5);

    if (widget.connection != null) {
      billingInfo = Repository().client(widget.connection!).billingInfo();
      text = Repository().client(widget.connection!).linkInformation();
      if (billingInfo.isPremium) {
        text = "Premium Node";
        color = Colors.green;
      }

      if (billingInfo.usingLocalRouter) {
        text = "local connection";
        color = Colors.grey;
      }
    }

    if (text.isEmpty) {
      text = "Client Version: v${widget.version}";
    }

    return Text(
      text,
      style: TextStyle(color: color, fontSize: 10),
    );
  }

  List<Widget> getActions() {
    if (widget.actions == null) {
      return [];
    }
    return widget.actions!;
  }

  Widget buildBackButton() {
    if (Navigator.of(context).canPop()) {
      return buildActionButton(context, Icons.arrow_back_ios, "Back", () {
        Navigator.of(context).pop();
      });
    }
    return buildActionButton(context, null, "", () {});
  }

  Widget buildBillingButton() {
    BillingSummary billingInfo = BillingSummary();

    bool usingLocalRouter = false;
    if (widget.connection != null) {
      usingLocalRouter =
          Repository().client(widget.connection!).usingLocalRouter();
    }
    if (widget.connection != null) {
      billingInfo = Repository().client(widget.connection!).billingInfo();
    }

    bool isPremium = billingInfo.isPremium;

    // isPremium = true;

    double value = 0;
    value = billingInfo.percents;

    Color colorOfValue = Colors.green;

    // value = 80;

    if (value > 50) {
      colorOfValue = Colors.orangeAccent;
      if ((tickCounter_ % 2) == 0) {
        colorOfValue = Colors.yellow;
      }
    }

    if (value > 80) {
      colorOfValue = Colors.red;
      if ((tickCounter_ % 2) == 0) {
        colorOfValue = Colors.yellow;
      }
    }

    Widget innerWidget = CircularProgressIndicator(
      value: value / 100,
      color: colorOfValue,
      backgroundColor: Colors.grey,
    );
    Widget percentsText = Center(
      child: Text(
        "${(value).round()}%",
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 10),
      ),
    );

    if (usingLocalRouter) {
      innerWidget = const Center(
        child: Icon(
          Icons.radar,
          size: 32,
          color: Colors.green,
        ),
      );
      percentsText = Container();
    }

    if (widget.connection != null) {
      if (!Repository().client(widget.connection!).connected()) {
        innerWidget = const Center(
          child: Icon(
            Icons.error,
            size: 32,
            color: Colors.red,
          ),
        );
        percentsText = Container();
      }
    }

    if (isPremium) {
      innerWidget = const Center(
        child: Icon(
          Icons.auto_awesome,
          size: 32,
          color: Colors.green,
        ),
      );
      percentsText = Container();
    }

    if (widget.connection == null) {
      innerWidget = const Image(
          image: AssetImage('assets/images/ios/Icon-App-40x40@1x.png'));
      percentsText = Container();
    }

    return GestureDetector(
      onTap: () {
        if (widget.connection != null) {
          Navigator.pushNamed(context, "/billing",
              arguments: BillingFormArgument(widget.connection!));
        }
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Stack(
          children: [
            SizedBox(
              width: 52,
              height: 52,
              child: Center(
                child: SizedBox(
                  width: 32,
                  height: 32,
                  child: innerWidget,
                ),
              ),
            ),
            SizedBox(
              width: 52,
              height: 52,
              child: percentsText,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: DesignColors.mainBackgroundColor,
        child: Stack(
          children: [
            Border02Painter.build(false, DesignColors.fore2()),
            Container(
              padding: const EdgeInsets.only(left: 3, top: 3, right: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildBackButton(),
                  buildBillingButton(),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(top: 8, left: 12),
                      //color: Colors.yellow,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        //mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Container(
                              //color: Colors.cyan,
                              alignment: Alignment.bottomLeft,
                              child: Text(
                                titleLine(),
                                style: TextStyle(
                                    color: DesignColors.fore(),
                                    overflow: TextOverflow.ellipsis),
                                maxLines: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Container(
                              //color: Colors.cyan,
                              alignment: Alignment.topLeft,
                              child: billing(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: getActions(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
