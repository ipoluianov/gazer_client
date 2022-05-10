import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'dart:ui' as dart_ui;

import 'package:flutter/material.dart';
import 'package:gazer_client/core/gazer_style.dart';
import 'package:gazer_client/core/protocol/resource/resource_list.dart';
import 'package:gazer_client/core/protocol/unit/unit_state_all.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_decorations/map_item_decoration.dart';
import 'package:gazer_client/forms/maps/map_form/map_item_library.dart';

class MapItemDecorationCard extends StatefulWidget {
  final Connection conn;
  final MapItemDecorationType mapItemDecoration;
  final Function onNavigate;

  const MapItemDecorationCard(this.conn, this.mapItemDecoration, this.onNavigate, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapItemDecorationCardState();
  }
}

class MapItemDecorationCardState extends State<MapItemDecorationCard> {
  bool hover = false;
  late Uint8List _bytesImage;

  late MapItemDecoration decoration;

  late Timer _timer;
  late Timer _timerTick;


  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      setState(() {
      });
    });

    _timerTick = Timer.periodic(const Duration(milliseconds: 40), (t) {
      decoration.tickDecoration();
    });

    _bytesImage = Uint8List(0);
    //loadThumbnail();
    decoration = MapItemDecoration.makeByType(widget.mapItemDecoration.type);
    decoration.initDefaultProperties();
  }

  @override
  void dispose() {
    _timer.cancel();
    _timerTick.cancel();
    super.dispose();
  }

  /*Image thumbnail = Image.memory(Uint8List(0));

  void loadThumbnail() async {
    dart_ui.PictureRecorder rec = dart_ui.PictureRecorder();
    Canvas canvas = Canvas(rec);
    Size size = const Size(300, 300);
    double decorationPaddingW = size.width / 5;
    double decorationPaddingH = size.height / 5;
    double w = size.width - decorationPaddingW * 2;
    double h = size.height - decorationPaddingH * 2;
    canvas.translate(decorationPaddingW, decorationPaddingH);
    var decoration = MapItemDecoration.makeByType(widget.mapItemDecoration.type);
    decoration.showProgress = 1;
    var defaultItem = MapItemsLibrary().makeItemByType("item", widget.conn);
    decoration.initDefaultProperties();
    decoration.drawDecoratorPre(canvas, Rect.fromLTWH(0, 0, w, h), defaultItem, 1);
    decoration.drawDecoratorPost(canvas, Rect.fromLTWH(0, 0, w, h), defaultItem, 1);

    dart_ui.Picture pic = rec.endRecording();
    dart_ui.Image img = await pic.toImage(size.width.toInt(), size.height.toInt());
    ByteData? byteData = await img.toByteData(format: ImageByteFormat.png);
    if (byteData != null) {
      thumbnail = Image.memory(byteData.buffer.asUint8List());
      print("${byteData.buffer.asUint8List()}");
    }
    setState(() {
    });
  }*/

  /*Widget itemImage() {
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
  }*/

  @override
  Widget build(BuildContext context) {
    Icon icon = const Icon(
      Icons.layers,
      color: Colors.blue,
      size: 36,
    );
    /*if (widget.mapItem.type != "map") {
      icon = const Icon(
        Icons.stop,
        color: Colors.purpleAccent,
        size: 36,
      );
      blurK = 0;
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
                CustomPaint(
                  painter: DecorationPainter(decoration, widget.conn),
                  child: SizedBox(width: 250, height: 250,),
                  key: UniqueKey(),
                ),
                ClipRRect(
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
                              icon,
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.only(left: 10, top: 5, bottom: 5),
                                  color: Colors.black26,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.mapItemDecoration.name,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DecorationPainter extends CustomPainter {
  MapItemDecoration decoration;
  Connection connection;
  DecorationPainter(this.decoration, this.connection);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    double paddingW = size.width / 4;
    double paddingH = size.height / 4;
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.translate(paddingW, paddingH);
    //canvas.drawRect(Rect.fromLTWH(0, 0, 10, 10), Paint()..color = Colors.red);
    decoration.drawDecoratorPre(canvas, Rect.fromLTWH(0, 0, size.width - paddingW*2, size.height - paddingH*2), MapItemsLibrary().makeItemByType("item", connection), 1);
    decoration.drawDecoratorPost(canvas, Rect.fromLTWH(0, 0, size.width - paddingW*2, size.height - paddingH*2), MapItemsLibrary().makeItemByType("item", connection), 1);
    //settings.draw(canvas, size);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}