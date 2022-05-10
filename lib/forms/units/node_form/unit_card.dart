import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/gazer_style.dart';
import 'package:gazer_client/core/protocol/unit/unit_state_all.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/widgets/borders/border_01_item.dart';

class UnitCard extends StatefulWidget {
  final Connection conn;
  final UnitStateAllItemResponse unitState;
  final Function onNavigate;
  final Function onRemove;

  const UnitCard(this.conn, this.unitState, this.onNavigate, this.onRemove, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UnitCardState();
  }
}

class UnitCardState extends State<UnitCard> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    double valueAndUOMFontSize = 14;
    var valueAndUOM = widget.unitState.value + " " + widget.unitState.uom;
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
                Border01Painter.build(hover),
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
                                    widget.unitState.unitName,
                                    style: TextStyle(fontSize: 14, color: DesignColors.fore()),
                                    overflow: TextOverflow.fade,
                                  ),
                                  Text(
                                    widget.unitState.unitId + " (" + widget.unitState.typeName + ")",
                                    style: TextStyle(fontSize: 14, color: DesignColors.fore2()),
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
                                  child: Text(
                                    widget.unitState.mainItem.replaceAll(widget.unitState.unitId + "/", ""),
                                    style: TextStyle(
                                      color: DesignColors.fore1(),
                                    ),
                                  ),
                                ),
                                Container(
                                  //margin: const EdgeInsets.only(top: 10),
                                  padding: const EdgeInsets.all(3),
                                  child: Text(
                                    valueAndUOM,
                                    style: TextStyle(
                                        fontSize: valueAndUOMFontSize,
                                        color: colorByUOM(widget.unitState.uom),
                                        fontWeight: fontWeightByUOM(widget.unitState.uom)),
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
                            color: DesignColors.fore2(),
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
      content: Text("Would you like to remove [${widget.unitState.unitName}]?"),
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
