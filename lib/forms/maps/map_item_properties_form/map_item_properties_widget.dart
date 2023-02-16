import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/forms/maps/map_form/main/map_item.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/map_item_group_of_properties.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';

class MapItemPropertiesWidget extends StatefulWidget {
  final MapItemPropertiesFormArgument arg;
  const MapItemPropertiesWidget(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemPropertiesWidgetSt();
  }
}

class MapItemPropertiesWidgetSt extends State<MapItemPropertiesWidget> {
  late IPropContainer item;

  @override
  void initState() {
    super.initState();
    item = widget.arg.item;
  }

  ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Widget buildPropGroup(MapItemPropGroup propItem) {
    return MapItemGroupOfProperties(item, propItem);
  }

  int currentPageIndex = 0;

  @override
  Widget build(BuildContext context) {
    var propPages = item.propList();

    List<Widget> pagesButtons = [];
    for (int pageIndex = 0; pageIndex < propPages.length; pageIndex++) {
      var propPage = propPages[pageIndex];
      pagesButtons.add(
        Expanded(
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                currentPageIndex = pageIndex;
              });
            },
            icon: propPage.icon,
            label: Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 12),
                child: Text(propPage.name)),
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(
                    (pageIndex == currentPageIndex)
                        ? Colors.blue.withOpacity(0.3)
                        : Colors.transparent)
                //color: (pageIndex == currentPageIndex) ? Colors.green : Colors.white
                ),
          ),
        ),
      );
    }

    List<Widget> propGroupsWidgets = [];
    if (currentPageIndex >= 0 && currentPageIndex < propPages.length) {
      if (propPages[currentPageIndex].widget != null) {
        propGroupsWidgets.add(propPages[currentPageIndex].widget!);
      } else {
        for (var propGroup in propPages[currentPageIndex].groups) {
          propGroupsWidgets.add(buildPropGroup(propGroup));
        }
      }
    }

    if (!mounted) {
      return Container();
    }
    //return Text("123");
    return Container(
      constraints: const BoxConstraints(maxWidth: 290),
      color: DesignColors.back1(),
      padding: const EdgeInsets.all(3),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: pagesButtons,
          ),
          Expanded(
            child: Scrollbar(
              controller: scrollController,
              thickness: 15,
              radius: const Radius.circular(5),
              thumbVisibility: true,
              child: ListView(
                controller: scrollController,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: propGroupsWidgets,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /*@override
  Widget build1(BuildContext context) {
    var propList = item.propList();
    if (!mounted) {
      return Container();
    }
    //return Text("123");
    return Container(
      constraints: const BoxConstraints(maxWidth: 290),
      color: Colors.black45,
      child: Scrollbar(
        controller: scrollController,
        thickness: 10,
        radius: const Radius.circular(5),
        thumbVisibility: true,
        child: ListView(
          controller: scrollController,
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
    );
  }*/
}
