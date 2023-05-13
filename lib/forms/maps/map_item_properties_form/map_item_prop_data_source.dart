import 'package:flutter/material.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/forms/utilities/lookup_form/lookup_form.dart';
import 'package:gazer_client/forms/maps/map_form/main/map_item.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/styles.dart';

import '../../../core/navigation/route_generator.dart';

class MapItemPropDataSource extends StatefulWidget {
  final IPropContainer item;
  final MapItemPropItem propItem;

  const MapItemPropDataSource(this.item, this.propItem, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemPropDataSourceSt();
  }
}

class MapItemPropDataSourceSt extends State<MapItemPropDataSource> {
  late String value;
  TextEditingController txtController = TextEditingController();

  @override
  void initState() {
    super.initState();
    value = widget.item.get(widget.propItem.name);
    txtController.text = value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 100, maxWidth: 250),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: txtController,
            decoration: textInputDecoration(),
            onChanged: (text) {
              setState(() {
                widget.item.set(widget.propItem.name, text);
              });
              //widget.onChanged();
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.more_horiz),
          color: Colors.white.withOpacity(0.5),
          onPressed: () {
            Navigator.pushNamed(context, "/lookup",
                    arguments: LookupFormArgument(
                        Repository().lastSelectedConnection,
                        "Select source item",
                        "data-item"))
                .then((value) {
              if (value != null) {
                var res = value as LookupFormResult;
                setState(() {
                  txtController.text = res.field("name");
                  widget.item.set(widget.propItem.name, res.field("name"));
                });
              }
            });
          },
          //child: const Text("..."),
        ),
      ]),
    );
  }
}
