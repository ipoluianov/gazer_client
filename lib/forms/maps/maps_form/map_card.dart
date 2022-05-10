import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/gazer_style.dart';
import 'package:gazer_client/core/protocol/resource/resource_list.dart';
import 'package:gazer_client/core/protocol/unit/unit_state_all.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

class MapCard extends StatefulWidget {
  final Connection conn;
  final ResListItemItemResponse mapItem;
  final List<ResListItemItemResponse> children;
  final Function onNavigate;
  final Function onRename;
  final Function onNeedUpdate;
  final Function onRemove;

  const MapCard(this.conn, this.mapItem, this.children, this.onNavigate, this.onRename, this.onNeedUpdate, this.onRemove, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapCardState();
  }
}

class MapCardState extends State<MapCard> {
  bool hover = false;

  bool loaded = false;

  @override
  void initState() {
    super.initState();
  }

  List<Widget> childrenWidgets() {
    List<Widget> res = [];
    for (int i = 0; i < widget.children.length && i < 4; i++) {
      res.add(Row(
        children: [
          const Icon(
            Icons.layers,
            size: 14,
          ),
          const SizedBox(
            width: 3,
          ),
          Text(
            widget.children[i].getProp("name"),
          ),
        ],
      ));
    }
    res.add(Expanded(child: Container()));
    res.add(Text("Total: ${widget.children.length}"));

    return res;
  }

  @override
  Widget build(BuildContext context) {
    //late final Uint8List _bytesImage = widget.mapItem.thumbnail;

    List<Widget> actionWidgets = [];

    if (widget.mapItem.type != "maps_folder") {
      actionWidgets.add(IconButton(
        onPressed: () {
          Repository()
              .client(widget.conn)
              .resPropSet(widget.mapItem.id, widget.mapItem.getProp("favorite").isNotEmpty ? {"favorite": ""} : {"favorite": "1"})
              .then((value) {
            widget.onNeedUpdate();
          });
        },
        icon: const Icon(Icons.favorite),
        color: widget.mapItem.getProp("favorite").isNotEmpty ? Colors.redAccent : Colors.white54,
      ));

      actionWidgets.add(IconButton(
        onPressed: () {
          Repository()
              .client(widget.conn)
              .resPropSet(widget.mapItem.id, widget.mapItem.getProp("template").isNotEmpty ? {"template": ""} : {"template": "1"})
              .then((value) {
            widget.onNeedUpdate();
          });
        },
        icon: const Icon(Icons.layers_outlined),
        color: widget.mapItem.getProp("template").isNotEmpty ? Colors.redAccent : Colors.white54,
      ));
    }
    actionWidgets.add(Expanded(child: Container()));
    actionWidgets.add(IconButton(
      onPressed: () {
        widget.onRename();
      },
      icon: const Icon(Icons.drive_file_rename_outline),
      color: Colors.white54,
    ));
    actionWidgets.add(IconButton(
      onPressed: () {
        showAlertDialog(context);
      },
      icon: const Icon(Icons.delete),
      color: Colors.white54,
    ));

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          widget.onNavigate();
        },
        child: Card(
          margin: const EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 5),
          color: Colors.black54,
          child: Container(
            padding: const EdgeInsets.all(0),
            constraints: const BoxConstraints(
              maxWidth: 400,
            ),
            height: 200,
            color: hover ? Colors.black54 : Colors.transparent,
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(0)),
              child: Container(
                color: Colors.grey.withOpacity(0.1),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          widget.mapItem.type == "map" ? Icons.layers : Icons.folder_open,
                          color: widget.mapItem.type == "map" ? Colors.blue : Colors.white38,
                          size: 36,
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                            color: Colors.black26,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.mapItem.getProp("name"),
                                  style: const TextStyle(fontSize: 14),
                                  overflow: TextOverflow.fade,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    widget.mapItem.type == "map"
                        ? Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              child: Text(
                                widget.mapItem.getProp("description"),
                              ),
                            ),
                          )
                        : Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
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
      content: Text("Would you like to remove [${widget.mapItem.getProp("name")}]?"),
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
