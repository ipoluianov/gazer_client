import 'package:flutter/material.dart';

import '../../forms/maps/map_form/main/map_view.dart';

Widget buildContentMapArea(BuildContext context, MapView settings) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double width = constraints.maxWidth;

      double mapWidth = settings.instance.getDouble("w");
      double mapHeight = settings.instance.getDouble("h");
      if (mapWidth < 1 || mapHeight < 1) {
        return Container();
      }
      double mapWidthHeightK = mapHeight / mapWidth;
      double height = width * mapWidthHeightK;

      return Listener(
        onPointerHover: (event) {
          settings.onHover(event.localPosition);
        },
        child: MouseRegion(
          cursor: () {
            if (settings.hoverItem != null) {
              if (settings.hoverItem!.hasAction()) {
                return SystemMouseCursors.click;
              }
            }
            return SystemMouseCursors.basic;
          }(),
          child: GestureDetector(
            onTapDown: (details) {
              settings.tapDown(details.localPosition, context);
            },
            child: CustomPaint(
              painter: MapPainter(settings),
              key: UniqueKey(),
              child: Container(
                height: height,
              ),
            ),
          ),
        ),
      );
    },
  );
}
