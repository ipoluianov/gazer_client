import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/protocol/resource/resource_get.dart';
import 'package:gazer_client/core/protocol/service/service_info.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/forms/maps/map_form/map_item.dart';
import 'package:gazer_client/forms/maps/map_item_properties_form/map_item_properties_widget.dart';
import 'package:gazer_client/forms/utilities/lookup_form/lookup_form.dart';
import 'package:gazer_client/widgets/error_widget/error_block.dart';
import 'package:gazer_client/widgets/time_chart/time_chart.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_settings.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_settings_area.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_settings_series.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';

class ChartGroupForm extends StatefulWidget {
  final ChartGroupFormArgument arg;
  const ChartGroupForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChartGroupFormSt();
  }
}

class ChartGroupFormSt extends State<ChartGroupForm> {
  late TimeChartSettings _settings;

  bool serviceInfoLoaded = false;
  late ServiceInfoResponse serviceInfo;
  bool changed = false;
  String errorMessage = "";
  bool loaded = false;
  bool loading = false;
  String nameOfChartGroup = "";
  String loadingError = "";
  String lastLoadedResource = "";

  //late Timer _timerUpdate = Timer.periodic(const Duration(milliseconds: 500), (timer) {});

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

  @override
  void initState() {
    super.initState();
    _settings = TimeChartSettings(widget.arg.connection, []);
    loadNodeInfo();
    load();

    /*_timerUpdate = Timer.periodic(const Duration(milliseconds: 1000), (t) {
      setState(() {
      });
    });*/
  }

  @override
  void dispose() {
    super.dispose();
    //_timerUpdate.cancel();
  }

  void loadFromResource(String resourceId) async {
    if (resourceId == "") {
      return;
    }

    if (loading) {
      return;
    }

    loaded = false;
    loading = true;

    int step = 200000;
    List<int> result = [];

    try {
      for (int offset = 0; offset < 100 * 1000000; offset += step) {
        var value = await Repository().client(widget.arg.connection).fetch<ResGetRequest, ResGetResponse>(
              'resource_get',
              ResGetRequest(resourceId, offset, step),
              (Map<String, dynamic> json) => ResGetResponse.fromJson(json),
            );
        if (value.content.isEmpty) {
          break;
        }
        nameOfChartGroup = value.name;
        result.addAll(value.content.toList());
      }
    } catch (loadingErr) {
      setState(() {
        errorMessage = loadingErr.toString();
        loading = false;
      });
    }

    try {
      var jsonString = utf8.decode(result);
      var jsonObject = jsonDecode(jsonString);
      setState(() {
        _settings = TimeChartSettings.fromJson(widget.arg.connection, jsonObject);
      });
    } catch (e) {
    }

    setState(() {
      lastLoadedResource = resourceId;
      loading = false;
      loaded = true;
    });
  }

  void load() {
    _settings.areas = [];
    loadFromResource(widget.arg.id);
    return;
  }

  bool saving = false;
  double savingProgress = 0;

  void saveAsync() async {
    saving = true;
    bool saveOk = true;

    try {
      var encoder = JsonUtf8Encoder();
      Map<String, dynamic> j = _settings.toJson();
      String jsonString = String.fromCharCodes(encoder.convert(j));
      var listOfBytes = jsonString.codeUnits;
      int step = 100000;
      for (int offset = 0; offset < listOfBytes.length; offset += step) {
        var currentStep = step;
        if (offset + currentStep > listOfBytes.length) {
          currentStep = listOfBytes.length - offset;
        }
        await Repository()
            .client(widget.arg.connection)
            .resSet(widget.arg.id, "", offset, Uint8List.fromList(listOfBytes.sublist(offset, offset + currentStep)));

        if (listOfBytes.isNotEmpty) {
          setState(() {
            savingProgress = (offset + currentStep) / listOfBytes.length;
          });
        }
      }
    } catch (err) {
      saveOk = false;
    }

    if (saveOk) {
      setState(() {
        _settings.setEditing(false);
      });
    } else {
      _showErrorMessage("Error", "Can not save the chart group. Please try again.");
    }

    saving = false;
  }

  void save() {
    saveAsync();
    changed = true;
  }

  void updateState() {
    setState(() {
      //var rng = Random();
      //map.value = rng.nextInt(100).toDouble() / 100;
    });
  }

  void updateTick() {
    setState(() {
      //map.tick();
    });
  }

  Widget buildPropWidget(BuildContext context) {
    if (!_settings.editing()) {
      return Container();
    }

    IPropContainer propContainer = _settings.selectedObject();
    return MapItemPropertiesWidget(
      MapItemPropertiesFormArgument(widget.arg.connection, propContainer),
      key: Key(propContainer.id()),
    );
  }

  Widget buildContent(BuildContext context) {
    if (loading) {
      return const Text("loading ...");
    }

    if (errorMessage.isNotEmpty) {
      return ErrorBlock(errorMessage);
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
        buttons.add(buildActionButtonFull(context, Icons.keyboard_tab, "Move Forward", () {
          setState(() {
            _settings.horScale.setFixedHorScale(false);
          });
        }, false, imageColor: _settings.horScale.fixedHorScale ? Colors.white38 : DesignColors.fore()));
        if (!fullScreen) {
          /*buttons.add(buildActionButtonFull(context, Icons.adjust, "Auto Zoom", () {
            map.autoZoomToggle();
          }, map.autoZoom));*/
          /*buttons.add(buildActionButton(context, Icons.zoom_in, "Zoom In", () {
            map.zoomIn();
          }));
          buttons.add(buildActionButton(context, Icons.zoom_out, "Zoom Out", () {
            map.zoomOut();
          }));
          buttons.add(buildActionButton(context, Icons.preview_sharp, "100%", () {
            map.resetView();
          }));*/
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
        if (_settings.editing()) {
          rightButtons.add(buildActionButton(context, Icons.add, "Add item", () {
            Navigator.pushNamed(context, "/lookup", arguments: LookupFormArgument(Repository().lastSelectedConnection, "Select source item", "data-item"))
                .then((value) {
              if (value != null) {
                var res = value as LookupFormResult;
                setState(() {
                  _settings.areas
                      .add(TimeChartSettingsArea(widget.arg.connection, <TimeChartSettingsSeries>[TimeChartSettingsSeries(widget.arg.connection, res.field("name"), [], Colors.blueAccent)]));
                });
              }
            });
          }));
          rightButtons.add(buildActionButton(context, Icons.delete_forever, "Remove item", () {
            setState(() {
              _settings.removeSelected();
            });
          }));
          rightButtons.add(buildActionButtonFull(context, Icons.more_horiz, "Item Properties", () {
            /*var item = map.currentItem();
            if (item != null) {
              Navigator.of(context)
                  .pushNamed(
                "/map_item_properties",
                arguments: MapItemPropertiesFormArgument(widget.arg.connection, map.currentItem()!),
              )
                  .then((value) {
                setState(() {});
              });
            }*/
          }, false));
        }
        leftButtons.add(Expanded(child: Container()));
        leftButtons.addAll(rightButtons);
        if (fullScreen) {
          leftButtons.add(buildActionButtonFull(context, Icons.fullscreen_exit, "Exit Full Screen", () {
            setState(() {
              fullScreen = false;
              //map.fullscreen = false;
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
    /*if (map.hoverItem != null) {
      if (map.hoverItem!.hasAction()) {
        return SystemMouseCursors.click;
      }
    }*/
    return SystemMouseCursors.basic;
  }

  Widget buildContentMapArea(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
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
                  /*onPointerDown: (PointerDownEvent ev) {
                    setState(() {
                      map.onPointerDown(ev.localPosition);
                    });
                  },
                  onPointerMove: (PointerMoveEvent ev) {},
                  onPointerUp: (PointerUpEvent ev) {
                    setState(() {
                      map.onPointerUp(ev.localPosition);
                    });
                  },
                  onPointerSignal: (pointerSignal) {
                    if (pointerSignal is PointerScrollEvent) {
                      map.scroll(pointerSignal.scrollDelta, pointerSignal.localPosition);
                    }
                  },
                  onPointerHover: (event) {
                    //print("hover: ${event.localPosition}");
                    map.onHover(event.localPosition);
                  },*/
                  child: GestureDetector(
                    /*onHorizontalDragStart: (DragStartDetails ev) {
                      map.startMoving(1, ev.localPosition);
                      setState(() {});
                    },
                    onHorizontalDragUpdate: (DragUpdateDetails ev) {
                      setState(() {
                        map.updateMoving(1, ev.localPosition, 1);
                      });
                    },
                    onHorizontalDragEnd: (DragEndDetails ev) {
                      setState(() {
                        map.stopMoving(1);
                      });
                    },
                    onTapDown: (details) {
                      setState(() {
                        map.tapDown(details.localPosition, context);
                      });
                    },
                    onTapUp: (details) {
                      setState(() {
                        map.tapUp(details.localPosition, context);
                      });
                    },
                    onScaleStart: (details) {
                      map.startMoving(details.pointerCount, details.localFocalPoint);
                    },
                    onScaleUpdate: (details) {
                      map.updateMoving(details.pointerCount, details.localFocalPoint, details.scale);
                    },
                    onScaleEnd: (details) {
                      map.stopMoving(details.pointerCount);
                    },*/
                    child: TimeChart(widget.arg.connection, "u2/Time", _settings, () {
                      setState(() {
                      });
                    }),
                  ),
                ),
              ),
              Container(
                constraints: const BoxConstraints(maxHeight: 55),
                child: fullScreen ? Opacity(opacity: 0.2, child: buildMapToolbar(context)) : Container(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildFullScreen(BuildContext context) {
    return Scaffold(
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
            widget.arg.connection, nodeName() + " - Chart Group - " + nameOfChartGroup,
            actions: <Widget>[
              !fullScreen
                  ? buildActionButton(context, Icons.fullscreen, "Full Screen", () {
                setState(() {
                  fullScreen = true;
                  //map.fullscreen = true;
                  //map.entire();
                });
              })
                  : Container(),
              !_settings.editing()
                  ? buildActionButton(context, Icons.edit, "Edit", () {
                //saveOriginal();
                setState(() {
                  _settings.setEditing(true);
                });
              })
                  : Container(),
              (_settings.editing() && !saving)
                  ? Padding(
                padding: const EdgeInsets.all(10),
                child: ElevatedButton.icon(
                  onPressed: () {
                    load();
                    setState(() {
                      _settings.setEditing(false);
                    });
                  },
                  icon: const Icon(Icons.cancel),
                  label: const Text("Reject"),
                ),
              )
                  : Container(),
              (_settings.editing() && !saving)
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
            child:Column(
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
