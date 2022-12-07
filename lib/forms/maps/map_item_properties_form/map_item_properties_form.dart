import 'package:flutter/material.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/forms/maps/map_form/map_item.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/map_item_group_of_properties.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';

class MapItemPropertiesForm extends StatefulWidget {
  final MapItemPropertiesFormArgument arg;
  const MapItemPropertiesForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemPropertiesFormSt();
  }
}

class MapItemPropertiesFormSt extends State<MapItemPropertiesForm> {
  late IPropContainer item;

  @override
  void initState() {
    super.initState();
    item = widget.arg.item;
  }

  Widget buildPropGroup(MapItemPropGroup propItem) {
    return MapItemGroupOfProperties(item, propItem);
  }

  Widget buildContent(BuildContext context) {
    /*var propList = item.propList();
    return Expanded(
      child: Scrollbar(
        thickness: 20,
        radius: const Radius.circular(10),
        thumbVisibility: true,
        child: ListView(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: propList.map<Widget>((item) {
                return buildPropGroup(item);
              }).toList(),
            )
          ],
        ),
      ),
    );*/
    return Text("not implemented");
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
            "Map Item Properties",
            actions: <Widget>[
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
