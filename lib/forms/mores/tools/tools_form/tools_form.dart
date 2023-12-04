import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';

import '../../more_form/more_button.dart';

class ToolsForm extends StatefulWidget {
  final ToolsFormArgument arg;
  const ToolsForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ToolsFormSt();
  }
}

class ToolsFormSt extends State<ToolsForm> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  Widget buildHeader(BuildContext context, String header) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          padding: EdgeInsets.only(bottom: 10),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.green,
                width: 3,
              ),
            ),
          ),
          child: Text(
            header,
            style: TextStyle(
              fontSize: 24,
              color: DesignColors.fore(),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> buildDebug(BuildContext context) {
    List<Widget> result = [
      MoreButton(() {
        Navigator.pushNamed(context, "/tools_debug_summary",
            arguments: ToolsFormArgument());
      }, "Debug Summary", const Icon(Icons.bug_report, size: 48), 3),
    ];
    return [buildHeader(context, "Debug"), Wrap(children: result)];
  }

  List<Widget> buildSensors(BuildContext context) {
    List<Widget> result = [
      MoreButton(() {
        Navigator.pushNamed(context, "/tools_sensors_raw",
            arguments: ToolsFormArgument());
      }, "Sensors Raw", const Icon(Icons.sensors, size: 48), 3),
    ];
    return [buildHeader(context, "Sensors"), Wrap(children: result)];
  }

  List<Widget> buildContent(BuildContext context) {
    List<Widget> result = [];
    result.addAll(buildDebug(context));
    result.addAll(buildSensors(context));
    return result;
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
            null,
            "More",
            actions: <Widget>[
              buildHomeButton(context),
            ],
            key: Key(getCurrentTitleKey()),
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
                        child: DesignColors.buildScrollBar(
                          controller: _scrollController,
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: buildContent(context),
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
          ),
        );
      },
    );
  }

  String txtNodeName = "";
  final TextEditingController _textFieldController = TextEditingController();

  int currentTitleKey = 0;
  void incrementTitleKey() {
    setState(() {
      currentTitleKey++;
    });
  }

  String getCurrentTitleKey() {
    return "units_" + currentTitleKey.toString();
  }
}
