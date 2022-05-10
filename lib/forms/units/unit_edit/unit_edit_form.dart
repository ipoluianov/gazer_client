import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/protocol/unit/unit_get_config.dart';
import 'package:gazer_client/core/protocol/unit_type/unit_type_config_meta.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/forms/units/unit_edit/config/unit_config_object.dart';
import 'package:gazer_client/widgets/error_dialog/error_dialog.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';

import '../../../core/navigation/route_generator.dart';
import 'unit_edit_form_bloc.dart';

class UnitEditForm extends StatefulWidget {
  final UnitEditFormArgument arg;
  const UnitEditForm({Key? key, required this.arg}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UnitEditFormSt();
  }
}

class UnitEditFormSt extends State<UnitEditForm> {
  late UnitEditFormCubit cubit;

  late String name = "";
  bool nameLoadedByUnitType = false;
  late Map<String, dynamic> currentConfig;
  late List<dynamic> currentConfigMeta;
  //late String conf = "";

  late Future<UnitTypeConfigMetaResponse> _futureUnitTypeConfigMeta;
  late Future<UnitGetConfigResponse> _futureUnitGetConfig;
  final ScrollController _scrollController = ScrollController();
  late ScrollController _scrollController1;
  late ScrollController _scrollController2;
  final TextEditingController _txtNameController = TextEditingController();

  @override
  void initState() {
    if (widget.arg.unitId == "") {
      currentConfig = <String, dynamic>{};
      _futureUnitTypeConfigMeta = Repository().client(widget.arg.connection).unitTypeConfigMeta(widget.arg.unitType);
    } else {
      _futureUnitGetConfig = Repository().client(widget.arg.connection).unitsGetConfig(widget.arg.unitId);
    }

    Repository().client(widget.arg.connection).unitsGetConfig(widget.arg.unitId).then((value) {
      name = value.unitName;
      _txtNameController.text = value.unitName;
    });

    _scrollController1 = ScrollController();
    _scrollController2 = ScrollController();

    super.initState();

    cubit = UnitEditFormCubit(UnitEditFormStateLoading());

    cubit.load(widget.arg.connection);
  }

  @override
  void dispose() {
    _scrollController1.dispose();
    _scrollController2.dispose();

    super.dispose();
  }

  // UnitTypeConfigMetaResponse

  Widget buildNewUnitConfig() {
    return FutureBuilder<UnitTypeConfigMetaResponse>(
      future: _futureUnitTypeConfigMeta,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          currentConfigMeta = jsonDecode(snapshot.data!.unitTypeConfigMeta);
          if (name == "" && !nameLoadedByUnitType) {
            _txtNameController.text = snapshot.data!.unitType;
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
              UnitConfigObject(Repository().client(widget.arg.connection), currentConfigMeta, currentConfig, () {
                setState(() {});
              }),
            ],
          );
        } else if (snapshot.hasError) {
          return const Text("Error");
        }
        return Container();
      },
    );
  }

  Widget buildEditUnitConfig() {
    return FutureBuilder<UnitGetConfigResponse>(
      future: _futureUnitGetConfig,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          try {
            currentConfig = jsonDecode(snapshot.data!.unitConfig);
          } catch (ex) {
            currentConfig = <String, dynamic>{};
          }

          currentConfigMeta = jsonDecode(snapshot.data!.unitConfigMeta);
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
              UnitConfigObject(Repository().client(widget.arg.connection), currentConfigMeta, currentConfig, () {
                setState(() {});
              }),
            ],
          );
        } else if (snapshot.hasError) {
          return const Text("Error");
        }
        return Container();
      },
    );
  }

  Widget buildConfigWidget() {
    return widget.arg.unitId == "" ? buildNewUnitConfig() : buildEditUnitConfig();
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
                        isAlwaysShown: true,
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
