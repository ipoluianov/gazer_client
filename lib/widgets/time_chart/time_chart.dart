import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/core/protocol/dataitem/data_item_history_chart.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/tools/color_by_index.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/chart_groups/chart_group_form/chart_group_data_items.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_history_for_group.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_painter.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_settings.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_settings_area.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_settings_series.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimeChart extends StatefulWidget {
  final Connection conn;
  final String itemName;
  final TimeChartSettings _settings;
  final Function onChanged;
  const TimeChart(this.conn, this.itemName, this._settings, this.onChanged,
      {Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TimeChartState();
  }
}

class TimeRange {
  final String name;
  final String value;
  TimeRange(this.name, this.value);
}

class TimeChartState extends State<TimeChart> with TickerProviderStateMixin {
  late Timer _timerUpdateTimeRange =
      Timer.periodic(const Duration(milliseconds: 500), (timer) {});

  @override
  void initState() {
    requestHistory();
    setUpdateTimePeriodMs(100);
    SharedPreferences.getInstance().then((sharedPref) {
      dropdownValue =
          sharedPref.getString("time_chart_default_last_period") ?? "5min";
    });

    super.initState();
  }

  void requestHistory() {
    return;
  }

  void setUpdateTimePeriodMs(int durationMs) {
    _timerUpdateTimeRange.cancel();
    _timerUpdateTimeRange =
        Timer.periodic(Duration(milliseconds: durationMs), (t) {
      updateTimes();
    });
  }

  String displayPeriodName(String value) {
    String result = value;
    if (value == "1min") {
      result = "1m";
    }
    if (value == "5min") {
      result = "5m";
    }
    if (value == "10min") {
      result = "10m";
    }
    if (value == "30min") {
      result = "30m";
    }
    if (value == "60min") {
      result = "60m";
    }
    if (value == "3hours") {
      result = "3H";
    }
    if (value == "6hours") {
      result = "6H";
    }
    if (value == "12hours") {
      result = "12H";
    }
    if (value == "24hours") {
      result = "24H";
    }
    if (value == "7days") {
      result = "7d";
    }
    if (value == "30days") {
      result = "30d";
    }
    if (value == "180days") {
      result = "180s";
    }
    if (value == "365days") {
      result = "365d";
    }

    return result;
  }

  void updateTimes() {
    int now = DateTime.now().microsecondsSinceEpoch;
    double lastSeconds = 10;

    if (dropdownValue == "1min") {
      lastSeconds = 1 * 60;
    }
    if (dropdownValue == "5min") {
      lastSeconds = 5 * 60;
    }
    if (dropdownValue == "10min") {
      lastSeconds = 10 * 60;
    }
    if (dropdownValue == "30min") {
      lastSeconds = 30 * 60;
    }
    if (dropdownValue == "60min") {
      lastSeconds = 60 * 60;
    }
    if (dropdownValue == "3hours") {
      lastSeconds = 3 * 60 * 60;
    }
    if (dropdownValue == "6hours") {
      lastSeconds = 6 * 60 * 60;
    }
    if (dropdownValue == "12hours") {
      lastSeconds = 12 * 60 * 60;
    }
    if (dropdownValue == "24hours") {
      lastSeconds = 1 * 24 * 60 * 60;
    }
    if (dropdownValue == "7days") {
      lastSeconds = 7 * 24 * 60 * 60;
    }
    if (dropdownValue == "30days") {
      lastSeconds = 30 * 24 * 60 * 60;
    }
    if (dropdownValue == "180days") {
      lastSeconds = 180 * 24 * 60 * 60;
    }
    if (dropdownValue == "365days") {
      lastSeconds = 365 * 24 * 60 * 60;
    }

    setState(() {
      widget._settings.setDisplayRangeLast(lastSeconds);

      double w = widget._settings.horScale.width;
      if (w < 1) {
        return;
      }

      double r = widget._settings.horScale.displayMax -
          widget._settings.horScale.displayMin;
      int timePerPixel = (r / w).round();

      //print("getHistory - ${timePerPixel} - ${r} / ${w}");

      for (int areaIndex = 0;
          areaIndex < widget._settings.areas.length;
          areaIndex++) {
        var area = widget._settings.areas[areaIndex];
        for (int seriesIndex = 0;
            seriesIndex < area.series.length;
            seriesIndex++) {
          var series = area.series[seriesIndex];
          var data = Repository().history.getNode(widget.conn).getHistory(
              series.itemName(),
              widget._settings.horScale.displayMin.round(),
              widget._settings.horScale.displayMax.round(),
              timePerPixel);

          if (data.isNotEmpty) {
            series.itemHistory = data;
          }

          series.displayName = Repository()
              .history
              .getNode(widget.conn)
              .value(series.itemName())
              .displayName;

          series.loadingTasks = Repository()
              .history
              .getNode(widget.conn)
              .getLoadingTasks(series.itemName());

          /*if (series.itemName == value.name) {
            series.dataByGroup[value.groupTimeRange] = TimeChartHistoryForGroup(value.groupTimeRange);
            series.dataByGroup[value.groupTimeRange]!.itemHistory = value.items;
          }*/
        }
      }
    });
  }

  @override
  void dispose() {
    _timerUpdateTimeRange.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  String dropdownValue = "5min";

  Widget buildTimeButton(String timeString) {
    bool isCurrent = dropdownValue == timeString;

    return Container(
      margin: const EdgeInsets.only(
        left: 5,
      ),
      padding: const EdgeInsets.only(left: 0, top: 3, right: 0, bottom: 3),
      //height: 25,
      child: TextButton(
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(
            isCurrent ? DesignColors.accent() : DesignColors.fore(),
          ),
          backgroundColor: MaterialStateProperty.all(
            isCurrent ? DesignColors.back2() : DesignColors.back1(),
          ),
        ),
        onPressed: () {
          setState(() {
            dropdownValue = timeString;
            widget._settings.setFixedHorScale(false);
            widget._settings.resetToDefaultDisplayRange();
          });

          SharedPreferences.getInstance().then((sharedPref) {
            sharedPref.setString(
                "time_chart_default_last_period", dropdownValue);
          });

          widget.onChanged();
        },
        child: SizedBox(
          width: 70,
          //height: 20,
          child: Container(
            //color: Colors.blueAccent,
            child: Center(
              child: Text(
                displayPeriodName(timeString),
                style: TextStyle(
                    fontSize: isCurrent ? 16 : 14,
                    fontWeight:
                        isCurrent ? FontWeight.normal : FontWeight.normal),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTimeFilterCombobox(context) {
    return DropdownButton<String>(
      value: dropdownValue,
      onChanged: (String? newValue) {
        setState(
          () {
            dropdownValue = newValue!;
            widget._settings.setFixedHorScale(false);
            widget._settings.resetToDefaultDisplayRange();
          },
        );
      },
      //itemHeight: 40,
      //dropdownColor: Colors.teal.withOpacity(0.5),
      style: TextStyle(
        fontSize: 14,
      ),
      items: <String>[
        "1min",
        "5min",
        "10min",
        "30min",
        "60min",
        "3hours",
        "6hours",
        "12hours",
        "24hours",
        "7days",
        "30days",
        "180days",
        "365days",
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget buildTimeFilterButtons(context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        List<Widget> buttons = [
          buildTimeButton("5min"),
          buildTimeButton("30min"),
          buildTimeButton("60min"),
          buildTimeButton("3hours"),
          buildTimeButton("12hours"),
          buildTimeButton("24hours"),
          buildTimeButton("7days"),
        ];

        int countOfButtons = (constraints.maxWidth / 120).round();
        if (countOfButtons < 1) {
          countOfButtons = 1;
        }
        if (countOfButtons > buttons.length) {
          countOfButtons = buttons.length;
        }

        return Row(
          children: buttons.getRange(0, countOfButtons).toList(),
        );
      },
    );
  }

  Widget buildTimeFilter(context) {
    return Container(
      padding: const EdgeInsets.only(left: 3),
      //height: 36,
      child: Row(
        children: [
          buildTimeFilterCombobox(context),
          Expanded(child: buildTimeFilterButtons(context)),
        ],
      ),
    );
  }

  final FocusNode _focusNode = FocusNode();

  bool keyControl = false;
  bool keyShift = false;
  bool keyAlt = false;

  /*
DragTarget<DataItemsObject>(
      builder: (
          BuildContext context,
          List<dynamic> accepted,
          List<dynamic> rejected,
          ) {
        return text();


                },
      onAcceptWithDetails: (details) {
        var data = details.data;
        var areaIndex = widget._settings.findAreaIndexByXY(details.offset.dx, details.offset.dy);
        if (areaIndex < 0) {
          setState(() {
            widget._settings.areas
                .add(TimeChartSettingsArea(widget.conn, <TimeChartSettingsSeries>[TimeChartSettingsSeries(widget.conn, data.name, [], Colors.blueAccent)], false));
          });
        } else {
          setState(() {
            widget._settings.areas[areaIndex].series.add(TimeChartSettingsSeries(widget.conn, data.name, [], Colors.blueAccent));
          });

        }
      },
    );

   */

  RenderBox? lastRenderBox_;

  MouseCursor chartCursor() {
    return widget._settings.mouseCursor();

    /*if (widget._settings.keyControl) {
      print("cursor wait");
      return SystemMouseCursors.wait;
    }*/
    return SystemMouseCursors.basic;
  }

  String acceptedData = "";
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildTimeFilter(context),
        Expanded(
          child: RawKeyboardListener(
            focusNode: _focusNode,
            onKey: (ev) {
              setState(() {
                keyControl = ev.isControlPressed;
                keyAlt = ev.isAltPressed;
                keyShift = ev.isShiftPressed;
                widget._settings.setKeys(keyControl, keyAlt, keyShift);
              });
              //print("key: ${keyControl}");
            },
            child: MouseRegion(
              cursor: chartCursor(),
              onEnter: (ev) {
                setState(() {
                  widget._settings.onEnter(ev);
                });
              },
              onExit: (ev) {
                setState(() {
                  widget._settings.onLeave(ev);
                });
              },
              child: Listener(
                onPointerDown: (PointerDownEvent ev) {
                  FocusScope.of(context).requestFocus(_focusNode);
                  widget.onChanged();
                },
                onPointerMove: (PointerMoveEvent ev) {},
                onPointerUp: (PointerUpEvent ev) {
                  setState(() {});
                  widget.onChanged();
                },
                onPointerSignal: (pointerSignal) {
                  FocusScope.of(context).requestFocus(_focusNode);
                  if (pointerSignal is PointerScrollEvent) {
                    //print("scroll ${pointerSignal.scrollDelta.dy}");
                    widget._settings.scroll(pointerSignal.scrollDelta.dy);
                  }
                },
                onPointerHover: (event) {
                  setState(() {
                    widget._settings.onHover(event.localPosition);
                  });
                  widget.onChanged();
                },
                child: GestureDetector(
                  onHorizontalDragStart: (DragStartDetails ev) {
                    print("onHorizontalDragStart ${ev.kind?.index}");
                    FocusScope.of(context).requestFocus(_focusNode);
                    widget._settings.startMoving(ev.localPosition.dx);
                    widget.onChanged();
                  },
                  onHorizontalDragUpdate: (DragUpdateDetails ev) {
                    setState(() {
                      widget._settings.updateMoving(ev.localPosition.dx);
                    });
                    widget.onChanged();
                  },
                  onHorizontalDragEnd: (DragEndDetails ev) {
                    setState(() {
                      widget._settings.finishMoving();
                    });
                    widget.onChanged();
                  },
                  onTapDown: (ev) {
                    setState(() {
                      widget._settings.onTapDown(ev.localPosition);
                    });
                    FocusScope.of(context).requestFocus(_focusNode);
                    widget.onChanged();
                  },
                  /*onVerticalDragStart: (DragStartDetails ev) {
                settings.startMovingY(ev.localPosition.dy);
              },
              onVerticalDragUpdate: (DragUpdateDetails ev) {
                setState(() {
                  settings.updateMovingY(ev.localPosition.dy);
                });
              },
              onVerticalDragEnd: (DragEndDetails ev) {
                setState(() {
                  settings.finishMovingY();
                });
              },*/
                  /*
              onDoubleTap: () {
                settings.doubleTap();
              },*/
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
                      return CustomPaint(
                        painter: TimeChartPainter(widget._settings,
                            (int groupTimeRange, int dtBegin, int dtEnd) {
                          //currentGroupTimeRange = groupTimeRange;
                        }),
                        child: Container(),
                        key: UniqueKey(),
                      );
                    },
                    onAcceptWithDetails: (details) {
                      if (lastRenderBox_ != null) {
                        //var localOffset = lastRenderBox_!.globalToLocal(details.offset);
                        var data = details.data;
                        setState(() {
                          widget._settings.addSeries(data.name);
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
