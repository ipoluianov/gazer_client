import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/core/protocol/service/service_info.dart';
import 'package:gazer_client/core/protocol/unit/unit_state_all.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/widgets/load_indicator/load_indicator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/forms/units/node_form/unit_card.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:gazer_client/widgets/title_widget/title_widget.dart';

import '../../../core/navigation/route_generator.dart';
import 'node_form_bloc.dart';

class NodeForm extends StatefulWidget {
  final NodeFormArgument arg;
  const NodeForm({Key? key, required this.arg}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NodeFormSt();
  }
}

class NodeFormSt extends State<NodeForm> {
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    load();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      load();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  bool loading = false;
  bool loaded = false;
  String loadingError = "";
  List<UnitStateAllItemResponse> items = [];

  bool addingUnits = false;

  void load() {
    setState(() {
      loading = true;
    });
    GazerLocalClient client = Repository().client(widget.arg.connection);
    navCurrentIndex(context);
    //print("Units - STATE ${navCurrentPath(context)}");
    client.unitsStateAll().then((value) {
      if (mounted) {
        setState(() {
          items = value.items;
          loading = false;
          loaded = true;
          loadingError = "";
        });
      }
    }).catchError((err) {
      if (mounted) {
        setState(() {
          loadingError = err.toString();
          loading = false;
        });
      }
    });
  }

  Widget buildUnitCard(BuildContext context, UnitStateAllItemResponse e) {
    return UnitCard(widget.arg.connection, e, () {
      setState(() {});
      Navigator.of(context)
          .pushNamed(
        "/unit",
        arguments: UnitFormArgument(
          widget.arg.connection,
          e.unitId,
        ),
      )
          .then((value) {
        setState(() {});
      });
    }, () {
      List<String> ids = [];
      ids.add(e.unitId);
      Repository().client(widget.arg.connection).unitsRemove(ids).then((value) {
        load();
      });
    });
  }

  Widget buildUnitsList(BuildContext context) {
    return DesignColors.buildScrollBar(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                children: items.map(
                  (e) {
                    return buildUnitCard(context, e);
                  },
                ).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    if (loading && !loaded) {
      return Text("loading ...");
    }
    if (items.isEmpty && loaded) {
      return buildEmptyUnitList(context);
    }
    return buildUnitsList(context);
  }

  Widget buildError(BuildContext context) {
    if (loadingError.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Container()),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.red.withOpacity(0.5),
            ),
            constraints: const BoxConstraints(minWidth: 200),
            padding: const EdgeInsets.all(10),
            child: Text(
              "Error: " + loadingError,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }

  void addUnit() {
    Navigator.of(context).pushNamed("/unit_add", arguments: UnitAddFormArgument(widget.arg.connection));
  }

  Widget buildAddButton(BuildContext context) {
    if (items.isNotEmpty) {
      return buildActionButton(context, Icons.add, "Add Unit", () {
        addUnit();
      });
    } else {
      return buildActionButtonFull(context, Icons.add, "Add Unit", () {
        addUnit();
      }, false, imageColor: Colors.white, backColor: Colors.green);
    }
  }

  void addLocalSystemUnits() async {
    setState(() {
      addingUnits = true;
    });
    await Repository().client(widget.arg.connection).unitsAdd("computer_memory", "Memory", "{}");
    await Repository().client(widget.arg.connection).unitsAdd("computer_network", "Network", "{}");
    await Repository().client(widget.arg.connection).unitsAdd("computer_storage", "Storage", "{}");
    setState(() {
      addingUnits = false;
    });
  }

  Widget buildEmptyUnitList(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          child: Scrollbar(
            isAlwaysShown: true,
            thickness: 15,
            radius: const Radius.circular(5),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: const Text(
                      "No units to display",
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white30,
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        const Text(
                          "Add a unit",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white30,
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(top: 5),
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              addUnit();
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(Colors.green),
                              padding: MaterialStateProperty.all(const EdgeInsets.all(32)),
                            ),
                            label: const Text("Add a Unit"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    child: Column(
                      children: [
                        const Text(
                          "Add local system units:\r\nMemory & Network & Storage",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white30,
                          ),
                        ),
                        addingUnits
                            ? const Text("adding ...")
                            : Container(
                                margin: const EdgeInsets.only(top: 5),
                                child: ElevatedButton(
                                    onPressed: () {
                                      addLocalSystemUnits();
                                    },
                                    child: const Text("Add local system units"))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  int currentTitleKey = 0;
  void incrementTitleKey() {
    setState(() {
      currentTitleKey++;
    });
  }

  String getCurrentTitleKey() {
    return "units_" + currentTitleKey.toString();
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
            "Units",
            key: Key(getCurrentTitleKey()),
            actions: [
              buildAddButton(context),
              buildActionButton(context, Icons.edit, "Node Name", () {
                Repository().client(widget.arg.connection).serviceInfo().then((value) {
                  _textFieldController.text = value.nodeName;
                  _displayNodeNameDialog(context).then((value) {
                    incrementTitleKey();
                  });
                }).catchError((err) {});
              }),
              buildHomeButton(context),
            ],
          ),
          body: Container(
            color: DesignColors.mainBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LeftNavigator(showLeft),
                      Expanded(
                        child: Stack(
                          children: [
                            buildContent(context),
                            buildError(context),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                BottomNavigator(showBottom),
              ],
            ),
          ),
        );
      },
    );
  }

  String txtNodeName = "";
  final TextEditingController _textFieldController = TextEditingController();

  Future<void> _displayNodeNameDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Set Node Name'),
            content: TextField(
              autofocus: true,
              onChanged: (value) {
                setState(() {
                  txtNodeName = value;
                });
              },
              controller: _textFieldController,
              decoration: const InputDecoration(hintText: "Node Name"),
            ),
            actions: <Widget>[
              OutlinedButton(
                child: const Text('CANCEL'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
              OutlinedButton(
                child: const Text('OK'),
                onPressed: () {
                  setState(() {
                    Repository().client(widget.arg.connection).serviceSetNodeName(txtNodeName).then((value) {
                      Navigator.pop(context);
                    });
                  });
                },
              ),
            ],
          );
        });
  }
}
