import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/gazer_style.dart';
import 'package:gazer_client/core/protocol/resource/resource_list.dart';
import 'package:gazer_client/core/protocol/unit/unit_state_all.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';

import 'map_item_add_form.dart';

class MapItemCard extends StatefulWidget {
  final Connection conn;
  final MapItemAddFormItem mapItem;
  final Function onNavigate;

  const MapItemCard(this.conn, this.mapItem, this.onNavigate, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemCardState();
  }
}

class MapItemCardState extends State<MapItemCard> {
  bool hover = false;
  late Uint8List _bytesImage;

  @override
  void initState() {
    super.initState();
    _bytesImage = Uint8List(0);
    loadThumbnail();
  }

  void loadThumbnail() {
    if (widget.mapItem.thumbnail == null) {
      Repository().client(widget.conn).resGetThumbnail(widget.mapItem.id).then((value) {
        setState(() {
          _bytesImage = value.item.content;
        });
      });
    }
  }

  Widget itemImage() {
    if (widget.mapItem.thumbnail != null) {
      return Image(
        fit: BoxFit.contain,
        image: widget.mapItem.thumbnail!,
      );
    }
    if (_bytesImage.isNotEmpty) {
      return Image.memory(_bytesImage, fit: BoxFit.cover);
    }
    return Container(color: Colors.red.withOpacity(0.2));
  }

  @override
  Widget build(BuildContext context) {
    double blurK = 1.5;
    if (hover) {
      blurK = 1;
    }

    Icon icon = const Icon(
      Icons.layers,
      color: Colors.blue,
      size: 36,
    );
    if (widget.mapItem.type != "map") {
      icon = const Icon(
        Icons.stop,
        color: Colors.teal,
        size: 36,
      );
      blurK = 0;
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
          color: Colors.black54,
          child: Container(
            padding: const EdgeInsets.all(0),
            constraints: const BoxConstraints(
              maxWidth: 200,
            ),
            height: 200,
            decoration: BoxDecoration(
              color: hover ? Colors.black54 : Colors.transparent,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                itemImage(),
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(0)),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: blurK, sigmaY: blurK),
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
                              icon,
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                  color: Colors.black26,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.mapItem.name,
                                        style: const TextStyle(fontSize: 14),
                                        overflow: TextOverflow.fade,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
