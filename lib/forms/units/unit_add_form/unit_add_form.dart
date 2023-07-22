import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/protocol/unit_type/unit_type_categories.dart';
import 'package:gazer_client/core/protocol/unit_type/unit_type_list.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/forms/units/unit_add_form/unit_type.dart';

import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:gazer_client/widgets/title_widget/title_widget.dart';

import '../../../core/navigation/route_generator.dart';

class UnitAddForm extends StatefulWidget {
  final UnitAddFormArgument arg;
  const UnitAddForm({Key? key, required this.arg}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UnitAddFormSt();
  }
}

class UnitAddFormSt extends State<UnitAddForm> {
  @override
  void initState() {
    super.initState();

    timerLoad = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      loadCategories();
      loadUnitTypes();
    });
  }

  late Timer timerLoad;

  bool categoriesLoading = false;
  bool categoriesLoaded = false;

  bool unitTypesLoading = false;
  bool unitTypesLoaded = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    timerLoad.cancel();
    super.dispose();
  }

  List<UnitTypeListItemResponse> types = [];
  List<UnitTypeCategoriesItemResponse> categories = [];

  void updateUnitTypes() {
    unitTypesLoading = false;
    unitTypesLoaded = false;
    loadUnitTypes();
  }

  void loadUnitTypes() {
    if (unitTypesLoading || unitTypesLoaded) return;
    unitTypesLoading = true;

    String category = "";
    if (selectedCategory != null) {
      category = selectedCategory!.name;
    }

    String loadingCategory = category;
    String loadingFilterString = filterString;

    Repository()
        .client(widget.arg.connection)
        .unitTypeList(loadingCategory, loadingFilterString, 0, 1000)
        .then((value) {
      String category = "";
      if (selectedCategory != null) {
        category = selectedCategory!.name;
      }
      if (loadingCategory == category && loadingFilterString == filterString) {
        setState(() {
          types = value.types;
          unitTypesLoading = false;
          unitTypesLoaded = true;
        });
      }
    }).catchError((err) {
      setState(() {
        unitTypesLoading = false;
        unitTypesLoaded = false;
      });
    });
  }

  void loadCategories() {
    if (categoriesLoading || categoriesLoaded) return;
    categoriesLoading = true;

    Repository()
        .client(widget.arg.connection)
        .unitTypeCategories()
        .then((value) {
      print("load cats");
      setState(() {
        categories = value.items;
      });
      for (var item in categories) {
        if (item.name == "") {
          selectedCategory = item;
          break;
        }
      }
      categoriesLoading = false;
      categoriesLoaded = true;
    }).catchError((err) {
      categoriesLoading = false;
      categoriesLoaded = false;
      print("load cats error $err");
      setState(() {});
    });
  }

  Widget buildContentList(BuildContext context) {
    return Expanded(
      child: Scrollbar(
        thumbVisibility: true,
        controller: _scrollController,
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Wrap(
            children: types.asMap().entries.map((entry) {
              var w = UnitType(
                (unitType, str) {
                  Navigator.pushNamed(context, "/unit_edit",
                      arguments: UnitEditFormArgument(
                          widget.arg.connection, "", unitType));
                },
                entry.value,
                entry.key,
                key: Key(entry.value.type),
              );
              return w;
            }).toList(),
          ),
        ),
      ),
    );
  }

  UnitTypeCategoriesItemResponse? selectedCategory;
  String filterString = "";

  Widget buildCategoryComboBox(context) {
    return DropdownButton<UnitTypeCategoriesItemResponse>(
      value: selectedCategory,
      alignment: AlignmentDirectional.centerStart,
      isExpanded: true,
      onChanged: (UnitTypeCategoriesItemResponse? newValue) {
        setState(
          () {
            selectedCategory = newValue!;
          },
        );
        updateUnitTypes();
      },
      items: categories.map<DropdownMenuItem<UnitTypeCategoriesItemResponse>>(
          (UnitTypeCategoriesItemResponse value) {
        Uint8List _bytesImage = const Base64Decoder().convert(value.image);

        return DropdownMenuItem<UnitTypeCategoriesItemResponse>(
          value: value,
          child: Row(children: [
            ColorFiltered(
              colorFilter:
                  ColorFilter.mode(DesignColors.fore(), BlendMode.srcATop),
              child: Image.memory(
                _bytesImage,
                width: 24,
              ),
            ),
            SizedBox(
              width: 6,
            ),
            Text(value.displayName),
          ]),
        );
      }).toList(),
    );
  }

  Widget buildContent(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            buildCategoryComboBox(context),
            TextField(
              decoration: const InputDecoration(
                labelText: "Search",
              ),
              onChanged: (value) {
                filterString = value;
                updateUnitTypes();
              },
            ),
            const SizedBox(
              height: 10,
            ),
            buildContentList(context),
          ],
        ),
      ),
    );
  }

  String getCurrentTitleKey() {
    return "units_new_";
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool narrow = constraints.maxWidth < constraints.maxHeight;
        bool showLeft = !narrow;
        bool showBottom = narrow;

        return Scaffold(
          appBar: TitleBar(
            widget.arg.connection,
            "Add Unit",
            key: Key(getCurrentTitleKey()),
            actions: <Widget>[
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
}
