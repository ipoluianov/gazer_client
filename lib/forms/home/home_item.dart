import 'package:flutter/material.dart';

import '../../core/design.dart';
import '../../core/navigation/route_generator.dart';
import '../../widgets/confirmation_dialog/confirmation_dialog.dart';
import 'home_config.dart';

abstract class HomeItem extends StatefulWidget {
  final HomeFormArgument arg;
  final HomeConfigItem config;
  final Function(HomeConfigItem item) onEdit;
  final Function(HomeConfigItem item) onRemove;
  final Function(HomeConfigItem item) onUp;
  final Function(HomeConfigItem item) onDown;
  HomeItem(
    this.arg,
    this.config,
    this.onEdit,
    this.onRemove,
    this.onUp,
    this.onDown, {
    super.key,
  });

  Widget buildH1(BuildContext context, String text, bool showMenu,
      bool showConfig, bool showRemove) {
    List<Widget> ws = [];
    ws.add(
      Container(
        constraints: const BoxConstraints(minHeight: 6),
        color: Colors.transparent,
      ),
    );

    List<PopupMenuEntry<String>> actions = [];

    if (showConfig) {
      actions.add(PopupMenuItem<String>(
        value: "change",
        child: Row(
          children: const [
            Padding(
                padding: EdgeInsets.only(right: 10), child: Icon(Icons.edit)),
            Text("Change Item")
          ],
        ),
      ));
      actions.add(PopupMenuDivider());
    }

    if (showRemove) {
      actions.add(PopupMenuItem<String>(
        value: "remove",
        child: Row(
          children: const [
            Padding(
                padding: EdgeInsets.only(right: 10), child: Icon(Icons.delete)),
            Text("Remove Item")
          ],
        ),
      ));
    }

    actions.add(PopupMenuDivider());

    actions.add(PopupMenuItem<String>(
      value: "up",
      child: Row(
        children: const [
          Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.arrow_upward)),
          Text("Move Up")
        ],
      ),
    ));

    actions.add(PopupMenuItem<String>(
      value: "down",
      child: Row(
        children: const [
          Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.arrow_downward)),
          Text("Move Down")
        ],
      ),
    ));

    var popupMenuButton = PopupMenuButton(
      color: DesignColors.back(),
      shadowColor: DesignColors.fore(),
      elevation: 20,
      onSelected: (str) {
        if (str == "remove") {
          showConfirmationDialog(context, "Confirmation", "Remove Item?", () {
            onRemove(config);
          });
        }

        if (str == "change") {
          onEdit(config);
        }

        if (str == "up") {
          onUp(config);
        }

        if (str == "down") {
          onDown(config);
        }
      },
      itemBuilder: (context) {
        return actions;
      },
      icon: Icon(
        Icons.menu,
        color: DesignColors.fore(),
      ),
    );

    ws.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 24, fontFamily: "RobotoMono"),
            ),
          ),
          Row(
            children: [showMenu ? popupMenuButton : Container()],
          ),
        ],
      ),
    );

    ws.add(
      Container(
        constraints: const BoxConstraints(minHeight: 1),
        color: DesignColors.fore1(),
      ),
    );

    ws.add(Container(
      height: 6,
    ));

    return Container(
      margin: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ws,
      ),
    );
  }
}
