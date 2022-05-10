import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/widgets/action_button/action_button.dart';
import 'package:gazer_client/widgets/borders/border_01_item.dart';
import 'package:gazer_client/widgets/borders/border_02_titlebar.dart';
import 'package:gazer_client/widgets/borders/border_03_item_details.dart';
import 'package:gazer_client/widgets/borders/border_04_action_button.dart';

import '../design.dart';
import 'route_generator.dart';

Color navColorForLeftMenuItem(context, int index) {
  if (index == navCurrentIndex(context)) {
    return DesignColors.accent();
  }
  return DesignColors.fore();
}

Color navBackcolorForLeftMenuItem(context, int index) {
  if (index == navCurrentIndex(context)) {
    return Colors.black26;
  }
  return Colors.transparent;
}

bool navIsCurrentForLeftMenuItem(context, int index) {
  if (index == navCurrentIndex(context)) {
    return true;
  }
  return false;
}

int navCurrentIndex(context) {
  switch (Repository().navIndex) {
    case NavIndex.units:
      return 0;
    case NavIndex.charts:
      return 1;
    case NavIndex.maps:
      return 2;
    case NavIndex.more:
      return 3;
  }
}

String navCurrentPath(context) {
  var path = Repository().lastPath;
  var r = ModalRoute.of(context);
  if (r != null) {
    if (r.settings.name != null) {
      path = r.settings.name!;
    }
  }
  return path;
}

Widget buildActionButton(context, IconData icon, String tooltip, Function() onPress, {key}) {
  return buildActionButtonFull(context, icon, tooltip, onPress, false, key: key);
}

Widget buildActionButtonFull(context, IconData icon, String tooltip, Function() onPress, bool checked, {Color? imageColor, Color? backColor, key}) {
  return ActionButton(
    icon: icon,
    tooltip: tooltip,
    onPress: onPress,
    checked: checked,
    imageColor: imageColor,
    backColor: backColor,
    key: key
  );
}

Widget buildHomeButton(context) {
  return Container(
      padding: const EdgeInsets.only(left: 5),
      child: buildActionButton(context, Icons.list_alt, "All Nodes", () {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.popAndPushNamed(context, "/", arguments: MainFormArgument());
      }));
}
