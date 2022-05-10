import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_decorations/map_item_decoration.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';

import 'map_item_decoration_card.dart';

class MapItemDecorationAddForm extends StatefulWidget {
  final MapItemDecorationAddFormArgument arg;
  const MapItemDecorationAddForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemDecorationAddFormSt();
  }
}

class MapItemDecorationAddFormResult {
  String type;
  String parameter;
  MapItemDecorationAddFormResult(this.type, this.parameter);
}

class MapItemDecorationAddFormSt extends State<MapItemDecorationAddForm> {
  @override
  void initState() {
    super.initState();
    load();
  }

  bool loaded = true;
  List<MapItemDecorationType> items = [];

  void load() {
    items = [];
    var internalMapItemTypes = MapItemDecoration.types();
    for (var i in internalMapItemTypes) {
      items.add(i);
    }
  }

  Widget buildContent(BuildContext context) {
    if (!loaded) {
      return Text("loading ...");
    }
    return Expanded(
      child: Scrollbar(
        isAlwaysShown: true,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(6),
            child: Wrap(
              children: items.map<Widget>(
                    (e) {
                  return MapItemDecorationCard(widget.arg.connection, e, () {
                    Navigator.of(context).pop(MapItemDecorationAddFormResult(e.type, ""));
                  });
                },
              ).toList(),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool narrow = constraints.maxWidth < constraints.maxHeight;
        bool showLeft = !narrow;
        bool showBottom = narrow;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Add Map Item Decoration"),
            actions: [
              buildHomeButton(context),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    LeftNavigator(showLeft),
                    buildContent(context),
                  ],
                ),
              ),
              BottomNavigator(showBottom),
            ],
          ),
        );
      },
    );
  }
}
