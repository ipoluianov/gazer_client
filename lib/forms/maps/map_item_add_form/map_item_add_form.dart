import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_library.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';

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
  ImageProvider? thumbnail;
  Set<String> tags = {};
  MapItemAddFormItem(this.id, this.name, this.type, this.thumbnail,
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

  void load() {
    loaded = false;

    items = [];
    var internalMapItemTypes = MapItemsLibrary().internalMapItemTypes();
    for (var i in internalMapItemTypes) {
      var mapItem =
          MapItemsLibrary().makeItemByType(i.type, widget.arg.connection);
      var rr = mapItem.zoom;
      var mapItemType = MapItemAddFormItem(i.id, i.name, i.type, null);
      items.add(mapItemType);
      mapItem.drawToImage(60, true).then((value) {
        setState(() {
          mapItemType.thumbnail = Image.memory(value).image;
        });
      });
    }

    Repository()
        .client(widget.arg.connection)
        .resList("map", "", 0, 10000)
        .then((value) {
      setState(() {
        for (var i in value.item.items) {
          //var thumbnail = Image.memory(i.thumbnail);
          items.add(MapItemAddFormItem(i.id, i.getProp("name"), i.type, null));
        }

        loaded = true;
      });
    });
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool narrow = constraints.maxWidth < constraints.maxHeight;
        bool showLeft = !narrow;
        bool showBottom = narrow;

        return Scaffold(
          appBar: AppBar(
            title: const Text("Add Map Item"),
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
