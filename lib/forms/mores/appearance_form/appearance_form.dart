import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/core/version.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:gazer_client/widgets/title_widget/title_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'appearance_item.dart';

class AppearanceForm extends StatefulWidget {
  final AppearanceFormArgument arg;
  const AppearanceForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AppearanceFormSt();
  }
}

class AppearanceFormSt extends State<AppearanceForm> {
  @override
  void initState() {
    super.initState();
  }

  void setPalette(String code) {
    DesignColors.setPalette(code);
  }

  final ScrollController _scrollController = ScrollController();

  void rebuildAllChildren(BuildContext context) {
    void rebuild(Element el) {
      el.markNeedsBuild();
      el.visitChildren(rebuild);
    }

    (context as Element).visitChildren(rebuild);
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
            "Appearance",
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
                          controller: _scrollController,
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Wrap(
                              children: [
                                AppearanceButton(() {
                                  setPalette("blue");
                                  setState(() {});
                                }, "blue", const Icon(Icons.contrast, size: 48),
                                    0),
                                AppearanceButton(() {
                                  setPalette("turquoise");
                                  setState(() {});
                                }, "turquoise",
                                    const Icon(Icons.contrast, size: 48), 0),
                                AppearanceButton(() {
                                  setPalette("green");
                                  setState(() {});
                                }, "green",
                                    const Icon(Icons.contrast, size: 48), 0),
                                AppearanceButton(() {
                                  setPalette("yellow");
                                  setState(() {});
                                }, "yellow",
                                    const Icon(Icons.contrast, size: 48), 0),
                                AppearanceButton(() {
                                  setPalette("white");
                                  setState(() {});
                                }, "white",
                                    const Icon(Icons.contrast, size: 48), 0),
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
}
