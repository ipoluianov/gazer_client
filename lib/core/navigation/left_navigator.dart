import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/widgets/borders/border_01_item.dart';
import 'package:gazer_client/widgets/borders/border_05_left_navigator.dart';
import 'package:gazer_client/widgets/borders/border_09_left_navigator_main.dart';

import 'left_navigator_button.dart';
import 'resources_form_arguments_factory.dart';
import 'route_generator.dart';
import 'navigation.dart';

class LeftNavigator extends StatelessWidget {
  final bool show;
  const LeftNavigator(this.show, {Key? key}) : super(key: key);

  Widget buildLeftBarButton(
      context, int index, String text, IconData iconData, Function()? onPress) {
    return LeftNavigatorButton(
        index,
        text,
        iconData,
        onPress,
        navColorForLeftMenuItem(context, index),
        navIsCurrentForLeftMenuItem(context, index));
  }

  Widget buildLeftBar(context) {
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
      width: 120,
      decoration: BoxDecoration(
          //color: Colors.black12,
          ),
      child: Stack(
        children: [
          Border09Painter.build(false),
          Container(
            padding: EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                showUnits
                    ? buildLeftBarButton(context, 0, "Units", Icons.blur_on,
                        () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, "/node",
                            arguments: NodeFormArgument(
                                Repository().lastSelectedConnection));
                      })
                    : Container(),
                showCharts
                    ? buildLeftBarButton(
                        context, 1, "Charts", Icons.stacked_line_chart, () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        Navigator.of(context).pop();
                        Navigator.pushNamed(
                          context,
                          "/chart_groups",
                          arguments: buildResourcesFormArgumentCharts(),
                        );
                      })
                    : Container(),
                showMaps
                    ? buildLeftBarButton(context, 2, "Maps", Icons.layers, () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        Navigator.of(context).pop();
                        Navigator.pushNamed(
                          context,
                          "/maps",
                          arguments: buildResourcesFormArgumentMaps(),
                        );
                      })
                    : Container(),
                showMore
                    ? buildLeftBarButton(context, 3, "More", Icons.more_horiz,
                        () {
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, "/more",
                            arguments: MoreFormArgument(
                                Repository().lastSelectedConnection));
                      })
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!show) {
      return Container();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return buildLeftBar(context);
      },
    );
  }
}
