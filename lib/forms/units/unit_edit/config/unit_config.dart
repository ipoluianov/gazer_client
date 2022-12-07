import 'dart:convert';

import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/forms/units/unit_edit/config/unit_config_object.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class UnitConfig extends StatefulWidget {
  final GazerLocalClient client;
  final Function() onBack;
  final Function(String unitName) onAccept;
  final String unitConfigMeta;
  final String unitConfig;
  final String id;
  final String type;
  final String name;
  const UnitConfig(this.client, this.id, this.type, this.name,
      this.unitConfigMeta, this.unitConfig, this.onBack, this.onAccept,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UnitConfigState();
  }
}

class UnitConfigState extends State<UnitConfig> with TickerProviderStateMixin {
  late Map<String, dynamic> currentConfig;
  late List<dynamic> currentConfigMeta;
  late String conf;
  late ScrollController _scrollController;
  late TextEditingController _controller;
  late String name;

  @override
  void initState() {
    _controller = TextEditingController();
    _scrollController = ScrollController();
    name = widget.name;
    try {
      currentConfig = jsonDecode(widget.unitConfig);
    } catch (ex) {
      currentConfig = <String, dynamic>{};
    }

    conf = "";

    _controller.text = name;

    currentConfigMeta = jsonDecode(widget.unitConfigMeta);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void save() {
    setState(() {
      conf = jsonEncode(currentConfig);
    });

    if (widget.id == "") {
      widget.client.unitsAdd(widget.type, name, conf);
    } else {
      widget.client.unitsSetConfig(widget.id, name, conf);
    }
    widget.onAccept(name);
  }

  Widget buildToolbar() {
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        color: Colors.black26,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Flex(
            direction: Axis.horizontal,
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                child: ElevatedButton(
                  onPressed: () {
                    widget.onBack();
                  },
                  child: const Icon(
                    Icons.arrow_back_ios,
                    size: 36,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5),
                child: ElevatedButton(
                  onPressed: () {
                    save();
                  },
                  child: const Icon(
                    Icons.save,
                    size: 36,
                  ),
                ),
              ),
              const Expanded(
                child: Text(""),
              ),
            ],
          ),
        ),
      ),
      margin: const EdgeInsets.all(10),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      dragStartBehavior: DragStartBehavior.down,
      scrollDirection: Axis.vertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //buildToolbar(),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              hintText: "Name",
              labelText: "Name",
            ),
            onChanged: (text) {
              setState(() {
                name = text;
              });
            },
          ),
          UnitConfigObject(widget.client, currentConfigMeta, currentConfig, () {
            setState(() {});
          }),
          Text(conf)
        ],
      ),
    );
  }
}
