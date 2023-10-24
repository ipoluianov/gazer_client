import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/forms/maps/map_form/main/map_item_library.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';

import '../../../widgets/filter_button/filter_button.dart';
import '../../../widgets/title_bar/title_bar.dart';
import 'map_item_card.dart';

class MapItemAddForm extends StatefulWidget {
  final MapItemAddFormArgument arg;
  const MapItemAddForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemAddFormSt();
  }
}

class MapItemAddFormResult {
  String type;
  String parameter;
  MapItemAddFormResult(this.type, this.parameter);
}

class MapItemAddFormItem {
  String id;
  String name;
  String type;
  String category;
  ImageProvider? thumbnail;
  Set<String> tags = {};
  MapItemAddFormItem(
      this.id, this.name, this.type, this.category, this.thumbnail,
      {this.tags = const {}});
}

class MapItemAddFormSt extends State<MapItemAddForm> {
  @override
  void initState() {
    super.initState();
    load();
  }

  final ScrollController _scrollController = ScrollController();

  bool loaded = false;
  List<MapItemAddFormItem> items = [];
  String filter = "";

  void load() {
    loaded = false;

    items = [];
    var internalMapItemTypes = MapItemsLibrary().internalMapItemTypes();
    for (var i in internalMapItemTypes) {
      if (i.type == "map") {
        continue;
      }

      if (filter != "") {
        if (filter != i.category) {
          continue;
        }
      }

      var mapItem =
          MapItemsLibrary().makeItemByType(i.type, widget.arg.connection);
      //var rr = mapItem.zoom;
      var mapItemType =
          MapItemAddFormItem(i.id, i.name, i.type, i.category, null);
      items.add(mapItemType);
      mapItem.drawToImage(60, true).then((value) {
        setState(() {
          mapItemType.thumbnail = Image.memory(value).image;
        });
      });
    }

    if (filter == "external") {
      Repository()
          .client(widget.arg.connection)
          .resList("map", "", 0, 10000)
          .then((value) {
        setState(() {
          for (var i in value.item.items) {
            //var thumbnail = Image.memory(i.thumbnail);
            items.add(MapItemAddFormItem(
                i.id, i.getProp("name"), i.type, "external", null));
          }
        });
      });
    }
    loaded = true;
  }

  Widget buildContent(BuildContext context) {
    if (!loaded) {
      return Text("loading ...");
    }
    return Expanded(
      child: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Container(
            padding: const EdgeInsets.all(6),
            child: Wrap(
              children: items.map<Widget>(
                (e) {
                  return MapItemCard(widget.arg.connection, e, () {
                    Navigator.of(context)
                        .pop(MapItemAddFormResult(e.type, e.id));
                  });
                },
              ).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildFilterButtonFull(
      context, IconData icon, String tooltip, Function() onPress, bool checked,
      {Color? imageColor, Color? backColor, key}) {
    return FilterButton(
        icon: icon,
        tooltip: tooltip,
        onPress: onPress,
        checked: checked,
        imageColor: imageColor,
        backColor: backColor,
        key: key);
  }

  Widget buildToolbar(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        List<Widget> buttons = [];
        buttons.add(buildFilterButtonFull(context, Icons.apps, "All", () {
          if (mounted) {
            setState(() {
              filter = "";
            });
            load();
          }
        }, false,
            imageColor:
                (filter == "") ? DesignColors.accent() : DesignColors.fore2()));

        buttons.add(buildFilterButtonFull(context, Icons.text_fields, "Text",
            () {
          if (mounted) {
            setState(() {
              filter = "text";
            });
            load();
          }
        }, false,
            imageColor: (filter == "text")
                ? DesignColors.accent()
                : DesignColors.fore2()));

        buttons.add(buildFilterButtonFull(context, Icons.speed, "Gauges", () {
          if (mounted) {
            setState(() {
              filter = "gauge";
            });
            load();
          }
        }, false,
            imageColor: (filter == "gauge")
                ? DesignColors.accent()
                : DesignColors.fore2()));

        buttons.add(buildFilterButtonFull(context, Icons.show_chart, "Charts",
            () {
          if (mounted) {
            setState(() {
              filter = "chart";
            });
            load();
          }
        }, false,
            imageColor: (filter == "chart")
                ? DesignColors.accent()
                : DesignColors.fore2()));

        buttons.add(buildFilterButtonFull(context, Icons.stars, "Decorations",
            () {
          if (mounted) {
            setState(() {
              filter = "decoration";
            });
            load();
          }
        }, false,
            imageColor: (filter == "decoration")
                ? DesignColors.accent()
                : DesignColors.fore2()));

        buttons.add(buildFilterButtonFull(context, Icons.layers, "External",
            () {
          if (mounted) {
            setState(() {
              filter = "external";
            });
            load();
          }
        }, false,
            imageColor: (filter == "external")
                ? DesignColors.accent()
                : DesignColors.fore2()));

        int countOfButtons = ((constraints.maxWidth - 200) / 65).round();
        if (countOfButtons < 1) {
          countOfButtons = 1;
        }
        if (countOfButtons > buttons.length) {
          countOfButtons = buttons.length;
        }
        var leftButtons = buttons.getRange(0, countOfButtons).toList();
        List<Widget> rightButtons = [];
        leftButtons.add(Expanded(child: Container()));
        leftButtons.addAll(rightButtons);
        return Row(
          children: leftButtons,
        );
      },
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
          appBar: TitleBar(
            widget.arg.connection,
            "Add item",
            actions: [
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            buildToolbar(context),
                            buildContent(context),
                          ],
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
