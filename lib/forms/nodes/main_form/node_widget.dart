import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

class NodeWidget extends StatefulWidget {
  final Connection conn;
  final Function() onNavigate;
  final Function() onRemove;
  const NodeWidget(this.conn, this.onNavigate, this.onRemove, {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NodeWidgetSt();
  }
}

class NodeWidgetSt extends State<NodeWidget> {
  bool hover = false;
  String nodeName = "";
  String status = "";
  bool errorExists = false;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    setState(() {
      nodeName = widget.conn.address;
    });
    Repository().client(widget.conn).infoReceived =
        false; // Reset info in connection
    updateNodeInfo();

    _timer = Timer.periodic(const Duration(milliseconds: 5000), (timer) {
      if (errorExists) {
        updateNodeInfo();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void updateNodeInfo() {
    setState(() {
      status = "";
      errorExists = false;
    });
    Repository().client(widget.conn).serviceInfo().then((value) {
      if (mounted) {
        setState(() {
          nodeName = value.nodeName;
          status = value.version;
          errorExists = false;
        });
      }
    }).catchError((err) {
      if (mounted) {
        setState(() {
          nodeName = widget.conn.address;
          status = err.toString();
          errorExists = true;
        });
      }
    });
  }

  Widget buildStatus() {
    if (status != "") {
      return Container(
        constraints: const BoxConstraints(maxHeight: 50),
        child: Container(
          child: Text(
            status,
            style: TextStyle(
                fontSize: 12, color: errorExists ? Colors.red : Colors.green),
          ),
        ),
      );
    }

    return Container(
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 20, maxHeight: 20),
          child: const CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget buildContent() {
    return const Text("");
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hover = true;
        });
      },
      onExit: (_) {
        setState(() {
          hover = false;
        });
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget.onNavigate();
        },
        child: Card(
          margin: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
          color: Colors.black12,
          child: Container(
            color: hover ? Colors.black12 : Colors.transparent,
            padding: const EdgeInsets.all(10),
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),
            height: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      (widget.conn.transport == "http/local")
                          ? Icons.computer
                          : Icons.cloud_queue,
                      color: Colors.blue,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "nodeName",
                              //nodeName,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.fade,
                            ),
                            Text(
                              "---",
                              //widget.conn.transport + " : " + widget.conn.address,
                              style: const TextStyle(
                                  fontSize: 14, color: Colors.white24),
                              overflow: TextOverflow.fade,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 1,
                  color: Colors.white24,
                  margin: const EdgeInsets.only(top: 10),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            //margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(3),
                            child: buildStatus(),
                          ),
                          Container(
                            //margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(3),
                            child: const Text(
                              "Node",
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showAlertDialog(context);
                      },
                      icon: const Icon(Icons.delete),
                      color: Colors.white54,
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildOriginal(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          hover = true;
        });
      },
      onExit: (_) {
        setState(() {
          hover = false;
        });
      },
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget.onNavigate();
        },
        child: Card(
          margin: const EdgeInsets.all(10),
          child: Container(
            padding: const EdgeInsets.all(6),
            color: hover ? Colors.black12 : Colors.transparent,
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Text(
                    nodeName,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                buildStatus(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        widget.conn.transport + " : " + widget.conn.address,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white60),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          showAlertDialog(context);
                        },
                        icon: const Icon(Icons.delete))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = OutlinedButton(
      child: const SizedBox(width: 70, child: Center(child: Text("Cancel"))),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = OutlinedButton(
      child: const SizedBox(width: 70, child: Center(child: Text("Remove"))),
      onPressed: () {
        Navigator.of(context).pop();
        widget.onRemove();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Confirmation"),
      content: Text("Would you like to remove [${widget.conn.address}]?"),
      actions: [
        continueButton,
        cancelButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
