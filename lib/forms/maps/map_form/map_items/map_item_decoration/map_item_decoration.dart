import '../../../../../core/workspace/workspace.dart';
import '../../main/map_item.dart';
import '../map_item_single/map_item_single.dart';

abstract class MapItemDecoration extends MapItemSingle {
  MapItemDecoration(Connection connection) : super(connection);

  bool activityEnabled() {
    String activityCondition = get("activity_condition");
    String activityValue = get("activity_value");
    bool activityEnabled = false;
    String value = dataSourceValue().value;
    String uom = dataSourceValue().uom;
    if (activityCondition == "") {
      activityEnabled = true;
    }
    if (activityCondition == "==" && activityValue == dataSourceValue().value) {
      activityEnabled = true;
    }

    if (activityCondition == ">" ||
        activityCondition == ">=" ||
        activityCondition == "<" ||
        activityCondition == "<=") {
      double? valueAsDouble = double.tryParse(value);
      double? activityValueAsDouble = double.tryParse(activityValue);
      if (valueAsDouble != null && activityValueAsDouble != null) {
        if (activityCondition == ">") {
          if (valueAsDouble > activityValueAsDouble) {
            activityEnabled = true;
          }
        }
        if (activityCondition == ">=") {
          if (valueAsDouble >= activityValueAsDouble) {
            activityEnabled = true;
          }
        }
        if (activityCondition == "<") {
          if (valueAsDouble < activityValueAsDouble) {
            activityEnabled = true;
          }
        }
        if (activityCondition == "<=") {
          if (valueAsDouble <= activityValueAsDouble) {
            activityEnabled = true;
          }
        }
      }
    }

    if (activityCondition == "uom != error" && uom != "error") {
      activityEnabled = true;
    }
    if (activityCondition == "always") {
      activityEnabled = true;
    }
    return activityEnabled;
  }

  @override
  List<MapItemPropGroup> propGroupsOfItem() {
    List<MapItemPropGroup> groups = super.propGroupsOfItem();
    {
      List<MapItemPropItem> props = [];
      props.add(MapItemPropItem("", "activity_condition", "Condition",
          "options:always:==:<:<=:>:>=:uom != error", "always"));
      props.add(MapItemPropItem("", "activity_value", "Value", "text", "0"));
      groups.add(MapItemPropGroup("Activity", true, props));
    }
    return groups;
  }
}
