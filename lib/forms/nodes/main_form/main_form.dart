import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/nodes/main_form/main_form_bloc.dart';
import 'package:gazer_client/forms/nodes/main_form/node_widget.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:gazer_client/xchg/xchg_connection.dart';

import '../../../core/workspace/add_local_connection.dart';
import '../../../core/navigation/bottom_navigator.dart';
import '../../../core/navigation/left_navigator.dart';
import '../../../core/navigation/navigation.dart';

class MainForm extends StatefulWidget {
  const MainForm({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MainFormSt();
  }
}

class MainFormSt extends State<MainForm> {
  MainFormCubit bloc = MainFormCubit(MainFormState([]));
  int updateCounter = 0;

  @override
  void initState() {
    super.initState();
    //conn.call("", Uint8List(0));

    addLocalConnection().then((value) {
      if (value is Connection) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).pop();
        Navigator.pushNamed(context, "/node", arguments: NodeFormArgument(value));
        return;
      }

      bloc.load();
    });
  }

  Widget buildNodeList(BuildContext context, MainFormState state) {
    return Expanded(
      child: Scrollbar(
        isAlwaysShown: true,
        child: SingleChildScrollView(
          child: Wrap(
            children: state.connections.map<Widget>((e) {
              return NodeWidget(e, () {
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context).pop();
                Navigator.pushNamed(context, "/node", arguments: NodeFormArgument(e));
              }, () {
                bloc.remove(e.id);
              }, key: Key(e.id + updateCounter.toString()));
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget buildEmptyNodeList(context, state) {
    return Expanded(
      child: Scrollbar(
        isAlwaysShown: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: const Text(
                  "No nodes to display",
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
                      "Connect to the node via GazerCloud",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white30,
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 5),
                        child: ElevatedButton(
                            onPressed: () {
                              addNode(true);
                            },
                            child: const Text("Connect via GazerCloud"))),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    const Text(
                      "Direct connect to the node via LAN",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white30,
                      ),
                    ),
                    Container(
                        margin: const EdgeInsets.only(top: 5),
                        child: ElevatedButton(
                            onPressed: () {
                              addNode(false);
                            },
                            child: const Text("Direct Connect"))),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context, MainFormState state) {
    if (state.connections.isNotEmpty) {
      return buildNodeList(context, state);
    }
    return buildEmptyNodeList(context, state);
  }

  void addNode(bool toCloud) {
    Navigator.pushNamed(context, "/node_add", arguments: NodeAddFormArgument(toCloud)).then(
      (value) {
        updateCounter++;
        bloc.load();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool narrow = constraints.maxWidth < 600;
        bool showLeft = !narrow;
        bool showBottom = narrow;

        return Scaffold(
          appBar: TitleBar(
            Connection.makeDefault(), "Nodes Gazer.Cloud",
            actions: <Widget>[
              buildActionButton(
                context,
                Icons.add,
                "Add Node",
                    () {
                  addNode(true);
                },
              ),
              buildActionButton(
                context,
                Icons.refresh,
                "Refresh",
                    () {
                  updateCounter++;
                  bloc.load();
                },
              ),
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
                    const LeftNavigator(false),
                    BlocBuilder<MainFormCubit, MainFormState>(
                      bloc: bloc,
                      builder: (context, state) {
                        return buildContent(context, state);
                      },
                    ),
                  ],
                ),
              ),
              const BottomNavigator(false),
            ],
          ),
          ),
        );
      },
    );
  }
}
