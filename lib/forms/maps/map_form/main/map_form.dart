import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/protocol/service/service_info.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/tools/thumbnail_maker.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/forms/chart_groups/chart_group_form/chart_group_data_items.dart';
import 'package:gazer_client/forms/maps/map_item_add_form/map_item_add_form.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/map_item_properties_widget.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';

import 'map_view.dart';

class MapForm extends StatefulWidget {
  final MapFormArgument arg;
  const MapForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MapFormSt();
  }
}

class MapFormSt extends State<MapForm> {
  late MapView map;

  bool serviceInfoLoaded = false;
  late ServiceInfoResponse serviceInfo;
  bool changed = false;
  String errorMessage = "";
  bool loading = false;

  void loadNodeInfo() {
    Repository().client(widget.arg.connection).serviceInfo().then((value) {
      setState(() {
        serviceInfo = value;
        serviceInfoLoaded = true;
      });
    });
  }

  String nodeName() {
    if (serviceInfoLoaded) {
      return serviceInfo.nodeName;
    }
    return widget.arg.connection.address;
  }

  String mapName = "";

  late Timer _timer;
  late Timer _timerTick;

  RenderBox? lastRenderBox_;

  @override
  void initState() {
    super.initState();
    map = MapView(widget.arg.connection);
    loadNodeInfo();
    load();

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      updateState();
    });

    _timerTick = Timer.periodic(const Duration(milliseconds: 40), (t) {
      updateTick();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _timerTick.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  void load() {
    map.initMapInstance(widget.arg.connection);
    map.instance.loadFromResource(widget.arg.id, {}).then((value) {
      if (widget.arg.edit) {
        widget.arg.edit = false;
        openEditor();
      }
    });
    return;
  }

  String mapOriginal = "";
  void saveOriginal() {
    var encoder = JsonUtf8Encoder();
    Map<String, dynamic> j = map.instance.toJson();
    mapOriginal = String.fromCharCodes(encoder.convert(j));
  }

  void openEditor() {
    saveOriginal();
    map.setEditing(true);
  }

  /*void loadOriginal() {
    try {
      var jsonObject = jsonDecode(mapOriginal);
      //map = MapView.fromJson(jsonObject, widget.arg.connection);
      map = MapView(widget.arg.connection);
      map.initMapInstance(widget.arg.connection);
      map.instance.isRoot = true;
      map.instance.loadPropertiesRoot(jsonObject);
      //map.instance.lastResourceId = widget.arg.id;
    } catch (err) {}
  }*/

  Future<Uint8List> drawMapToImage() async {
    Uint8List pngBytes = Uint8List(0);
    PictureRecorder rec = PictureRecorder();
    Canvas canvas = Canvas(rec);
    Size size = Size(map.instance.getDouble("w"), map.instance.getDouble("h"));

    Offset previousDisplayOffset = map.displayOffset();
    double previousZoom = map.instance.zoom;

    map.setViewPropertiesDirect(const Offset(0, 0), 1);
    map.instance.drawItem(canvas, size, "", []);
    map.setViewPropertiesDirect(previousDisplayOffset, previousZoom);

    Picture pic = rec.endRecording();
    var img = await pic.toImage(map.instance.getDouble("w").toInt(),
        map.instance.getDouble("h").toInt());

    ByteData? byteData = await img.toByteData(format: ImageByteFormat.png);
    if (byteData != null) {
      pngBytes = byteData.buffer.asUint8List();
      pngBytes = makeThumbnail(pngBytes)!;
    }
    return pngBytes;
  }

  bool saving = false;
  double savingProgress = 0;

  void saveAsync() async {
    saving = true;
    bool saveOk = true;

    try {
      var encoder = JsonUtf8Encoder();
      Map<String, dynamic> j = map.instance.toJson();
      String jsonString = String.fromCharCodes(encoder.convert(j));
      var listOfBytes = jsonString.codeUnits;
      int step = 50000;
      for (int offset = 0; offset < listOfBytes.length; offset += step) {
        bool savePartComplete = false;
        String errorPartText = "";

        for (int iteration = 0; iteration < 10; iteration++) {
          var currentStep = step;

          if (offset + currentStep > listOfBytes.length) {
            currentStep = listOfBytes.length - offset;
          }

          try {
            await Repository().client(widget.arg.connection).resSet(
                widget.arg.id,
                "",
                offset,
                Uint8List.fromList(
                    listOfBytes.sublist(offset, offset + currentStep)));
            if (listOfBytes.isNotEmpty) {
              setState(() {
                savingProgress = (offset + currentStep) / listOfBytes.length;
              });
            }
            savePartComplete = true;
          } catch (err) {
            errorPartText = err.toString();
          }

          if (savePartComplete) {
            break;
          }
        }

        if (!savePartComplete) {
          throw errorPartText;
        }
      }
    } catch (err) {
      saveOk = false;
    }

    if (saveOk) {
      map.setEditing(false);
      map.entire();

      /*drawMapToImage().then((value) {
        Repository()
            .client(widget.arg.connection)
            .resSet(widget.arg.id, "thumbnail", 0, value);
      });*/
    } else {
      _showErrorMessage("Error", "Can not save the map. Please try again.");
    }

    saving = false;
  }

  void save() {
    map.setEditing(false);
    saveOriginal();
    map.setEditing(true);
    saveAsync();
    changed = true;
  }

  void updateState() {
    setState(() {
      mapName = map.instance.mapName();
      //var rng = Random();
      //map.value = rng.nextInt(100).toDouble() / 100;
    });
  }

  void updateTick() {
    setState(() {
      map.tick();
    });
  }

  Widget buildPropWidget(BuildContext context) {
    var selectedItem = map.currentItem();
    if (!map.editing()) {
      selectedItem = null;
    }
    if (selectedItem == null) {
      return Container();
    }
    return MapItemPropertiesWidget(
      MapItemPropertiesFormArgument(widget.arg.connection, selectedItem),
      key: Key(selectedItem.id()),
    );
  }

  Widget buildContent(BuildContext context) {
    if (errorMessage.isNotEmpty) {
      return Text("Error: " + errorMessage);
    }

    if (loading) {
      return const Text("Loading ...");
    }

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          var canPlacePropWidget = constraints.maxWidth > 600;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  child: buildContentMapArea(context),
                ),
              ),
              canPlacePropWidget ? buildPropWidget(context) : Container(),
            ],
          );
        },
      ),
    );
  }

  // MapItemPropertiesWidget(MapItemPropertiesFormArgument(widget.arg.connection, selectedItem))
  Widget buildMapToolbar(BuildContext context) {
    /*if (fullScreen) {
      return Container();
    }*/
    return LayoutBuilder(
      builder: (context, constraints) {
        List<Widget> buttons = [];
        buttons.add(
            buildActionButton(context, Icons.zoom_out_map, "Show entire", () {
          map.entire();
        }));
        if (!fullScreen) {
          /*buttons.add(buildActionButtonFull(context, Icons.adjust, "Auto Zoom", () {
            map.autoZoomToggle();
          }, map.autoZoom));*/
          buttons.add(buildActionButton(context, Icons.zoom_in, "Zoom In", () {
            map.zoomIn();
          }));
          buttons
              .add(buildActionButton(context, Icons.zoom_out, "Zoom Out", () {
            map.zoomOut();
          }));
          buttons
              .add(buildActionButton(context, Icons.preview_sharp, "100%", () {
            map.resetView();
          }));
        }

        int countOfButtons = ((constraints.maxWidth - 200) / 65).round();
        if (countOfButtons < 1) {
          countOfButtons = 1;
        }
        if (countOfButtons > buttons.length) {
          countOfButtons = buttons.length;
        }
        var leftButtons = buttons.getRange(0, countOfButtons).toList();
        List<Widget> rightButtons = [];
        if (map.editing()) {
          rightButtons.add(
            buildActionButtonFull(context, Icons.add, "Add item", () {
              Navigator.of(context)
                  .pushNamed(
                "/map_item_add",
                arguments: MapItemAddFormArgument(widget.arg.connection, map),
              )
                  .then(
                (value) {
                  if (value != null) {
                    setState(() {
                      var res = value as MapItemAddFormResult;
                      map.currentTool = res.type;
                      map.currentToolParameter = res.parameter;
                      //print("Adding ${res.type} ${res.parameter}");
                    });
                  }
                },
              );
            }, false),
          );
          rightButtons.add(
            buildActionButtonFull(context, Icons.code, "Convert item", () {
              Navigator.of(context)
                  .pushNamed(
                "/map_item_add",
                arguments: MapItemAddFormArgument(widget.arg.connection, map),
              )
                  .then(
                (value) {
                  if (value != null) {
                    setState(() {
                      var res = value as MapItemAddFormResult;
                      map.convertSelectedItemToType(res.type, res.parameter);
                    });
                  }
                },
              );
            }, false),
          );
          rightButtons.add(buildActionButton(
              context, Icons.delete_forever, "Remove item", () {
            map.removeSelectedItem();
          }));
          rightButtons.add(
              buildActionButton(context, Icons.vertical_align_top, "to Up", () {
            map.upSelectedItem();
          }));
          rightButtons.add(buildActionButton(
              context, Icons.vertical_align_bottom, "to Down", () {
            map.downSelectedItem();
          }));
          rightButtons.add(buildActionButton(context, Icons.copy, "Copy", () {
            map.copySelectedItem();
          }));
          rightButtons.add(buildActionButton(context, Icons.paste, "Paste", () {
            map.pasteFromClipboard();
          }));
          rightButtons.add(buildActionButtonFull(
              context, Icons.more_horiz, "Item Properties", () {
            var item = map.currentItem();
            if (item != null) {
              Navigator.of(context)
                  .pushNamed(
                "/map_item_properties",
                arguments: MapItemPropertiesFormArgument(
                    widget.arg.connection, map.currentItem()!),
              )
                  .then((value) {
                setState(() {});
              });
            }
          }, false));
        }
        leftButtons.add(Expanded(child: Container()));
        leftButtons.addAll(rightButtons);
        if (fullScreen) {
          leftButtons.add(buildActionButtonFull(
              context, Icons.fullscreen_exit, "Exit Full Screen", () {
            setState(() {
              fullScreen = false;
              map.fullscreen = false;
            });
          }, false, imageColor: Colors.blueAccent, backColor: Colors.black));
        }
        return Row(
          children: leftButtons,
        );
      },
    );
  }

  MouseCursor mapCursor() {
    if (map.hoverItem != null) {
      if (map.hoverItem!.hasAction()) {
        return SystemMouseCursors.click;
      }
    }
    return SystemMouseCursors.basic;
  }

  final FocusNode _focusNode = FocusNode();

  bool keyControl = false;
  bool keyShift = false;
  bool keyAlt = false;

  Widget buildContentMapArea(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: Colors.black26,
          //child: Text("123"),
          child: fullScreen ? Container() : buildMapToolbar(context),
        ),
        Container(
          color: DesignColors.fore2(),
          height: 1,
        ),
        Expanded(
          child: Stack(
            children: [
              MouseRegion(
                cursor: mapCursor(),
                child: Listener(
                  onPointerDown: (PointerDownEvent ev) {
                    print("Listener::onPointerDown");
                    FocusScope.of(context).requestFocus(_focusNode);
                    setState(() {
                      map.onPointerDown(ev.localPosition);
                    });
                  },
                  onPointerMove: (PointerMoveEvent ev) {},
                  onPointerUp: (PointerUpEvent ev) {
                    print("Listener::onPointerUp");

                    setState(() {
                      map.onPointerUp(ev.localPosition);
                    });
                  },
                  onPointerSignal: (pointerSignal) {
                    // print("Listener::onPointerSignal");
                    if (pointerSignal is PointerScrollEvent) {
                      print(
                          "----------------- Listener::onPointerSignal ${pointerSignal.scrollDelta}");
                      map.scroll(pointerSignal.scrollDelta,
                          pointerSignal.localPosition);
                    }
                  },
                  onPointerHover: (event) {
                    //print("hover: ${event.localPosition}");
                    //map.lastHoverOffset = event.localPosition;
                    map.onHover(event.localPosition);
                    //map.lastTapOffset = event.localPosition;
                    //map.setTargetDisplayOffset(event.localPosition);
                  },
                  child: GestureDetector(
                    onHorizontalDragStart: (DragStartDetails ev) {
                      print(
                          "GestureDetector::onHorizontalDragStart ${ev.kind} ${ev.globalPosition}");
                      if (ev.kind != null) {
                        map.lastDeviceType = ev.kind!;
                      }
                      if (ev.kind == PointerDeviceKind.mouse) {
                        map.startMoving(1, ev.localPosition);
                      }
                      if (ev.kind == PointerDeviceKind.trackpad) {
                        map.startMoving(1, ev.globalPosition);
                      }

                      //map.startMoving(1, map.lastHoverOffset);
                      setState(() {});
                    },
                    onHorizontalDragUpdate: (DragUpdateDetails ev) {
                      print(
                          "GestureDetector::onHorizontalDragUpdate ${ev.globalPosition}");
                      Offset offset = ev.localPosition;
                      if (map.lastDeviceType == PointerDeviceKind.mouse) {
                        offset = ev.localPosition;
                      }
                      if (map.lastDeviceType == PointerDeviceKind.trackpad) {
                        offset = ev.globalPosition;
                      }
                      setState(() {
                        map.updateMoving(1, offset, 1);
                      });
                    },
                    onHorizontalDragEnd: (DragEndDetails ev) {
                      print("GestureDetector::onHorizontalDragEnd");
                      setState(() {
                        map.stopMoving(1);
                      });
                    },
                    onTapDown: (details) {
                      print("GestureDetector::onTapDown");
                      FocusScope.of(context).requestFocus(_focusNode);
                      setState(() {
                        map.tapDown(details.localPosition, context);
                      });
                    },
                    onTapUp: (details) {
                      print("GestureDetector::onTapUp");
                      setState(() {
                        map.tapUp(details.localPosition, context);
                      });
                    },
                    onScaleStart: (details) {
                      print("GestureDetector::onScaleStart");
                      FocusScope.of(context).requestFocus(_focusNode);
                      map.startMoving(
                          details.pointerCount, details.localFocalPoint);
                    },
                    onScaleUpdate: (details) {
                      print("GestureDetector::onScaleUpdate");

                      map.updateMoving(details.pointerCount,
                          details.localFocalPoint, details.scale);
                    },
                    onScaleEnd: (details) {
                      print("GestureDetector::onScaleEnd");

                      map.stopMoving(details.pointerCount);
                    },
                    child: DragTarget<DataItemsObject>(
                      onMove: (details) {
                        //.findRenderObject();
                        //Converts the global coordinates to the local coordinates of the current widget.
                        //Offset center = box.globalToLocal(Offset(info.dx, info.dy));

                        //print("MOVE: ${details.offset}");
                      },
                      builder: (
                        BuildContext context,
                        List<dynamic> accepted,
                        List<dynamic> rejected,
                      ) {
                        RenderObject? rObject = context.findRenderObject();
                        if (rObject is RenderBox) {
                          lastRenderBox_ = rObject;
                        }

                        return RawKeyboardListener(
                            focusNode: _focusNode,
                            onKey: (ev) {
                              setState(() {
                                keyControl = ev.isControlPressed;
                                keyAlt = ev.isAltPressed;
                                keyShift = ev.isShiftPressed;
                                map.setKeys(keyControl, keyAlt, keyShift);
                              });

                              if (ev is RawKeyDownEvent) {
                                if (ev.isControlPressed &&
                                    ev.physicalKey ==
                                        PhysicalKeyboardKey.keyC) {
                                  map.copySelectedItem();
                                }
                                if (ev.isControlPressed &&
                                    ev.physicalKey ==
                                        PhysicalKeyboardKey.keyV) {
                                  map.pasteFromClipboard();
                                }
                                if (ev.physicalKey ==
                                    PhysicalKeyboardKey.delete) {
                                  map.removeSelectedItem();
                                }
                                if (ev.physicalKey ==
                                    PhysicalKeyboardKey.escape) {
                                  map.entire();
                                }
                                if (ev.physicalKey == PhysicalKeyboardKey.f11) {
                                  setState(() {
                                    fullScreen = true;
                                    map.fullscreen = true;
                                    map.entire();
                                  });
                                  FocusScope.of(context)
                                      .requestFocus(_focusNode);
                                }
                              }
                            },
                            child: CustomPaint(
                              painter: MapPainter(map),
                              child: Container(),
                              key: UniqueKey(),
                            ));
                      },
                      onAcceptWithDetails: (details) {
                        if (lastRenderBox_ != null) {
                          var localOffset =
                              lastRenderBox_!.globalToLocal(details.offset);
                          var data = details.data;

                          if (data.name.contains("/")) {
                            setState(() {
                              map.addItem("text.02", localOffset,
                                  {"data_source": data.name});
                            });
                          } else {
                            setState(() {
                              map.addItem("unit.table.01", localOffset,
                                  {"data_source": data.name});
                            });
                          }

                          /*var areaIndex = widget._settings.findAreaIndexByXY(localOffset.dx, localOffset.dy);
                          if (areaIndex < 0) {
                            setState(() {
                              widget._settings.areas.add(TimeChartSettingsArea(
                                  widget.conn, <TimeChartSettingsSeries>[TimeChartSettingsSeries(widget.conn, data.name, [], colorByIndex(0))]));
                            });
                          } else {
                            setState(() {
                              widget._settings.areas[areaIndex].series
                                  .add(TimeChartSettingsSeries(widget.conn, data.name, [], colorByIndex(widget._settings.areas[areaIndex].series.length)));
                            });
                          }*/
                        }
                      },
                    ),
                  ),
                ),
              ),
              Container(
                constraints: const BoxConstraints(maxHeight: 55),
                child: fullScreen
                    ? Opacity(opacity: 0.2, child: buildMapToolbar(context))
                    : Container(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildFullScreen(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignColors.mainBackgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildContent(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool fullScreen = false;

  Widget buildRegular(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool narrow = constraints.maxWidth < constraints.maxHeight;
        bool showLeft = !narrow;
        bool showBottom = narrow;

        return Scaffold(
          appBar: TitleBar(
            widget.arg.connection,
            nodeName() + " - Map - " + mapName,
            actions: <Widget>[
              !fullScreen
                  ? buildActionButton(context, Icons.fullscreen, "Full Screen",
                      () {
                      setState(() {
                        fullScreen = true;
                        map.fullscreen = true;
                        map.entire();
                      });
                    })
                  : Container(),
              !map.editing()
                  ? buildActionButton(context, Icons.edit, "Edit", () {
                      openEditor();
                    })
                  : Container(),
              (map.editing() && !saving)
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          load();
                          map.setEditing(false);
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text("Reject"),
                      ),
                    )
                  : Container(),
              (map.editing() && !saving)
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          save();
                        },
                        icon: const Icon(Icons.save),
                        label: const Text("Save"),
                      ),
                    )
                  : Container(),
              (saving)
                  ? Padding(
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        width: 100,
                        height: 20,
                        child: LinearProgressIndicator(
                          value: savingProgress,
                        ),
                      ),
                    )
                  : Container(),
              buildHomeButton(context),
            ],
          ),
          body: Container(
            color: DesignColors.mainBackgroundColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      LeftNavigator(showLeft),
                      buildContent(context),
                    ],
                  ),
                ),
                BottomNavigator(showBottom),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (fullScreen) {
      return buildFullScreen(context);
    } else {
      return buildRegular(context);
    }
  }

  Future<void> _showErrorMessage(String header, String text) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(header),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(text),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
