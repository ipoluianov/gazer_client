import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/forms/units/unit_edit/config/unit_default_value.dart';
import 'package:flutter/material.dart';

class UnitConfigText extends StatefulWidget {
  final GazerLocalClient client;
  final Map<String, dynamic> meta;
  Map<String, dynamic> config;
  UnitConfigText(this.client, this.meta, this.config, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UnitConfigTextState();
  }
}

class UnitConfigTextState extends State<UnitConfigText>
    with TickerProviderStateMixin {
  late TextEditingController _controller;

  @override
  void initState() {
    _controller = TextEditingController();
    if (!widget.config.containsKey(widget.meta['name'])) {
      widget.config[widget.meta['name']] = defaultValue(widget.meta['type'], widget.meta['default_value'], widget.meta['format']);
    }
    _controller.text = widget.config[widget.meta['name']];
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: widget.meta['display_name'],
        labelText: widget.meta['name'],
      ),
      onChanged: (text) {
        widget.config[widget.meta['name']] = text;
      },
    );
  }
}
