import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/core/version.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:gazer_client/widgets/title_widget/title_widget.dart';
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool narrow = constraints.maxWidth < constraints.maxHeight;
        bool showLeft = !narrow;
        bool showBottom = narrow;

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
                            const Text(
                              "Gazer Client",
                              style: TextStyle(fontSize: 24),
                            ),
                            Text(
                              clientVersion,
                              style: const TextStyle(fontSize: 16),
                            ),
                            Text(
                              "Copyright (c ) Poluianov Ivan, 2021-${DateTime.now().year}",
                              style: const TextStyle(fontSize: 16),
                            ),
                            InkWell(
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  child: const Text(
                                    'Gazer.Cloud',
                                    style: TextStyle(color: Colors.blueAccent, decoration: TextDecoration.underline),
                                  ),
                                ),
                                onTap: () {
                                  launch('https://gazer.cloud/');
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
