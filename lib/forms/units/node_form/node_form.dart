import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/core/protocol/unit/unit_state_all.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/widgets/load_indicator/load_indicator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/forms/units/node_form/unit_card.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';

import '../../../core/navigation/route_generator.dart';

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

  ScrollController scrollController1 = ScrollController();
  ScrollController scrollController2 = ScrollController();

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
      controller: scrollController1,
      child: SingleChildScrollView(
        controller: scrollController1,
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

  Widget buildToolbar(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        List<Widget> leftButtons = [];
        List<Widget> rightButtons = [];

        leftButtons.add(buildAddButton(context));

        leftButtons.add(Expanded(child: Container()));
        leftButtons.addAll(rightButtons);
        return Row(
          children: leftButtons,
        );
      },
    );
  }

  Widget buildForm(BuildContext context) {
    return Expanded(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildToolbar(context),
        Container(
          color: DesignColors.fore2(),
          height: 1,
        ),
        buildContent(context),
      ],
    ));
  }

  Widget buildContent(BuildContext context) {
    if (loading && !loaded) {
      return const LoadIndicator();
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
    Navigator.of(context).pushNamed("/unit_add",
        arguments: UnitAddFormArgument(widget.arg.connection));
  }

  Widget buildAddButton(BuildContext context) {
    return buildActionButton(context, Icons.add, "Add Unit", () {
      addUnit();
    });
  }

  void addLocalSystemUnits() async {
    setState(() {
      addingUnits = true;
    });
    await Repository()
        .client(widget.arg.connection)
        .unitsAdd("computer_memory", "Memory", "{}");
    await Repository()
        .client(widget.arg.connection)
        .unitsAdd("computer_network", "Network", "{}");
    await Repository()
        .client(widget.arg.connection)
        .unitsAdd("computer_storage", "Storage", "{}");
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
            controller: scrollController2,
            thumbVisibility: true,
            thickness: 15,
            radius: const Radius.circular(5),
            child: SingleChildScrollView(
              controller: scrollController2,
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
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.green),
                              padding: MaterialStateProperty.all(
                                  const EdgeInsets.all(32)),
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
                                    child:
                                        const Text("Add local system units"))),
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
            actions: [
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
                            buildForm(context),
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
}
