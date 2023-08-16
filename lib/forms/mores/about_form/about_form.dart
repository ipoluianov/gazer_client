import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutForm extends StatefulWidget {
  final AboutFormArgument arg;
  const AboutForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AboutFormSt();
  }
}

class AboutFormSt extends State<AboutForm> {
  @override
  void initState() {
    super.initState();
  }

  PackageInfo? packageInfo;

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

        return Scaffold(
          appBar: TitleBar(
            widget.arg.connection,
            "About",
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
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: const Image(
                                image: AssetImage(
                                    'assets/images/ios/Icon-App-40x40@1x.png'),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: const Text(
                                "Gazer Client",
                                style: TextStyle(fontSize: 24),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "v$version",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                "Copyright (c ) Poluianov Ivan, 2021-${DateTime.now().year}",
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            InkWell(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  child: const Text(
                                    'Gazer.Cloud',
                                    style: TextStyle(
                                        color: Colors.blueAccent,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                                onTap: () {
                                  var url = Uri.parse("https://gazer.cloud/");
                                  launchUrl(url);
                                }),
                            InkWell(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  child: const Text(
                                    'Source Code',
                                    style: TextStyle(
                                        color: Colors.blueAccent,
                                        decoration: TextDecoration.underline),
                                  ),
                                ),
                                onTap: () {
                                  var url = Uri.parse(
                                      "https://github.com/ipoluianov/gazer_client");
                                  launchUrl(url);
                                }),
                          ],
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
}
