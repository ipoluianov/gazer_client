import 'package:flutter/material.dart';
import 'package:gazer_client/core/gazer_style.dart';
import 'package:gazer_client/core/protocol/unit/unit_state_all.dart';
import 'package:gazer_client/core/protocol/user/session_list.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:intl/intl.dart';

class SessionCard extends StatefulWidget {
  final Connection conn;
  final SessionListItemResponse session;
  final Function onNavigate;
  final Function onRemove;

  const SessionCard(this.conn, this.session, this.onNavigate, this.onRemove, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return SessionCardState();
  }
}

class SessionCardState extends State<SessionCard> {
  bool hover = false;

  DateFormat timeFormat = DateFormat("yyyy-MM-dd HH:mm:ss");

  @override
  Widget build(BuildContext context) {
    var valueAndUOM = timeFormat.format(DateTime.fromMicrosecondsSinceEpoch(widget.session.sessionOpenTime));

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
        child: Card(
          margin: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
          color: Colors.black12,
          child: Container(
            color: hover ? Colors.black12 : Colors.transparent,
            padding: const EdgeInsets.all(10),
            constraints: const BoxConstraints(
              maxWidth: 300,
            ),
            height: 120,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.vpn_key_rounded,
                      color: Colors.blue,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              valueAndUOM,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.fade,
                            ),
                            Text(
                              widget.session.userName,
                              style: TextStyle(fontSize: 14, color: Colors.white24),
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
                            child: const Text(
                              "session_key:",
                              style: TextStyle(
                                color: Colors.white24,
                              ),
                            ),
                          ),
                          Container(
                            //margin: const EdgeInsets.only(top: 10),
                            padding: const EdgeInsets.all(3),
                            child: Text(
                              widget.session.sessionToken.length > 6 ? widget.session.sessionToken.substring(0, 5) + " ..." : " ...",
                              /*style: TextStyle(
                                  fontSize: valueAndUOMFontSize, color: colorByUOM(widget.unitState.uom), fontWeight: fontWeightByUOM(widget.unitState.uom)),*/
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
      content: Text("Would you like to remove [${widget.session.sessionToken}]?"),
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
