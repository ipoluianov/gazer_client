import 'package:flutter/material.dart';
import 'package:gazer_client/core/gazer_style.dart';
import 'package:gazer_client/core/protocol/unit/unit_state_all.dart';
import 'package:gazer_client/core/protocol/user/user_prop_get.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

class UserCard extends StatefulWidget {
  final Connection connection;
  final String userName;
  final Function onNavigate;
  final Function onRemove;

  const UserCard(this.connection, this.userName, this.onNavigate, this.onRemove, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UserCardState();
  }
}

class UserCardState extends State<UserCard> {
  bool hover = false;

  @override
  void initState() {
    super.initState();
    _response = UserPropGetResponse.makeDefault();
    load();
  }

  late UserPropGetResponse _response;

  bool loaded = false;
  bool loading = false;
  String errorMessage = "";

  void load() {
    if (loading) {
      return;
    }
    loading = true;
    Repository().client(widget.connection).userPropGet(widget.userName).then((value) {
      setState(() {
        _response = value;
      });
    }).catchError((e){
      setState(() {
        errorMessage = e.toString();
        loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double valueAndUOMFontSize = 14;
    //var valueAndUOM = widget.unitState.value + " " + widget.unitState.uom;
    var valueAndUOM = "";
    /*if (valueAndUOM.length > 20) {
      valueAndUOMFontSize = 16;
    }*/

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
              maxWidth: 400,
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
                      Icons.account_circle,
                      color: Colors.blue,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(left: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.userName,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.fade,
                            ),
                            Text(
                              _response.getProp("display_name"),
                              style: const TextStyle(fontSize: 14, color: Colors.white24),
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
                            child: Container(
                              child: Text(
                                valueAndUOM,
                                /*style: TextStyle(
                                    fontSize: valueAndUOMFontSize, color: colorByUOM(widget.unitState.uom), fontWeight: fontWeightByUOM(widget.unitState.uom)),*/
                              ),
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
      content: Text("Would you like to remove [${widget.userName}]?"),
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
