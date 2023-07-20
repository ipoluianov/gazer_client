import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/forms/units/unit_edit/config/unit_config_bool.dart';
import 'package:gazer_client/forms/units/unit_edit/config/unit_config_num.dart';
import 'package:gazer_client/forms/units/unit_edit/config/unit_config_string.dart';
import 'package:gazer_client/forms/units/unit_edit/config/unit_config_table.dart';
import 'package:flutter/material.dart';

import 'unit_config_text.dart';

class UnitConfigObject extends StatefulWidget {
  final GazerLocalClient client;
  final List<dynamic> meta;
  Map<String, dynamic> config;
  final Function() onChanged;
  UnitConfigObject(this.client, this.meta, this.config, this.onChanged,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UnitConfigObjectState();
  }
}

class UnitConfigObjectState extends State<UnitConfigObject>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.meta
          .map((entry) {
            if (entry['type'] == "string") {
              return UnitConfigString(widget.client, entry, widget.config, () {
                setState(() {});
                widget.onChanged();
              });
            }
            if (entry['type'] == "text") {
              return UnitConfigText(widget.client, entry, widget.config, () {
                setState(() {});
                widget.onChanged();
              });
            }
            if (entry['type'] == "num") {
              return UnitConfigNum(widget.client, entry, widget.config);
            }
            if (entry['type'] == "bool") {
              return UnitConfigBool(widget.client, entry, widget.config);
            }
            if (entry['type'] == "table") {
              return UnitConfigTable(widget.client, entry, widget.config);
            }
            var w = Text(entry['name']);
            return w;
          })
          .toList()
          .cast<Widget>(),
    );
  }
}
