import 'package:flutter/material.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/widgets/borders/border_01_item.dart';
import 'package:gazer_client/widgets/borders/border_03_item_details.dart';

import '../design.dart';
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
    bool showUnits = true;
    bool showCharts = true;
    bool showMaps = true;
    bool showMore = true;

    switch (navCurrentPath(context)) {
      case "/":
        showUnits = false;
        showCharts = false;
        showMaps = false;
        showMore = false;
        break;
    }

    return Container(
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
          showUnits
              ? buildBottomBarButton(context, 0, "Units", Icons.blur_on, () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, "/node",
                      arguments: NodeFormArgument(
                          Repository().lastSelectedConnection));
                })
              : Container(),
          showCharts
              ? buildBottomBarButton(
                  context, 1, "Charts", Icons.stacked_line_chart, () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.of(context).pop();
                  Navigator.pushNamed(
                    context,
                    "/chart_groups",
                    arguments: ResourcesFormArgument(
                      Repository().lastSelectedConnection,
                      "chart_group",
                      "Chart Group",
                      "Chart Groups",
                      Icons.stacked_line_chart,
                      true,
                      false,
                      "",
                      "",
                      (context, res) {
                        Navigator.of(context)
                            .pushNamed(
                          "/chart_group",
                          arguments: ChartGroupFormArgument(
                            Repository().lastSelectedConnection,
                            res.id,
                          ),
                        )
                            .then((value) {
                          //load();
                        });
                      },
                      (context, res) {},
                    ),
                  );
                })
              : Container(),
          showMaps
              ? buildBottomBarButton(context, 2, "Maps", Icons.layers, () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.of(context).pop();
                  Navigator.pushNamed(
                    context,
                    "/maps",
                    arguments: ResourcesFormArgument(
                      Repository().lastSelectedConnection,
                      "map",
                      "Map",
                      "Maps",
                      Icons.layers,
                      true,
                      false,
                      "",
                      "",
                      (context, res) {
                        Navigator.of(context)
                            .pushNamed(
                          "/map",
                          arguments: MapFormArgument(
                            Repository().lastSelectedConnection,
                            res.id,
                            true,
                          ),
                        )
                            .then((value) {
                          //load();
                        });
                      },
                      (context, res) {},
                    ),
                  );
                })
              : Container(),
          showMore
              ? buildBottomBarButton(context, 3, "More", Icons.more_horiz, () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.of(context).pop();
                  Navigator.pushNamed(context, "/more",
                      arguments: MoreFormArgument(
                          Repository().lastSelectedConnection));
                })
              : Container(),
        ],
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
