import 'package:flutter/material.dart';
import 'package:gazer_client/forms/maps/map_form/map_item.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/map_item_prop_bool.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/map_item_prop_data_source.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/map_item_prop_orientation.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/map_item_prop_threshold.dart';
import 'package:expandable/expandable.dart';

import 'map_item_prop_actions.dart';
import 'map_item_prop_color.dart';
import 'map_item_prop_decorations.dart';
import 'map_item_prop_double.dart';
import 'map_item_prop_image.dart';
import 'map_item_prop_scale_fit.dart';
import 'map_item_prop_text.dart';

class MapItemGroupOfProperties extends StatefulWidget {
  final IPropContainer item;
  final MapItemPropGroup propGroup;

  const MapItemGroupOfProperties(this.item, this.propGroup, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemGroupOfPropertiesSt();
  }
}

class MapItemGroupOfPropertiesSt extends State<MapItemGroupOfProperties> {
  ExpandableController expandableController = ExpandableController();
  bool expanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.propGroup.expanded) {
      expanded = true;
    }
  }

  static Widget buildPropItem(IPropContainer item, MapItemPropItem propItem, Key key) {
    Widget propWidget = Text("unknown property type", key: key);

    bool isDecorations = false;

    if (propItem.type == "double") {
      propWidget = MapItemPropDouble(
        item,
        propItem,
        key: key,
      );
    }
    if (propItem.type == "text") {
      propWidget = MapItemPropText(item, propItem, key: key);
    }
    if (propItem.type == "data_source") {
      propWidget = MapItemPropDataSource(item, propItem, key: key);
    }
    if (propItem.type == "threshold") {
      propWidget = MapItemPropThreshold(item, propItem, key: key);
    }
    if (propItem.type == "color") {
      propWidget = MapItemPropColor(item, propItem, key: key);
    }
    if (propItem.type == "bool") {
      propWidget = MapItemPropBool(item, propItem, key: key);
    }
    if (propItem.type == "image") {
      propWidget = MapItemPropImage(item, propItem, key: key);
    }
    if (propItem.type == "scale_fit") {
      propWidget = MapItemPropScaleFit(item, propItem, key: key);
    }
    if (propItem.type == "orientation") {
      propWidget = MapItemPropOrientation(item, propItem, key: key);
    }
    if (propItem.type == "decorations") {
      propWidget = MapItemPropDecorations(item, propItem, key: key);
      isDecorations = true;
    }
    if (propItem.type == "actions") {
      propWidget = MapItemPropActions(item, propItem, key: key);
    }

    /*if (isDecorations) {
      return propWidget;
    }*/

    return Container(
      constraints: const BoxConstraints(minWidth: 100, maxWidth: 265),
      color: Colors.blueAccent.withOpacity(0.1),
      padding: const EdgeInsets.all(0),
      margin: const EdgeInsets.only(bottom: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          (!isDecorations)
              ? Text(
                  propItem.displayName,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                )
              : Container(),
          Padding(
            padding: EdgeInsets.only(top: (isDecorations ? 0 : 3)),
            child: propWidget,
          ),
        ],
      ),
    );
  }

  Widget buildExpanded(BuildContext context) {
    if (expanded) {
      return Container(
        padding: const EdgeInsets.only(bottom: 0),
        color: Colors.black54,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.propGroup.props.map<Widget>((propItem) {
            return Container(padding: const EdgeInsets.only(left: 0, right: 0, bottom: 0), child: buildPropItem(widget.item, propItem, Key(propItem.name)));
          }).toList(),
        ),
      );
    }
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    /*if (widget.propGroup.name == "Decorations") {
      expanded = true;
      return buildExpanded(context);
    }*/

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    expanded = !expanded;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    //border: Border.symmetric(vertical: BorderSide(color: Colors.blue, width: 3))
                  ),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(minWidth: 100, maxWidth: 266),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(widget.propGroup.name),
                      ),
                      expanded ? const Icon(Icons.keyboard_arrow_up_outlined) : const Icon(Icons.keyboard_arrow_down_outlined),
                    ],
                  ),
                ),
              ),
            ),
            buildExpanded(context),
          ],
        ),
      ),
    );
  }
}
