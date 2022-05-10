import 'package:flutter/material.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/maps/map_form/map_item.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_decorations/map_item_decoration.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_decorations/map_item_decoration_set.dart';
import 'package:gazer_client/forms/maps/map_item_decoration_add_form/map_item_decoration_add_form.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/styles.dart';

import '../../../core/navigation/route_generator.dart';
import 'map_item_group_of_properties.dart';

class MapItemPropDecorations extends StatefulWidget {
  final IPropContainer item;
  final MapItemPropItem propItem;

  const MapItemPropDecorations(this.item, this.propItem, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemPropDecorationsSt();
  }
}

class MapItemPropDecorationsSt extends State<MapItemPropDecorations> {
  @override
  void initState() {
    super.initState();
  }

  Widget buildDecorationItem(BuildContext context, MapItemDecoration itemDecoration, int index) {
    var propList = itemDecoration.propList();
    List<MapItemPropGroup> groups = [];
    List<Widget> groupsWidgets = [];

    var itemTypeName = itemDecoration.get("type");
    for (var type in MapItemDecoration.types()) {
      if (type.type == itemDecoration.get("type")) {
        itemTypeName = type.name;
      }
    }
    groupsWidgets.add(
      Container(
        color: Colors.green.withOpacity(0.6),
        padding: EdgeInsets.all(6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              itemTypeName,
            ),
            Expanded(child: Container()),
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                onPressed: () {
                  widget.item.getDecorations().moveDown(index);
                },
                icon: const Icon(Icons.arrow_downward),
              ),
            ),
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                onPressed: () {
                  widget.item.getDecorations().moveUp(index);
                },
                icon: const Icon(Icons.arrow_upward),
              ),
            ),
            SizedBox(
              width: 32,
              height: 32,
              child: IconButton(
                onPressed: () {
                  widget.item.getDecorations().items.removeAt(index);
                },
                icon: const Icon(Icons.delete),
              ),
            ),
          ],
        ),
      ),
    );

    for (var propPage in propList) {
      for (var propGroup in propPage.groups) {
        groups.add(propGroup);
        groupsWidgets.add(MapItemGroupOfProperties(itemDecoration, propGroup));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: groupsWidgets,
    );
  }

  Widget buildList(BuildContext context) {
    List<Widget> resultItems = [];

    resultItems.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(padding: EdgeInsets.all(6), child: Ink(
              decoration: const ShapeDecoration(color: Colors.green, shape: CircleBorder()),
              child: Padding(padding: EdgeInsets.all(6), child: IconButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed("/map_item_decoration_add", arguments: MapItemDecorationAddFormArgument(widget.item.getConnection()))
                      .then((value) {
                    if (value is MapItemDecorationAddFormResult) {
                      MapItemDecoration item = MapItemDecoration.makeByType(value.type);
                      item.initDefaultProperties();
                      widget.item.getDecorations().items.add(item);
                    }
                  });
                },
                icon: const Icon(Icons.add),
                tooltip: "Add decoration",
                color: Colors.green,
              ),),),),
        ],
      ),
    );

    var itemIndex = 0;
    for (var decoration in widget.item.getDecorations().items) {
      resultItems.add(buildDecorationItem(context, decoration, itemIndex));
      itemIndex++;
    }

    return Expanded(
      child: Column(
        children: resultItems,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        buildList(context),
      ],
    );
  }
}
