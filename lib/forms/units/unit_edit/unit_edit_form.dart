import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/protocol/unit/unit_get_config.dart';
import 'package:gazer_client/core/protocol/unit_type/unit_type_config_meta.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/forms/units/unit_edit/config/unit_config_object.dart';
import 'package:gazer_client/widgets/error_dialog/error_dialog.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';

import '../../../core/navigation/route_generator.dart';

class UnitEditForm extends StatefulWidget {
  final UnitEditFormArgument arg;
  const UnitEditForm({Key? key, required this.arg}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UnitEditFormSt();
  }
}

class UnitEditFormSt extends State<UnitEditForm> {
  late String name = "";
  bool nameLoadedByUnitType = false;
  Map<String, dynamic> currentConfig = <String, dynamic>{};
  late List<dynamic> currentConfigMeta;
  //late String conf = "";

  //late Future<UnitTypeConfigMetaResponse> _futureUnitTypeConfigMeta;
  //late Future<UnitGetConfigResponse> _futureUnitGetConfig;
  //final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollController1 = ScrollController();
  //final ScrollController _scrollController2 = ScrollController();
  final TextEditingController _txtNameController = TextEditingController();

  UnitTypeConfigMetaResponse? unitConfigMeta_;
  UnitGetConfigResponse? unitConfig_;

  @override
  void initState() {
    super.initState();

    if (widget.arg.unitId == "") {
      loadUnitConfigMeta();
    } else {
      if (widget.arg.unitType != "") {
        loadUnitConfig();
      }
    }
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    //_scrollController2.dispose();

    super.dispose();
  }

  void loadUnitConfigMeta() {
    Repository()
        .client(widget.arg.connection)
        .unitTypeConfigMeta(widget.arg.unitType)
        .then((value) {
      if (mounted) {
        setState(() {
          unitConfigMeta_ = value;
        });
      }
    }).catchError((err) {
      print(err);
    });
  }

  void loadUnitConfig() {
    Repository()
        .client(widget.arg.connection)
        .unitsGetConfig(widget.arg.unitId)
        .then((value) {
      name = value.unitName;
      _txtNameController.text = value.unitName;
    }).catchError((err) {
      print("unit config loading $err");
    });
  }

  // UnitTypeConfigMetaResponse

  Widget buildNewUnitConfig() {
    if (unitConfigMeta_ != null) {
      currentConfigMeta = jsonDecode(unitConfigMeta_!.unitTypeConfigMeta);
      if (name == "" && !nameLoadedByUnitType) {
        _txtNameController.text = unitConfigMeta_!.unitType;
        name = _txtNameController.text;
        nameLoadedByUnitType = true;
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //buildToolbar(),
          Container(
            child: TextField(
              controller: _txtNameController,
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
          ),
          UnitConfigObject(Repository().client(widget.arg.connection),
              currentConfigMeta, currentConfig, () {
            setState(() {});
          }),
        ],
      );
    }
    return Container();
  }

  Widget buildEditUnitConfig() {
    if (unitConfig_ != null) {
      try {
        currentConfig = jsonDecode(unitConfig_!.unitConfig);
      } catch (ex) {
        currentConfig = <String, dynamic>{};
      }

      currentConfigMeta = jsonDecode(unitConfig_!.unitConfigMeta);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //buildToolbar(),
          Container(
            child: TextField(
              controller: _txtNameController,
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
          ),
          UnitConfigObject(Repository().client(widget.arg.connection),
              currentConfigMeta, currentConfig, () {
            setState(() {});
          }),
        ],
      );
    }
    return Container();
  }

  Widget buildConfigWidget() {
    return widget.arg.unitId == ""
        ? buildNewUnitConfig()
        : buildEditUnitConfig();
  }

  void save() {
    String conf = "";
    var client = Repository().client(widget.arg.connection);
    setState(() {
      conf = jsonEncode(currentConfig);
    });

    if (widget.arg.unitId == "") {
      client.unitsAdd(widget.arg.unitType, name, conf).then(
        (value) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed(
            "/unit",
            arguments: UnitFormArgument(
              widget.arg.connection,
              value.unitId,
            ),
          );
        },
      ).catchError((err) {
        showErrorDialog(context, "Error", "$err");
      });
    } else {
      client.unitsSetConfig(widget.arg.unitId, name, conf).then(
        (value) {
          Navigator.pop(context, name);
        },
      ).catchError(
        (err) {
          showErrorDialog(context, "Error", "$err");
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      bool narrow = constraints.maxWidth < constraints.maxHeight;
      bool showLeft = !narrow;
      bool showBottom = narrow;

      return Scaffold(
        appBar: TitleBar(
          widget.arg.connection,
          "Unit Edit  " + name,
          actions: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: ElevatedButton.icon(
                onPressed: () {
                  save();
                },
                icon: const Icon(Icons.save),
                label: const Text("Save"),
              ),
            ),
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
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      child: Scrollbar(
                        thumbVisibility: true,
                        controller: _scrollController1,
                        child: SingleChildScrollView(
                          controller: _scrollController1,
                          child: buildConfigWidget(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            BottomNavigator(showBottom),
          ],
        ),
      );
    });
  }
}
