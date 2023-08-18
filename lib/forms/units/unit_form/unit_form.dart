import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/gazer_local_client.dart';
import 'package:gazer_client/core/gazer_style.dart';
import 'package:gazer_client/core/protocol/unit/unit_state.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/widgets/borders/border_01_item.dart';
import 'package:gazer_client/widgets/borders/border_08_item_list_item.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/forms/units/unit_form/widget_dataitem_detail.dart';
import 'package:gazer_client/widgets/error_dialog/error_dialog.dart';
import 'package:gazer_client/widgets/time_chart/time_chart.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_settings.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_settings_area.dart';
import 'package:gazer_client/widgets/time_chart/time_chart_settings_series.dart';
import 'package:gazer_client/widgets/time_table/time_table.dart';
import 'package:gazer_client/widgets/time_table/time_table_settings.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';

import '../../../core/navigation/route_generator.dart';

class UnitForm extends StatefulWidget {
  final UnitFormArgument arg;
  const UnitForm({Key? key, required this.arg}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UnitFormSt();
  }
}

class UnitFormSt extends State<UnitForm> {
  late Timer _timer;
  late TimeChartSettings _chartSettings;
  late TimeTableSettings _tableSettings;
  int hoverIndex = -1;
  int selectedIndex = -1;
  String unitName = "";
  String mainItem = "";

  String itemPropView = "";
  bool itemPropLoading = false;

  bool unitInfoLoading = false;
  bool unitInfoLoaded = false;

  late UnitStateResponse unitState;
  List<UnitStateValuesResponseItem> filteredItems = [];

  @override
  void initState() {
    super.initState();

    _chartSettings = TimeChartSettings(widget.arg.connection, []);
    _tableSettings = TimeTableSettings(widget.arg.connection);

    unitState =
        UnitStateResponse(widget.arg.unitId, "", "", "", "", "", "", "", []);

    _timer = Timer.periodic(const Duration(milliseconds: 500), (t) {
      updateUnitInfo();
      updateItems();
      loadItemProperties();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void updateUnitInfo() {
    if (unitInfoLoading || unitInfoLoaded) return;
    unitInfoLoading = true;

    unitName = widget.arg.unitId;
    Repository()
        .client(widget.arg.connection)
        .unitPropGet(widget.arg.unitId)
        .then((value) {
      setState(() {
        mainItem = value.getProp("main_item");
      });
      unitInfoLoaded = true;
      unitInfoLoading = false;
      updateItems();
    }).catchError((err) {
      unitInfoLoaded = false;
      unitInfoLoading = false;
    });
  }

  bool unitStateLoading = false;
  bool unitStateLoaded = false;

  void updateItems() {
    if (unitStateLoading) return;
    if (!unitInfoLoaded) {
      return;
    }
    unitStateLoading = true;

    GazerLocalClient client = Repository().client(widget.arg.connection);
    client.unitsState(widget.arg.unitId).then((value) {
      if (mounted) {
        setState(() {
          unitName = value.unitName;
          unitState = value;
          unitStateLoaded = true;
          filteredItems = unitState.items.where((i) {
            return !i.name.contains('/.service/');
          }).toList();
          goToMainItem();
        });
        unitStateLoading = false;
      }
    }).catchError((err) {
      unitStateLoading = false;
    });
  }

  String formatDateTime(DateTime dt) {
    String result = "";
    result +=
        '${dt.year}-${dt.month}-${dt.day} ${dt.hour}:${dt.minute}:${dt.second}';
    return result;
  }

  String shortName(String itemName) {
    return itemName.replaceAll("${widget.arg.unitId}/", "");
  }

  bool itemPropsLoading = false;
  bool itemPropsLoaded = false;
  String itemPropsItem = "";

  void loadItemProperties() {
    if (itemPropsLoading) return;
    if (itemPropsLoaded) return;

    String currentItem = itemPropsItem;

    Repository()
        .client(widget.arg.connection)
        .dataItemPropGet(currentItem)
        .then((value) {
      if (mounted) {
        if (currentItem == itemPropsItem) {
          setState(() {
            itemPropView = value.getProp("view");
            itemPropLoading = false;
          });
        }
      }
    }).catchError((err) {});
  }

  ScrollController listScrollController = ScrollController();

  bool mainItemSelected = false;

  void selectItemByIndex(int index) {
    setState(() {
      selectedIndex = index;
      var itemName = getSelectedItem(filteredItems).name;

      _chartSettings.areas = [];
      _chartSettings.areas.add(TimeChartSettingsArea(
          widget.arg.connection, <TimeChartSettingsSeries>[
        TimeChartSettingsSeries(
            widget.arg.connection, itemName, [], DesignColors.fore())
      ]));
    });
  }

  void goToMainItem() {
    if (!mainItemSelected &&
        mainItem != "" &&
        unitInfoLoaded &&
        unitStateLoaded) {
      mainItemSelected = true;
      for (int i = 0; i < filteredItems.length; i++) {
        if (filteredItems[i].name == mainItem) {
          selectItemByIndex(i);
          break;
        }
      }

      /*double listHeight = filteredItems.length * 45;

      double scrollPosition = 0;
      listScrollController.jumpTo(scrollPosition);*/
    }
  }

  Widget buildTable(
      List<UnitStateValuesResponseItem> items, bool showPopupMenu) {
    //return Text("Table");
    showPopupMenu = false;

    return DesignColors.buildScrollBar(
      controller: listScrollController,
      child: ListView(
        controller: listScrollController,
        children: items.asMap().keys.map<Widget>((index) {
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (event) {
              setState(() {
                hoverIndex = index;
              });
            },
            onExit: (event) {
              setState(() {
                hoverIndex = -1;
              });
            },
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectItemByIndex(index);
                  itemPropLoading = true;
                });
                if (itemPropsItem != items[index].name) {
                  itemPropsItem = items[index].name;
                  itemPropsLoading = false;
                  itemPropsLoaded = false;
                  loadItemProperties();
                }
              },
              child: Container(
                padding: const EdgeInsets.all(0),
                child: SizedBox(
                  height: 40,
                  child: Stack(
                    children: [
                      Border08Painter.build(
                          hoverIndex == index, selectedIndex == index),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          showPopupMenu
                              ? PopupMenuButton<String>(
                                  onSelected: (sss) {},
                                  enableFeedback: false,
                                  icon: const Icon(Icons.menu_open),
                                  itemBuilder: (BuildContext context) {
                                    return {'Logout', 'Settings'}
                                        .map((String choice) {
                                      return PopupMenuItem<String>(
                                        value: choice,
                                        height: 30,
                                        child: Text(choice),
                                      );
                                    }).toList();
                                  },
                                )
                              : Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.menu_open,
                                    color: DesignColors.fore(),
                                  ),
                                ),
                          Container(
                            constraints: const BoxConstraints(minWidth: 50),
                            child: Text(
                              shortName(items[index].name),
                              style: TextStyle(
                                color: items[index].name == mainItem
                                    ? DesignColors.accent()
                                    : DesignColors.fore(),
                                fontSize:
                                    items[index].name == mainItem ? 16 : 14,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              constraints: const BoxConstraints(minWidth: 50),
                              padding: const EdgeInsets.only(right: 20),
                              child: Text(
                                items[index].value.value +
                                    " " +
                                    items[index].value.uom,
                                style: TextStyle(
                                  color: colorByUOM(items[index].value.uom),
                                ),
                                textAlign: TextAlign.right,
                                overflow: TextOverflow.ellipsis,
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
          );
        }).toList(),
      ),
    );
  }

  UnitStateValuesResponseItem getSelectedItem(
      List<UnitStateValuesResponseItem> items) {
    if (selectedIndex >= 0 && selectedIndex < items.length) {
      return items[selectedIndex];
    }
    return UnitStateValuesResponseItem.makeDefault();
  }

  Widget buildItemContent(
      BuildContext context, List<UnitStateValuesResponseItem> items) {
    if (itemPropLoading) {
      return Center(
          child: SizedBox(
              width: 32, height: 32, child: CircularProgressIndicator()));
    }
    if (itemPropView == "control-01") {
      return Container(
        color: Colors.black26,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  Repository()
                      .client(widget.arg.connection)
                      .dataItemWrite(items[selectedIndex].name, "1");
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  child: const Text(
                    "On",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: () {
                  Repository()
                      .client(widget.arg.connection)
                      .dataItemWrite(items[selectedIndex].name, "0");
                },
                child: Container(
                  margin: const EdgeInsets.all(10),
                  child: const Text(
                    "Off",
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (itemPropView == "table-01") {
      return Border01Painter.build(false);
      return TimeTable(
        widget.arg.connection,
        getSelectedItem(items).name,
        _tableSettings,
        () {},
        key: Key("page_units_unit_table_" + getSelectedItem(items).name),
      );
    }

    return TimeChart(
      widget.arg.connection,
      getSelectedItem(items).name,
      _chartSettings,
      () {},
      key: Key("page_units_unit_chart_" + getSelectedItem(items).name),
    );
  }

  Widget buildWide(
      BuildContext context, List<UnitStateValuesResponseItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  //color: Colors.blue,
                  child: buildTable(items, false),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  //color: Colors.green,
                  child: buildDetails(getSelectedItem(items)),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 0.5,
          color: DesignColors.fore(),
        ),
        Expanded(
          child: buildItemContent(context, items),
        ),
      ],
    );
  }

  Widget buildNarrow(BuildContext context,
      List<UnitStateValuesResponseItem> items, BoxConstraints constraints) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  //color: Colors.blue,
                  child: buildTable(items, true),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: buildItemContent(context, items),
        ),
      ],
    );
  }

  Widget buildFetched(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (constraints.maxWidth > 600) {
          return buildWide(context, filteredItems);
        } else {
          return buildNarrow(context, filteredItems, constraints);
        }
      },
    );
  }

  Widget buildDetails(UnitStateValuesResponseItem item) {
    var client = Repository().client(widget.arg.connection);
    return WidgetDataItemDetail(
        widget.arg.connection, client, unitName, widget.arg.unitId, item, () {
      unitInfoLoaded = false;
      updateUnitInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool narrow = constraints.maxWidth < constraints.maxHeight;
        bool showExtraButtons = constraints.maxWidth > 500;
        bool showLeft = !narrow;
        bool showBottom = narrow;

        return Scaffold(
          appBar: TitleBar(
            widget.arg.connection,
            unitName,
            actions: <Widget>[
              showExtraButtons
                  ? buildActionButton(context, Icons.play_arrow, "Start", () {
                      Repository()
                          .client(widget.arg.connection)
                          .unitsStart([widget.arg.unitId]).then((value) {
                        //cubit.load(widget.arg.connection, widget.arg.unitId);
                        updateItems();
                      }).catchError((err) {
                        showErrorDialog(context, "$err");
                      });
                    })
                  : Container(),
              showExtraButtons
                  ? buildActionButton(context, Icons.pause, "Stop", () {
                      Repository()
                          .client(widget.arg.connection)
                          .unitsStop([widget.arg.unitId]).then((value) {
                        updateItems();
                      }).catchError((err) {
                        showErrorDialog(context, "$err");
                      });
                    })
                  : Container(),
              buildActionButton(context, Icons.edit, "Edit", () {
                Navigator.pushNamed(context, "/unit_edit",
                        arguments: UnitEditFormArgument(
                            widget.arg.connection, widget.arg.unitId, ""))
                    .then((value) {
                  setState(() {
                    try {
                      unitName = value as String;
                    } catch (_) {}
                  });
                });
              }),
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
                      Expanded(
                        child: buildFetched(context),
                      ),
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
}
