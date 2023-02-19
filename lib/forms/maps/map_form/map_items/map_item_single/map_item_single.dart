import 'dart:ui';

import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/maps/map_form/main/map_item.dart';

abstract class MapItemSingle extends MapItem {
  MapItemSingle(Connection connection) : super(connection);

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = super.propGroupsOfItem();
    {
      {
        List<MapItemPropItem> props = [];
        props.add(MapItemPropItem(
            "", "data_source", "Data Source Item", "data_source", ""));
        groups.add(MapItemPropGroup("Data Source", true, props));
      }
    }
    return groups;
  }
}
