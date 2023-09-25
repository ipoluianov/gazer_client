import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import '../../../core/design.dart';
import '../../../core/navigation/route_generator.dart';
import '../../../widgets/borders/border_10_node_item.dart';

class NodeWidget extends StatefulWidget {
  final Connection conn;
  final Function() onNavigate;
  final Function() onRemove;
  final Function(Connection conn) onChange;
  const NodeWidget(this.conn, this.onNavigate, this.onRemove, this.onChange,
      {Key? key})
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

  bool timerFastMode_ = true;
  late Timer _timerFast;
  int _timerFastCounter = 0;
  late Timer _timerSlow;

  @override
  void initState() {
    super.initState();
    setState(() {
      nodeName = widget.conn.lastName;
    });
    Repository().client(widget.conn).infoReceived =
        false; // Reset info in connection
    updateNodeInfo();

    _timerSlow = Timer.periodic(const Duration(milliseconds: 10000), (timer) {
      if (timerFastMode_) return;

      if (errorExists) {
        updateNodeInfo();
      }
    });
    _timerFast = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (!timerFastMode_) return;

      if (errorExists) {
        updateNodeInfo();
        _timerFastCounter++;
        if (_timerFastCounter > 5) {
          timerFastMode_ = false;
        }
      }
    });
  }

  @override
  void dispose() {
    _timerSlow.cancel();
    _timerFast.cancel();
    super.dispose();
  }

  void updateNodeInfo() {
    setState(() {
      status = "";
      errorExists = false;
    });
    Repository().client(widget.conn).serviceInfo().then((value) {
      if (mounted) {
        if (widget.conn.lastName != value.nodeName) {
          widget.conn.lastName = value.nodeName;
          wsEditConnection(widget.conn);
        }
        setState(() {
          nodeName = value.nodeName;
          status = value.version;
          errorExists = false;
          if (nodeName.isEmpty) {
            nodeName = "[noname]";
          }
        });
      }
    }).catchError((err) {
      if (mounted) {
        setState(() {
          nodeName = "";
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
    //double valueAndUOMFontSize = 14;
    //var valueAndUOM = widget.unitState.value + " " + widget.unitState.uom;
    /*if (valueAndUOM.length > 20) {
      valueAndUOMFontSize = 16;
    }*/

    Color indicatorColor = DesignColors.good();

    if (errorExists) {
      indicatorColor = DesignColors.bad();
    }

    if (status == "") {
      indicatorColor = DesignColors.fore2();
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
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
      child: GestureDetector(
        onTap: () {
          widget.onNavigate();
        },
        child: Container(
          margin: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
          //color: Colors.black12,
          child: Container(
            color: hover ? Colors.black12 : Colors.transparent,
            //padding: const EdgeInsets.all(10),
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),
            height: 120,
            child: Stack(
              children: [
                Border10Painter.build(
                  hover,
                  indicatorColor,
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.blur_on,
                            color: DesignColors.fore(),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    //"nodeName",
                                    nodeName,
                                    style: const TextStyle(fontSize: 14),
                                    overflow: TextOverflow.fade,
                                  ),
                                  Text(
                                    widget.conn.address,
                                    //widget.conn.transport + " : " + widget.conn.address,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.white24),
                                    overflow: TextOverflow.fade,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: 0.5,
                        color: DesignColors.back1(),
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
                          PopupMenuButton(
                            onSelected: (str) {
                              if (str == "remove") {
                                showAlertDialog(context);
                              }

                              if (str == "change") {
                                widget.onChange(widget.conn);
                              }
                            },
                            itemBuilder: (context) {
                              return <PopupMenuEntry<String>>[
                                const PopupMenuItem<String>(
                                  value: "change",
                                  child: Text('Change'),
                                ),
                                const PopupMenuItem<String>(
                                  value: "remove",
                                  child: Text('Remove'),
                                ),
                              ];
                            },
                            icon: Icon(
                              Icons.menu,
                              color: DesignColors.fore2(),
                            ),
                            color: DesignColors.back2(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
