import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/forms/units/unit_edit/config/unit_default_value.dart';
import 'package:flutter/material.dart';

class UnitConfigBool extends StatefulWidget {
  final GazerLocalClient client;
  final Map<String, dynamic> meta;
  Map<String, dynamic> config;
  UnitConfigBool(this.client, this.meta, this.config, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UnitConfigBoolState();
  }
}

class UnitConfigBoolState extends State<UnitConfigBool>
    with TickerProviderStateMixin {
  @override
  void initState() {
    if (!widget.config.containsKey(widget.meta['name'])) {
      widget.config[widget.meta['name']] =
          defaultValue(widget.meta['type'], widget.meta['default_value'], widget.meta['format']);
    }
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Checkbox(
        onChanged: (bool? value) {
          setState(() {
            widget.config[widget.meta['name']] = value;
          });
        },
        value: widget.config[widget.meta['name']],
      ),
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
        onTap: () {
          setState(() {
            widget.config[widget.meta['name']] = !widget.config[widget.meta['name']];
          });
        },
        child: Text(widget.meta['display_name']),
      ),
      ),
    ]);
  }
}
