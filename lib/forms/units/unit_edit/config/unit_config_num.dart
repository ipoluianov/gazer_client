import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/forms/units/unit_edit/config/unit_default_value.dart';
import 'package:flutter/material.dart';

class UnitConfigNum extends StatefulWidget {
  final GazerLocalClient client;
  final Map<String, dynamic> meta;
  Map<String, dynamic> config;
  UnitConfigNum(this.client, this.meta, this.config, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UnitConfigNumState();
  }
}

class UnitConfigNumState extends State<UnitConfigNum>
    with TickerProviderStateMixin {
  late TextEditingController _controller;
  bool useInteger_ = false;

  @override
  void initState() {
    _controller = TextEditingController();
    try {
      if (int.parse(widget.meta['format']) == 0) {
        useInteger_ = true;
      }
    } catch (ex) {}

    if (!widget.config.containsKey(widget.meta['name'])) {
      widget.config[widget.meta['name']] = defaultValue(widget.meta['type'],
          widget.meta['default_value'], widget.meta['format']);
    }

    _controller.text = '${widget.config[widget.meta['name']]}';

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 100, maxWidth: 300),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: widget.meta['display_name'],
          labelText: widget.meta['display_name'],
        ),
        onChanged: (text) {
          try {
            if (useInteger_) {
              widget.config[widget.meta['name']] = int.parse(text);
            } else {
              widget.config[widget.meta['name']] = double.parse(text);
            }
          } catch (ex) {}
        },
      ),
    );
  }
}
