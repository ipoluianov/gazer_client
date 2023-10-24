import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/gazer_style.dart';
import 'package:gazer_client/core/protocol/unit/unit_state_all.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/widgets/borders/border_01_item.dart';
import 'package:gazer_client/widgets/confirmation_dialog/confirmation_dialog.dart';

class UnitCard extends StatefulWidget {
  final Connection conn;
  final int index;
  final UnitStateAllItemResponse unitState;
  final Function onNavigate;
  final Function onRemove;
  final Function onStart;
  final Function onStop;

  const UnitCard(this.conn, this.index, this.unitState, this.onNavigate,
      this.onRemove, this.onStart, this.onStop,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UnitCardState();
  }
}

class UnitCardState extends State<UnitCard> with TickerProviderStateMixin {
  bool hover = false;

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  late final AnimationController _controller = AnimationController(
    vsync: this,
  )..animateTo(1,
      duration: Duration(
        milliseconds: 200 + widget.index * 40,
      ),
      curve: Curves.linear);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

  @override
  Widget build(BuildContext context) {
    double valueAndUOMFontSize = 14;
    var valueAndUOM = widget.unitState.value + " " + widget.unitState.uom;
    /*if (valueAndUOM.length > 20) {
      valueAndUOMFontSize = 16;
    }*/

    return ScaleTransition(
      scale: _animation,
      child: MouseRegion(
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
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: DesignColors.fore()),
                                      overflow: TextOverflow.fade,
                                    ),
                                    Text(
                                      "${widget.unitState.unitId} (${widget.unitState.typeName})",
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: DesignColors.fore2()),
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
                                      widget.unitState.mainItem.replaceAll(
                                          widget.unitState.unitId + "/", ""),
                                      style: TextStyle(
                                        color: DesignColors.fore1(),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    //margin: const EdgeInsets.only(top: 10),
                                    constraints:
                                        const BoxConstraints(maxHeight: 30),
                                    padding: const EdgeInsets.all(3),
                                    child: Text(
                                      valueAndUOM,
                                      style: TextStyle(
                                          fontSize: valueAndUOMFontSize,
                                          color:
                                              colorByUOM(widget.unitState.uom),
                                          fontWeight: fontWeightByUOM(
                                              widget.unitState.uom)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton(
                              shadowColor: DesignColors.fore(),
                              elevation: 20,
                              onSelected: (str) {
                                if (str == "remove") {
                                  showConfirmationDialog(
                                      context,
                                      "Confirmation",
                                      "Would you like to remove [ ${widget.unitState.unitName} ]?",
                                      () {
                                    widget.onRemove();
                                  });
                                }

                                if (str == "start") {
                                  widget.onStart();
                                }

                                if (str == "stop") {
                                  widget.onStop();
                                }
                              },
                              itemBuilder: (context) {
                                return <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                    value: "remove",
                                    child: Text('Remove Unit'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: "start",
                                    child: Text('Start Unit'),
                                  ),
                                  const PopupMenuItem<String>(
                                    value: "stop",
                                    child: Text('Stop Unit'),
                                  ),
                                ];
                              },
                              icon: Icon(
                                Icons.menu,
                                color: DesignColors.fore(),
                              ),
                              color: DesignColors.back(),
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
      ),
    );
  }
}
