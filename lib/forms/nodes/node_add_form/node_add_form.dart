import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/core/protocol/cloud/cloud_registered_nodes.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/navigation/route_generator.dart';
import 'node_add_form_bloc.dart';

class NodeAddForm extends StatefulWidget {
  final NodeAddFormArgument arg;
  const NodeAddForm({Key? key, required this.arg}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NodeAddFormSt();
  }
}

class NodeAddFormSt extends State<NodeAddForm> {
  late NodeAddFormCubit cubit;
  final GazerLocalClient cl = GazerLocalClient("new", "", "", "");
  bool firstAccountLoaded = false;

  final TextEditingController _txtControllerHost = TextEditingController();
  final TextEditingController _txtControllerUser = TextEditingController();
  final TextEditingController _txtControllerPassword = TextEditingController();

  final TextEditingController _txtControllerCloudUser = TextEditingController();
  final TextEditingController _txtControllerCloudPassword = TextEditingController();

  late CloudAccount? currentCloudAccount;
  late CloudRegisteredNodesItemResponse? currentCloudNode;

  late Future<List<CloudAccount>> _cloudAccountsFuture;
  late Future<CloudRegisteredNodesResponse> _cloudNodes;

  int newConnectionMode = 0;
  String connectionError = "";

  @override
  void initState() {
    super.initState();

    if (widget.arg.toCloud) {
      newConnectionMode = 1;
    } else {
      newConnectionMode = 0;
    }

    cubit = NodeAddFormCubit(NodeAddFormStateLoading());

    cubit.load();

    _cloudAccountsFuture = wsGetCloudAccounts();
    currentCloudAccount = null;
    currentCloudNode = null;
    _cloudNodes = cl.cloudRegisteredNode();
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
          if (newConnectionMode == 0) {
            cl.transport = "http/local";
            cl.address = _txtControllerHost.text;

            cl.sessionOpen(_txtControllerUser.text, _txtControllerPassword.text).then((value) {
              cl.session = value.sessionToken;
              cl.isValid = true;
              //widget.onAdd("");
              wsAddConnection(Connection(UniqueKey().toString(), cl.transport, cl.address, cl.session)).then((value) {
                Navigator.pop(context, true);
              });
            }).catchError((ex) {
              setState(() {
                connectionError = '$ex';
              });
            });
          } else {
            if (currentCloudNode != null) {
              cl.isValid = true;
              //widget.onAdd("");
              wsAddConnection(Connection(UniqueKey().toString(), cl.transport, cl.address, cl.session)).then((value) {
                Navigator.pop(context, true);
              });
            } else {
              setState(() {
                connectionError = 'no node selected';
              });
            }
          }
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
          SizedBox(
            width: 200,
            child: TextField(
              controller: _txtControllerPassword,
              decoration: const InputDecoration(
                labelText: "Password",
              ),
              obscureText: true,
            ),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  _txtControllerHost.text = "localhost";
                  _txtControllerUser.text = "admin";
                  loadLocalAdminPassword().then((value) {
                    _txtControllerPassword.text = value;
                  });
                },
                child: const Text(
                  "Load local node default credentials",
                  style: TextStyle(decoration: TextDecoration.underline, color: Colors.blue),
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

  Widget buildNodesList() {
    return Container(
        child: FutureBuilder(
      future: _cloudNodes,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return DropdownButton<CloudRegisteredNodesItemResponse>(
            onChanged: (CloudRegisteredNodesItemResponse? newValue) {
              setState(() {
                currentCloudNode = newValue;
                cl.address = newValue!.id;
              });
            },
            value: currentCloudNode,
            items: (snapshot.data! as CloudRegisteredNodesResponse).items.map<DropdownMenuItem<CloudRegisteredNodesItemResponse>>((v) {
              return DropdownMenuItem(
                value: v,
                child: Container(
                  constraints: BoxConstraints(minWidth: 200, maxWidth: 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        v.id,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: Colors.white10),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        } else if (snapshot.hasError) {
          return SizedBox(
            width: 200,
            child: Text(
              snapshot.error.toString(),
              style: const TextStyle(
                color: Colors.redAccent,
              ),
            ),
          );
        } else {
          return const Text("loading nodes ...");
        }
      },
    ));
  }

  void loadCloudAccount() {}

  Widget buildCloud() {
    return Container(
      constraints: const BoxConstraints(minWidth: 250, minHeight: 300),
      child: Column(
        children: [
          FutureBuilder(
            future: _cloudAccountsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if ((snapshot.data! as List<CloudAccount>).isEmpty) {
                  return buildAddCloudAccount();
                } else {
                  var listOfAccounts = (snapshot.data! as List<CloudAccount>);
                  if (!firstAccountLoaded && listOfAccounts.isNotEmpty) {
                    firstAccountLoaded = true;
                    currentCloudNode = null;
                    currentCloudAccount = listOfAccounts[0];
                    cl.transport = "https/cloud";
                    cl.session = listOfAccounts[0].sessionKey;
                    _cloudNodes = cl.cloudRegisteredNode();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DropdownButton<CloudAccount>(
                        onChanged: (CloudAccount? newValue) {
                          setState(() {
                            currentCloudNode = null;
                            currentCloudAccount = newValue;
                            cl.transport = "https/cloud";
                            cl.session = newValue!.sessionKey;
                            _cloudNodes = cl.cloudRegisteredNode();
                          });
                        },
                        value: currentCloudAccount,
                        items: (snapshot.data! as List<CloudAccount>).map<DropdownMenuItem<CloudAccount>>((v) {
                          return DropdownMenuItem(
                            value: v,
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 200),
                              child: Column(
                                children: [
                                  Text(
                                    v.userName,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    v.sessionKey,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      buildNodesList(),
                      buildAddNodeButton(),
                    ],
                  );
                }
              } else if (snapshot.hasError) {
                return SizedBox(
                  width: 200,
                  child: Text(
                    '${snapshot.error}',
                    style: const TextStyle(
                      color: Colors.redAccent,
                    ),
                  ),
                );
              } else {
                return const Text("loading ...");
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildAddCloudAccount() {
    return Container(
      padding: EdgeInsets.all(10),
      constraints: BoxConstraints(minWidth: 200, minHeight: 200),
      child: Column(
        children: [
          SizedBox(
            width: 200,
            child: TextField(
              controller: _txtControllerCloudUser,
              decoration: const InputDecoration(
                labelText: "User email",
              ),
            ),
          ),
          SizedBox(
            width: 200,
            child: TextField(
              controller: _txtControllerCloudPassword,
              decoration: const InputDecoration(
                labelText: "Password",
              ),
              obscureText: true,
            ),
          ),
          const SizedBox(
            height: 50,
          ),
          SizedBox(
            width: 100,
            height: 44,
            child: ElevatedButton(
              onPressed: () {
                cl.transport = "https/cloud";
                cl.address = "0";
                cl.sessionOpen(_txtControllerCloudUser.text, _txtControllerCloudPassword.text).then((value) {
                  print("SessionID: ${value.sessionToken}");
                  wsAddCloudAccounts(CloudAccount(_txtControllerCloudUser.text, value.sessionToken)).then((value) {
                    setState(() {
                      _cloudAccountsFuture = wsGetCloudAccounts();
                    });
                  });
                }).catchError((ex) {
                  setState(() {
                    connectionError = ex.message;
                  });
                });
              },
              child: const Text(
                "connect to cloud",
                textAlign: TextAlign.center,
              ),
            ),
          ),
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
              decoration: const BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.all(Radius.circular(10))),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            newConnectionMode = 0;
                          });
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            newConnectionMode == 0 ? Colors.black38 : Colors.black12,
                          ),
                        ),
                        child: Container(
                          width: 100,
                          height: 50,
                          child: const Center(
                            child: Text("DIRECT"),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(
                            () {
                              newConnectionMode = 1;
                            },
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            newConnectionMode == 1 ? Colors.black38 : Colors.black12,
                          ),
                        ),
                        child: Container(
                          width: 100,
                          height: 50,
                          child: const Center(
                            child: Text("CLOUD"),
                          ),
                        ),
                      ),
                    ],
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      if (newConnectionMode == 0) {
                        return buildLocal();
                      } else {
                        return buildCloud();
                      }
                    },
                  ),
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
                    BlocBuilder<NodeAddFormCubit, NodeAddFormState>(
                      bloc: cubit,
                      builder: (context, state) {
                        if (state is NodeAddFormStateLoading) {
                          return buildMain();
                        }

                        if (state is NodeAddFormStateLoaded) {
                          NodeAddFormStateLoaded stateLoaded = state;
                          return const Expanded(
                            child: Text("New Node"),
                          );
                        }

                        return Text("Unknown state");
                      },
                    ),
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

  Future<String> loadLocalAdminPassword() async {
    String text = "";
    Permission.storage.request();
    try {
      final File file = File('${gazerDataDirectory()}/default_admin_password.txt');
      print("111");
      var stream = file.openRead();
      text = await file.readAsString();
      print("222");
    } catch (e) {

      print("error: ${e.toString()}");
    }
    return text;
  }
}
