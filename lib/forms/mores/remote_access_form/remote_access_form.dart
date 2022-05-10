import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/core/protocol/cloud/cloud_registered_nodes.dart';
import 'package:gazer_client/core/protocol/cloud/cloud_state.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/widgets/error_widget/error_block.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:gazer_client/widgets/title_widget/title_widget.dart';

class RemoteAccessForm extends StatefulWidget {
  final RemoteAccessFormArgument arg;
  const RemoteAccessForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return RemoteAccessFormSt();
  }
}

class RemoteAccessFormSt extends State<RemoteAccessForm> {
  late CloudRegisteredNodesItemResponse? currentCloudNode;

  late Timer _timerUpdate;
  late CloudStateResponse? _lastState;

  @override
  void initState() {
    _lastState = null;
    currentCloudNode = null;

    load();
    _timerUpdate = Timer.periodic(const Duration(seconds: 1), (t) {
      load();
    });

    Repository().client(widget.arg.connection).cloudState().then((value) {
      GazerLocalClient client = GazerLocalClient("updateCloudNodesList", "https/cloud", "", value.sessionKey);
      client.cloudRegisteredNode().then((value) {
        setState(() {});
      });
    });

    super.initState();
  }

  bool loading = false;
  bool loaded = false;
  String errorMessage = "";

  void load() {
    if (loading) {
      return;
    }
    loading = true;
    Repository().client(widget.arg.connection).cloudState().then((value) {
      setState(() {
        _lastState = value;
        loading = false;
        loaded = false;
        errorMessage = "";
      });
    }).catchError((e) {
      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    });
  }

  @override
  void dispose() {
    _timerUpdate.cancel();
    super.dispose();
  }

  Widget buildStateConnection(CloudStateResponse resp) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RichText(
            text: TextSpan(
              text: "Connection: ",
              children: <TextSpan>[
                TextSpan(
                  text: (resp.currentRepeater != "") ? resp.currentRepeater : "waiting for repeater",
                  style: TextStyle(color: (resp.currentRepeater != "") ? Colors.green : Colors.red),
                ),
                const TextSpan(
                  text: " / ",
                ),
                TextSpan(
                  text: (resp.connected) ? "ok" : resp.connectionStatus,
                  style: TextStyle(color: (resp.connected) ? Colors.green : Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStateLogin(CloudStateResponse resp) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: "User Name: ",
              children: <TextSpan>[
                TextSpan(
                  text: (resp.userName != "") ? resp.userName : "not provided",
                  style: TextStyle(color: (resp.userName != "") ? Colors.green : Colors.red),
                ),
                const TextSpan(
                  text: " / ",
                ),
                TextSpan(
                  text: (resp.loggedIn) ? "ok" : resp.loginStatus,
                  style: TextStyle(color: (resp.loggedIn) ? Colors.green : Colors.red),
                ),
              ],
            ),
          ),
          (_lastState != null && _lastState!.loggedIn)
              ? Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: OutlinedButton(
                    onPressed: () {
                      Repository().client(widget.arg.connection).cloudLogout().then((value) {
                        load();
                      });
                      //widget.arg.connection
                    },
                    child: const Text("Logout"),
                  ),
                )
              : Container(),
        ],
      ),
    );
  }

  Widget buildStateNode(CloudStateResponse resp) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(10),
      ),
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: "NodeId: ",
              children: <TextSpan>[
                TextSpan(
                  text: (resp.nodeId != "") ? resp.nodeId : "set node id",
                  style: TextStyle(color: (resp.nodeId != "") ? Colors.green : Colors.red),
                ),
                const TextSpan(
                  text: " / ",
                ),
                TextSpan(
                  text: (resp.loggedIn) ? resp.iAmStatus : "please log in",
                  style: TextStyle(color: (resp.loggedIn && resp.iAmStatus == "ok") ? Colors.green : Colors.red),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: OutlinedButton(
              onPressed: () {
                if (_lastState != null) {
                  GazerLocalClient client = GazerLocalClient("updateCloudNodesList", "https/cloud", "", _lastState!.sessionKey);
                  _futureServiceLookupNodeResponse = client.cloudRegisteredNode();
                  selectedIndex = -1;
                  _showLookupNodeDialog("Select node id", (nodeId) {
                    Repository().client(widget.arg.connection).cloudSetCurrentNodeId(nodeId);
                  });
                }
              },
              child: const Text("Change current node id"),
            ),
          )
        ],
      ),
    );
  }

  //final FocusScopeNode _focusNode = FocusScopeNode();

  String userName = "";
  String password = "";
  Widget buildLoginForm() {
    return FocusScope(
      child: Align(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                constraints: const BoxConstraints(maxWidth: 300),
                child: TextField(
                  autofocus: true,
                  decoration: const InputDecoration(labelText: "User Name"),
                  onChanged: (txt) {
                    userName = txt;
                  },
                ),
              ),
              Container(
                constraints: const BoxConstraints(maxWidth: 300),
                child: TextField(
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Password"),
                  onChanged: (txt) {
                    password = txt;
                  },
                ),
              ),
              Container(
                margin: const EdgeInsets.all(10),
                constraints: const BoxConstraints(maxWidth: 300),
                child: OutlinedButton(
                  onPressed: () {
                    Repository().client(widget.arg.connection).cloudLogin(userName, password).then((value) {
                      load();
                    });
                    load();
                  },
                  child: const Text("Login"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildFetched(BuildContext context) {
    if (loading) {
      return const Text("loading ...");
    }

    if (_lastState != null) {
      return ListView(
        children: [
          buildStateConnection(_lastState!),
          buildStateLogin(_lastState!),
          _lastState!.loggedIn || _lastState!.loginStatus == "processing" ? Container() : buildLoginForm(),
          _lastState!.loggedIn ? buildStateNode(_lastState!) : Container(),
          ErrorBlock(errorMessage),
        ],
      );
    }

    return const Text("no data");
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
            "Remote Access",
            actions: <Widget>[
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
                        child: buildFetched(context),
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

  late Future<CloudRegisteredNodesResponse> _futureServiceLookupNodeResponse;
  int selectedIndex = 1;
  String lookupSelectedItem = "";
  String lookupSelectedItem2 = "";

  Future<void> _showLookupNodeDialog(String text, Function(String) onLookupAccept) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(text),
              content: SingleChildScrollView(
                child: FutureBuilder<CloudRegisteredNodesResponse>(
                  future: _futureServiceLookupNodeResponse,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return DataTable(
                        headingRowColor: MaterialStateColor.resolveWith((states) => Colors.black26),
                        showCheckboxColumn: false,
                        rows: snapshot.data!.items.asMap().keys.map<DataRow>((rowIndex) {
                          var rows = snapshot.data!.items;
                          return DataRow(
                              selected: selectedIndex == rowIndex,
                              onSelectChanged: (bool? selected) {
                                setState(() {
                                  selectedIndex = rowIndex;
                                  lookupSelectedItem = rows[rowIndex].id;
                                  lookupSelectedItem2 = rows[rowIndex].name;
                                });
                              },
                              cells: [
                                DataCell(Text(rows[rowIndex].id)),
                                DataCell(Text(rows[rowIndex].name)),
                              ]);
                        }).toList(),
                        columns: const [
                          DataColumn(label: Text("Id")),
                          DataColumn(label: Text("Name")),
                        ],
                      );
                    } else if (snapshot.hasError) {
                      return const Text("Error");
                    }
                    return const Text("loading ...");
                  },
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    //print("$lookupParameter = $lookupSelectedItem");
                    //widget.config[lookupParameter] = lookupSelectedItem;
                    onLookupAccept(lookupSelectedItem);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
