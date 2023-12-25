import 'package:flutter/material.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/widgets/borders/border_01_item.dart';
import 'package:gazer_client/widgets/borders/border_03_item_details.dart';

import '../design.dart';
import 'resources_form_arguments_factory.dart';
import 'route_generator.dart';

class BottomNavigator extends StatelessWidget {
  final bool show;
  const BottomNavigator(this.show, {Key? key}) : super(key: key);

  Widget buildBottomBarButton(
      context, int index, String text, IconData iconData, Function()? onPress) {
    return Expanded(
      child: Container(
        height: 60,
        padding: const EdgeInsets.all(3),
        child: GestureDetector(
          onTap: onPress,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: Stack(
              children: [
                SizedBox(
                  //width: 60,
                  height: 90,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        iconData,
                        size: 24,
                        color: navColorForLeftMenuItem(context, index),
                      ),
                      Text(
                        text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: navColorForLeftMenuItem(context, index),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBottomBar(context) {
    bool showHome = true;
    bool showUnits = true;
    bool showCharts = true;
    bool showMaps = true;
    bool showMore = true;

    switch (navCurrentPath(context)) {
      case "/":
        showHome = false;
        showUnits = false;
        showCharts = false;
        showMaps = false;
        showMore = false;
        break;
    }

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black12,
          border: Border(
            top: BorderSide(
              color: DesignColors.fore2(),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            showHome
                ? buildBottomBarButton(context, 0, "Home", Icons.apps, () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, "/home",
                        arguments: HomeFormArgument(
                            Repository().lastSelectedConnection));
                  })
                : Container(),
            showUnits
                ? buildBottomBarButton(context, 1, "Units", Icons.blur_on, () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, "/node",
                        arguments: NodeFormArgument(
                            Repository().lastSelectedConnection));
                  })
                : Container(),
            showCharts
                ? buildBottomBarButton(
                    context, 2, "Charts", Icons.stacked_line_chart, () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.of(context).pop();
                    Navigator.pushNamed(
                      context,
                      "/chart_groups",
                      arguments: buildResourcesFormArgumentCharts(),
                    );
                  })
                : Container(),
            showMaps
                ? buildBottomBarButton(context, 3, "Maps", Icons.layers, () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.of(context).pop();
                    Navigator.pushNamed(
                      context,
                      "/maps",
                      arguments: buildResourcesFormArgumentMaps(),
                    );
                  })
                : Container(),
            showMore
                ? buildBottomBarButton(context, 4, "More", Icons.more_horiz,
                    () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, "/more",
                        arguments: MoreFormArgument(
                            Repository().lastSelectedConnection));
                  })
                : Container(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
    }
    return buildBottomBar(context);
  }
}
