import 'package:flutter/material.dart';

import '../repository.dart';
import 'route_generator.dart';

ResourcesFormArgument buildResourcesFormArgumentMaps() {
  return ResourcesFormArgument(
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
          false,
        ),
      )
          .then((value) {
        //load();
      });
    },
    (context, resId) {
      Navigator.of(context)
          .pushNamed(
        "/map",
        arguments: MapFormArgument(
          Repository().lastSelectedConnection,
          resId,
          true,
        ),
      )
          .then((value) {
        //load();
      });
    },
  );
}

ResourcesFormArgument buildResourcesFormArgumentCharts() {
  return ResourcesFormArgument(
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
          false,
        ),
      )
          .then((value) {
        //load();
      });
    },
    (context, res) {
      Navigator.of(context)
          .pushNamed(
        "/chart_group",
        arguments: ChartGroupFormArgument(
          Repository().lastSelectedConnection,
          res,
          true,
        ),
      )
          .then((value) {
        //load();
      });
    },
  );
}
