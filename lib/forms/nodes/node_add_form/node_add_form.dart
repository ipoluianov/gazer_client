import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/navigation/route_generator.dart';

class NodeAddForm extends StatefulWidget {
  final NodeAddFormArgument arg;
  const NodeAddForm({Key? key, required this.arg}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NodeAddFormSt();
  }
}

class NodeAddFormSt extends State<NodeAddForm> {
  final GazerLocalClient cl = GazerLocalClient("new", "", "", "");
  bool firstAccountLoaded = false;

  final TextEditingController _txtControllerHost = TextEditingController();
  final TextEditingController _txtControllerUser = TextEditingController();
  //final TextEditingController _txtControllerPassword = TextEditingController();

  String connectionError = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildAddNodeButton() {
    return SizedBox(
      width: 130,
      height: 36,
      child: ElevatedButton(
        onPressed: () {
          cl.transport = "http/local";
          cl.address = _txtControllerHost.text;
          cl.session = _txtControllerUser.text;
            wsAddConnection(Connection(UniqueKey().toString(), cl.transport,
                    cl.address, cl.session))
                .then((value) {
              Navigator.pop(context, true);
            });
        },
        child: Text("Add node"),
      ),
    );
  }

  Widget buildLocal() {
    return Container(
      padding: EdgeInsets.all(10),
      constraints: BoxConstraints(minWidth: 250, minHeight: 300),
      child: Column(
        children: [
          SizedBox(
            width: 200,
            child: TextField(
              autofocus: true,
              controller: _txtControllerHost,
              decoration: const InputDecoration(
                labelText: "Host",
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: 200,
            child: TextField(
              controller: _txtControllerUser,
              decoration: const InputDecoration(
                labelText: "User",
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  //_txtControllerHost.text = "localhost";
                  //_txtControllerUser.text = "admin";
                  loadLocalAdminPassword().then((result) {
                    _txtControllerHost.text = result[0];
                    _txtControllerUser.text = result[1];
                  });
                },
                child: const Text(
                  "Load local node default credentials",
                  style: TextStyle(
                      decoration: TextDecoration.underline, color: Colors.blue),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 0,
          ),
          buildAddNodeButton(),
        ],
      ),
    );
  }

  Widget buildMain() {
    return Expanded(
      child: ListView(children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              decoration: const BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  buildLocal(),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                    width: 200,
                    child: Text(
                      connectionError,
                      style: const TextStyle(
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ]),
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
            Connection.makeDefault(),
            "Connect To Node",
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    buildMain(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String homeDirectory() {
    String os = Platform.operatingSystem;
    String? home = "";
    Map<String, String> envVars = Platform.environment;
    if (Platform.isMacOS) {
      home = envVars['HOME'];
    } else if (Platform.isLinux) {
      home = envVars['HOME'];
    } else if (Platform.isWindows) {
      home = envVars['UserProfile'];
    }
    if (home == null) {
      return "/";
    }
    return home;
  }

  static String gazerDataDirectory() {
    String result = "";

    String os = Platform.operatingSystem;
    String varDir = "";
    Map<String, String> envVars = Platform.environment;
    if (Platform.isMacOS) {
      varDir = "/var";
    } else if (Platform.isLinux) {
      varDir = "/var";
    } else if (Platform.isWindows) {
      if (envVars['PROGRAMDATA'] != null) {
        varDir = envVars['PROGRAMDATA']!;
      }
    }
    result = varDir + "/gazer";
    return result;
  }

  Future<List<String>> loadLocalAdminPassword() async {
    String address = "";
    String masterKey = "";
    Permission.storage.request();
    try {
      final File file =
          File('${gazerDataDirectory()}/address.txt');
      var stream = file.openRead();
      address = await file.readAsString();
    } catch (e) {
      print("error: ${e.toString()}");
    }
    try {
      final File file =
          File('${gazerDataDirectory()}/masterkey.txt');
      var stream = file.openRead();
      masterKey = await file.readAsString();
    } catch (e) {
      print("error: ${e.toString()}");
    }
    return [address, masterKey];
  }
}
