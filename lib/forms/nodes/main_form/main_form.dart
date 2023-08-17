import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/nodes/main_form/node_widget.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  //MainFormCubit bloc = MainFormCubit(MainFormState([]));

  List<Connection> connections = [];

  int updateCounter = 0;
  ScrollController scrollController1 = ScrollController();
  ScrollController scrollController2 = ScrollController();

  bool peerLoaded = false;
  void initPeer() async {
    await Future.delayed(const Duration(milliseconds: 500));
    loadPeer().then((value) {
      setState(() {
        peerLoaded = true;
      });
      addLocalConnection().then((value) {
        if (value is Connection) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.of(context).pop();
          Navigator.pushNamed(context, "/node",
              arguments: NodeFormArgument(value));
          return;
        }
        loadNodesList();
      });
    });
  }

  @override
  void initState() {
    print("================ initState ==============");

    super.initState();

    initPeer();

    requestVersion();
  }

  PackageInfo? packageInfo;

  void requestVersion() {
    PackageInfo.fromPlatform().then((value) {
      setState(() {
        packageInfo = value;
      });
    }).catchError((err) {});
  }

  bool loading = true;
  void loadNodesList() async {
    setState(() {
      loading = true;
      connections = [];
    });

    SharedPreferences.getInstance().then((prefs) {
      var wsContent = prefs.getString("ws") ?? "{}";
      try {
        late Workspace ws;
        ws = Workspace.fromJson(jsonDecode(wsContent));
        for (var conn in ws.connections) {
          connections.add(conn);
        }
      } catch (ex) {
        // TODO: show error
      }
      setState(() {
        loading = false;
      });
    }).catchError((err) {
      // TODO: show error
      setState(() {
        loading = false;
      });
    });
  }

  Widget buildNodeList(BuildContext context) {
    return Expanded(
      child: Scrollbar(
        controller: scrollController1,
        thumbVisibility: false,
        child: SingleChildScrollView(
          controller: scrollController1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                child: Wrap(
                  children: connections.map<Widget>((e) {
                    return NodeWidget(e, () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      Navigator.of(context).pop();
                      Navigator.pushNamed(context, "/node",
                          arguments: NodeFormArgument(e));
                    }, () {
                      wsRemoveConnection(e.id).then((value) {
                        loadNodesList();
                      });
                    }, key: Key(e.id + updateCounter.toString()));
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEmptyNodeList(context) {
    return Expanded(
      child: Scrollbar(
        controller: scrollController2,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: scrollController2,
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
                      "Connect via XCHG",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white30,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          addNode(false);
                        },
                        child: Container(
                          child: const Text("CONNECT"),
                          padding: EdgeInsets.all(20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildContent(BuildContext context) {
    if (loading) {
      return Expanded(
        child: Container(
          color: Colors.black26,
          child: const Center(
              child: Text(
            "loading",
            style: TextStyle(
              color: Colors.blue,
              fontFamily: "BrunoAce",
              fontSize: 36,
            ),
          )),
        ),
      );
    }

    if (connections.isNotEmpty) {
      return buildNodeList(context);
    }
    return buildEmptyNodeList(context);
  }

  void addNode(bool toCloud) {
    Navigator.pushNamed(context, "/node_add",
            arguments: NodeAddFormArgument(toCloud))
        .then(
      (value) {
        updateCounter++;
        loadNodesList();
        if (value is Connection) {
          Navigator.of(context).popUntil((route) => route.isFirst);
          Navigator.of(context).pop();
          Navigator.pushNamed(context, "/node",
              arguments: NodeFormArgument(value));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("================ build ==============");
    return LayoutBuilder(
      builder: (context, constraints) {
        bool narrow = constraints.maxWidth < 600;
        bool showLeft = !narrow;
        bool showBottom = narrow;

        String version = "";

        if (packageInfo != null) {
          version = packageInfo!.version;
        }

        List<Widget> actions = [];

        if (!loading) {
          actions = <Widget>[
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
                loadNodesList();
              },
            ),
          ];
        }

        return Scaffold(
          appBar: TitleBar(
            null,
            "Nodes Gazer.Cloud",
            version: version,
            actions: actions,
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
                      buildContent(context),
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
