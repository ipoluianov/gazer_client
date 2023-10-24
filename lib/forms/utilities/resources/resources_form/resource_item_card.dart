import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/gazer_style.dart';
import 'package:gazer_client/core/protocol/resource/resource_list.dart';
import 'package:gazer_client/core/protocol/unit/unit_state_all.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/widgets/borders/border_01_item.dart';
import 'package:gazer_client/widgets/confirmation_dialog/confirmation_dialog.dart';

import '../../../../widgets/error_dialog/error_dialog.dart';

class ResourceItemCard extends StatefulWidget {
  final Connection conn;
  final ResListItemItemResponse resItem;
  final IconData iconData;
  final List<ResListItemItemResponse> children;
  final Function onNavigate;
  final Function onRename;
  final Function onFolderUp;
  final Function onNeedUpdate;
  final Function onRemove;
  final Function onGetInfo;
  final int index;

  const ResourceItemCard(
      this.conn,
      this.index,
      this.resItem,
      this.iconData,
      this.children,
      this.onNavigate,
      this.onRename,
      this.onFolderUp,
      this.onNeedUpdate,
      this.onRemove,
      this.onGetInfo,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ResourceItemCardState();
  }
}

class ResourceItemCardState extends State<ResourceItemCard>
    with TickerProviderStateMixin {
  bool hover = false;

  bool loaded = false;

  @override
  void initState() {
    super.initState();
  }

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

  List<Widget> childrenWidgets() {
    List<Widget> res = [];
    for (int i = 0; i < widget.children.length && i < 4; i++) {
      res.add(Row(
        children: [
          Icon(
            widget.children[i].type.endsWith("_folder")
                ? Icons.folder_open
                : widget.iconData,
            size: 14,
            color: DesignColors.fore1(),
          ),
          const SizedBox(
            width: 3,
          ),
          Text(
            widget.children[i].getProp("name"),
            style: TextStyle(color: DesignColors.fore1()),
          ),
        ],
      ));
    }

    if (widget.children.length > 4) {
      res.add(
        Text(
          "...",
          style: TextStyle(color: DesignColors.fore1()),
        ),
      );
    }

    res.add(Expanded(child: Container()));

    return res;
  }

  Widget header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          widget.resItem.type.endsWith("_folder")
              ? Icons.folder_open
              : widget.iconData,
          color: !widget.resItem.type.endsWith("_folder")
              ? DesignColors.fore()
              : DesignColors.fore1(),
          size: 36,
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
            //color: Colors.black26,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.resItem.getProp("name"),
                  style: TextStyle(
                      fontSize: 14,
                      decoration: TextDecoration.none,
                      color: DesignColors.fore(),
                      fontWeight: FontWeight.normal),
                  overflow: TextOverflow.fade,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget dragFeedback() {
    return Container(
      //color: Colors.deepOrange,
      decoration: BoxDecoration(
        color: Colors.black38,
        border: Border.all(width: 1, color: DesignColors.fore()),
      ),
      width: 300,
      child: header(),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> actionWidgets = [];

    if (!widget.resItem.type.endsWith("_folder")) {
      actionWidgets.add(IconButton(
        onPressed: () {
          Repository()
              .client(widget.conn)
              .resPropSet(
                  widget.resItem.id,
                  widget.resItem.getProp("favorite").isNotEmpty
                      ? {"favorite": ""}
                      : {"favorite": "1"})
              .then((value) {
            widget.onNeedUpdate();
          }).catchError((err) {
            showErrorDialog(context, "$err");
          });
        },
        icon: const Icon(Icons.favorite),
        color: widget.resItem.getProp("favorite").isNotEmpty
            ? DesignColors.accent()
            : DesignColors.fore2(),
      ));
    } else {
      actionWidgets.add(
        Container(
          padding: const EdgeInsets.only(left: 6),
          child: Text(
            "Total: ${widget.children.length}",
            style: TextStyle(color: DesignColors.fore1()),
          ),
        ),
      );
    }
    actionWidgets.add(Expanded(child: Container()));

    actionWidgets.add(
      PopupMenuButton(
        shadowColor: DesignColors.fore(),
        elevation: 20,
        onSelected: (str) {
          if (str == "remove") {
            if (widget.children.isEmpty) {
              showConfirmationDialog(context, "Confirmation",
                  "Would you like to remove [${widget.resItem.getProp("name")}]?",
                  () {
                widget.onRemove();
              });
            } else {
              showCanNotRemoveDialog(context);
            }
          }

          if (str == "change") {
            widget.onRename();
          }

          if (str == "up") {
            widget.onFolderUp();
          }

          if (str == "info") {
            widget.onGetInfo();
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
            const PopupMenuItem<String>(
              value: "up",
              child: Text('Move To Root Folder'),
            ),
            const PopupMenuItem<String>(
              value: "info",
              child: Text('Get Info'),
            ),
          ];
        },
        icon: Icon(
          Icons.menu,
          color: DesignColors.fore(),
        ),
        color: DesignColors.back(),
      ),
    );

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
              height: 210,
              child: Stack(
                children: [
                  Border01Painter.build(hover),
                  Container(
                    padding: EdgeInsets.all(10),
                    //color: Colors.grey.withOpacity(0.1),
                    //alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Draggable<ResListItemItemResponse>(
                          data: widget.resItem,
                          feedback: dragFeedback(),
                          child: header(),
                        ),
                        !widget.resItem.type.endsWith("_folder")
                            ? Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  child: Text(
                                    widget.resItem.getProp("description"),
                                    style:
                                        TextStyle(color: DesignColors.fore1()),
                                  ),
                                ),
                              )
                            : Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: childrenWidgets(),
                                  ),
                                ),
                              ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: actionWidgets,
                        )
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

  showCanNotRemoveDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = OutlinedButton(
      child: const SizedBox(width: 70, child: Center(child: Text("Cancel"))),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Error"),
      content: const Text("Folder not empty"),
      actions: [
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
