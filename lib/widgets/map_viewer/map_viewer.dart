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

      return Container(
        child: CustomPaint(
          painter: MapPainter(settings),
          child: Container(
            height: height,
          ),
          key: UniqueKey(),
        ),
      );
    },
  );
}
