import 'dart:async';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/repository.dart';

class GuestAccessForm extends StatefulWidget {
  final GuestAccessFormArgument arg;
  const GuestAccessForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return GuestAccessFormSt();
  }
}

class GuestAccessFormSt extends State<GuestAccessForm> {
  @override
  void initState() {
    super.initState();
    _timerTick = Timer.periodic(const Duration(milliseconds: 50), (t) {
      tick();
    });
  }

  int tickCounter = 0;
  int tickCounterMax = 20;
  void tick() {
    if (tickCounter > tickCounterMax) {
      _timerTick.cancel();
      return;
    }
    setState(() {
      tickCounter++;
    });
  }

  @override
  void dispose() {
    _timerTick.cancel();
    super.dispose();
  }

  PackageInfo? packageInfo;
  late Timer _timerTick;
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool narrow = constraints.maxWidth < constraints.maxHeight;
        bool showLeft = !narrow;
        bool showBottom = narrow;

        String version = "";
        PackageInfo.fromPlatform().then((value) {
          setState(() {
            packageInfo = value;
          });
        }).catchError((err) {});

        if (packageInfo != null) {
          version = packageInfo!.version;
        }

        var serviceInfo =
            Repository().client(widget.arg.connection).lastServiceInfo;
        String sessionKey = "";
        if (serviceInfo != null) {
          sessionKey = serviceInfo.guestKey;
        }

        String accessData = "${widget.arg.connection.address}_$sessionKey";
        String qrData = accessData;

        Color qrColor = Colors.black;
        Color qrBackColor = Colors.white;

        if (tickCounter < tickCounterMax) {
          qrData = "";
          for (int i = 0; i < Random.secure().nextInt(50); i++) {
            qrData += sha256.convert([
              Random.secure().nextInt(1000000),
              Random.secure().nextInt(1000000)
            ]).toString();
          }
          qrColor = Colors.grey;
        }

        return Scaffold(
          appBar: TitleBar(
            widget.arg.connection,
            "Guest Access",
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
                        child: Scrollbar(
                          controller: scrollController,
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(children: [
                                    const Text(
                                      "Access Data - Address + AccessKey: ",
                                    ),
                                    Text(
                                      accessData,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.amber,
                                          fontFamily: "RobotoMono"),
                                    ),
                                    OutlinedButton(
                                        onPressed: () {
                                          Clipboard.setData(
                                              ClipboardData(text: accessData));
                                          _showInformation(
                                              "Access Data has been copied");
                                        },
                                        child: const Text("Copy"))
                                  ]),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: QrImage(
                                    data: qrData,
                                    version: QrVersions.auto,
                                    size: 320,
                                    backgroundColor: qrBackColor,
                                    foregroundColor: qrColor,
                                    gapless: false,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(children: [
                                    const Text("Address: "),
                                    Text(
                                      widget.arg.connection.address,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.green,
                                          fontFamily: "RobotoMono"),
                                    ),
                                    OutlinedButton(
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(
                                              text: widget
                                                  .arg.connection.address));
                                          _showInformation(
                                              "Address has been copied");
                                        },
                                        child: const Text("Copy"))
                                  ]),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(children: [
                                    const Text("Access Key: "),
                                    Text(
                                      sessionKey,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.green,
                                          fontFamily: "RobotoMono"),
                                    ),
                                    OutlinedButton(
                                        onPressed: () {
                                          Clipboard.setData(
                                              ClipboardData(text: sessionKey));
                                          _showInformation(
                                              "Access Key has been copied");
                                        },
                                        child: const Text("Copy"))
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ),
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

  Future<void> _showInformation(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(''),
          content: SingleChildScrollView(
            child: Text(msg),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
