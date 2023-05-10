import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/maps/map_form/map_items/map_item_group/map_item_unit_table_01.dart';
import 'package:gazer_client/forms/maps/map_item_add_form/map_item_add_form.dart';

import 'map_item.dart';
import '../map_items/map_item_control/map_item_button.dart';
import '../map_items/map_item_single/chart/map_item_chart.dart';
import '../map_items/map_item_single/error_indicator/map_item_error_indicator.dart';
import '../map_items/map_item_single/gauge/map_item_gauge_round.dart';
import '../map_items/map_item_special/map_item_item.dart';
import '../map_items/map_item_special/map_item_map.dart';
import '../map_items/map_item_control/map_item_switch.dart';
import '../map_items/map_item_single/text/map_item_text.dart';
import '../map_items/map_item_single/text/map_item_text_02.dart';
import '../map_items/map_item_special/maps_item_runlang.dart';

class MapItemsLibrary {
  static final MapItemsLibrary _singleton = MapItemsLibrary._internal();

  MapItemsLibrary._internal() {
    registerItem(MapItemText.sType, MapItemText.sName, "text", (c) {
      return MapItemText(c);
    });
    registerItem(MapItemText02.sType, MapItemText02.sName, "text", (c) {
      return MapItemText02(c);
    });
    registerItem(MapItemGaugeRound.sType, MapItemGaugeRound.sName, "gauge",
        (c) {
      return MapItemGaugeRound(c);
    });
    registerItem(MapItemChart.sType, MapItemChart.sName, "chart", (c) {
      return MapItemChart(c);
    });
    registerItem(MapItemMap.sType, MapItemMap.sName, "", (c) {
      return MapItemMap(c);
    });
    registerItem(MapItemItem.sType, MapItemItem.sName, "", (c) {
      return MapItemItem(c);
    });
    registerItem(MapItemErrorIndicator.sType, MapItemErrorIndicator.sName, "",
        (c) {
      return MapItemErrorIndicator(c);
    });
    registerItem(MapItemSwitch.sType, MapItemSwitch.sName, "", (c) {
      return MapItemSwitch(c);
    });
    registerItem(MapItemButton.sType, MapItemButton.sName, "", (c) {
      return MapItemButton(c);
    });
    registerItem(MapItemUnitTable01.sType, MapItemUnitTable01.sName, "", (c) {
      return MapItemUnitTable01(c);
    });
    registerItem(MapItemRunlang.sType, MapItemRunlang.sName, "", (c) {
      return MapItemRunlang(c);
    });
  }

  factory MapItemsLibrary() {
    return _singleton;
  }

  Map<String, MapItemsLibraryItem> itemTypes = {};

  void registerItem(String type, String name, String category,
      MapItem Function(Connection) constructor) {
    itemTypes[type] = MapItemsLibraryItem(type, name, category, constructor);
  }

  List<MapItemAddFormItem> internalMapItemTypes() {
    List<MapItemAddFormItem> items = [];
    for (var key in itemTypes.keys) {
      var type = itemTypes[key];
      if (type != null) {
        items.add(MapItemAddFormItem(
            "", type.name, type.type, type.category, null,
            tags: {}));
      }
    }
    return items;
  }

  MapItem makeItemByType(String t, Connection connection) {
    MapItem? item;
    if (itemTypes.containsKey(t)) {
      var itemType = itemTypes[t];
      if (itemType != null) {
        item = itemType.constructor(connection);
      }
    }

    if (item == null) {
      var txtReplacer = MapItemText(connection);
      txtReplacer.isReplacer = true;
      txtReplacer.replaceType = t;
      item ??= txtReplacer;
    }

    item.generateAndSetNewId();

    for (var itemPropPage in item.propList()) {
      for (var itemPropGroup in itemPropPage.groups) {
        for (var itemProp in itemPropGroup.props) {
          item.set(itemProp.name, itemProp.defaultValue);
        }
      }
    }

    return item;
  }
}

class MapItemsLibraryItem {
  String name;
  String type;
  String category = "";
  MapItem Function(Connection) constructor;
  MapItemsLibraryItem(this.type, this.name, this.category, this.constructor);
}
