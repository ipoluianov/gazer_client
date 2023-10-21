import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/core/protocol/resource/resource_add.dart';
import 'package:gazer_client/core/protocol/resource/resource_list.dart';
import 'package:gazer_client/core/repository.dart';
import 'package:gazer_client/core/navigation/bottom_navigator.dart';
import 'package:gazer_client/core/navigation/left_navigator.dart';
import 'package:gazer_client/core/navigation/navigation.dart';
import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:gazer_client/widgets/error_dialog/error_dialog.dart';
import 'package:gazer_client/widgets/error_widget/error_block.dart';
import 'package:gazer_client/widgets/title_bar/title_bar.dart';
import 'package:gazer_client/widgets/title_widget/title_widget.dart';

import '../../../../widgets/load_indicator/load_indicator.dart';
import 'resource_item_card.dart';

class ResourcesForm extends StatefulWidget {
  final ResourcesFormArgument arg;
  const ResourcesForm(this.arg, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ResourcesFormSt();
  }
}

enum ItemsFilter { items, favorite, template, all }

class ResourcesFormSt extends State<ResourcesForm> {
  late Timer _timerLoad;

  @override
  void initState() {
    super.initState();

    //filterByFolder = widget.arg.filterByFolder;
    currentFolder = widget.arg.folderId;

    _timerLoad = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {});
      if (loading()) return;
      if (loaded()) return;
      load();
    });

    load();
  }

  @override
  void dispose() {
    _timerLoad.cancel();
    super.dispose();
  }

  bool loadingItems = false;
  bool loadedItems = false;
  bool loadingFolders = false;
  bool loadedFolders = false;
  String errorMessageItems = "";
  String errorMessageFolders = "";

  List<ResListItemItemResponse> items = [];
  List<ResListItemItemResponse> folders = [];

  ScrollController scrollController1 = ScrollController();
  ScrollController scrollController2 = ScrollController();

  ItemsFilter filter = ItemsFilter.all;

  String currentFolder = "";

  String errorMessage() {
    return errorMessageItems + errorMessageFolders;
  }

  bool loading() {
    return loadingItems || loadingFolders;
  }

  bool loaded() {
    return loadedItems && loadedFolders;
  }

  void load() {
    loadItems();
    loadFolders();
  }

  Future<void> processOnCreated(ResAddResponse value) async {
    Future.delayed(const Duration(milliseconds: 700)).then((v) {
      if (widget.arg.onCreated != null) {
        var resp = value;
        widget.arg.onCreated!(context, resp.id);
      }
    });
  }

  void loadFolders() {
    if (loadingFolders) {
      return;
    }
    loadingFolders = true;
    Repository()
        .client(widget.arg.connection)
        .resList("${widget.arg.type}_folder", "", 0, 10000)
        .then((value) {
      loadingFolders = false;
      if (mounted) {
        setState(() {
          folders = [];
          //folders.add(ResListItemItemResponse("", widget.arg.type + "_folder", [ResListItemItemPropResponse("name", "[no name]"), ResListItemItemPropResponse("%default_folder%", "1")], Uint8List(0)));
          folders.addAll(value.item.items);
          loadedFolders = true;
          loadingFolders = false;
          errorMessageFolders = "";
        });
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          loadedFolders = false;
          loadingFolders = false;
          errorMessageFolders = e.toString();
        });
      }
    });
  }

  void loadItems() {
    if (loadingItems) {
      return;
    }
    loadingItems = true;
    Repository()
        .client(widget.arg.connection)
        .resList(widget.arg.type, "", 0, 10000)
        .then((value) {
      loadingItems = false;
      if (mounted) {
        setState(() {
          items = value.item.items;
          items.sort((var r1, var r2) {
            return r1.getProp("name").compareTo(r2.getProp("name"));
          });
          loadedItems = true;
          loadingItems = false;
          errorMessageItems = "";
        });
      }
    }).catchError((e) {
      if (mounted) {
        setState(() {
          loadedItems = false;
          loadingItems = false;
          errorMessageItems = e.toString();
        });
      }
    });
  }

  List<ResListItemItemResponse> itemsInFolder(String folderId) {
    List<ResListItemItemResponse> res = [];

    List<ResListItemItemResponse> itemsAndFolders = [];
    itemsAndFolders.addAll(folders);
    itemsAndFolders.addAll(items);

    for (var i in itemsAndFolders) {
      if (i.getProp("folder") == folderId) {
        res.add(i);
      }
    }
    return res;
  }

  String currentFolderName() {
    return " - " + widget.arg.folderName;
  }

  String fullFolderName() {
    String result = "";
    List<ResListItemItemResponse> itemsAndFolders = [];
    itemsAndFolders.addAll(folders);
    itemsAndFolders.addAll(items);

    String current = currentFolder;
    //result = current + "/" + result;
    for (var i in itemsAndFolders) {
      if (i.id == current) {
        result = i.getProp("name") + "/" + result;
        current = i.getProp("folder");
        if (current.isEmpty) {
          break;
        }
      }
    }

    return result;
  }

  Widget buildEmptyNodeList(context) {
    return Expanded(
      child: DesignColors.buildScrollBar(
        controller: scrollController1,
        child: SingleChildScrollView(
          controller: scrollController1,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                child: const Text(
                  "No items to display",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white30,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: OutlinedButton(
                        onPressed: () {
                          addFolder();
                        },
                        child: SizedBox(
                          width: 150,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.create_new_folder_outlined,
                                  size: 32,
                                ),
                                Text("Add folder"),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      child: ElevatedButton(
                        onPressed: () {
                          addItem();
                        },
                        child: SizedBox(
                          width: 150,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: const [
                                Icon(
                                  Icons.add,
                                  size: 32,
                                ),
                                Text("Add item"),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildToolbar(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        List<Widget> leftButtons = [];
        List<Widget> rightButtons = [];

        leftButtons.add(buildActionButton(
            context, Icons.add, "Add ${widget.arg.typeName}", () {
          addItem();
        }));
        leftButtons.add(buildActionButton(
            context, Icons.create_new_folder_outlined, "Add Folder", () {
          addFolder();
        }));

        rightButtons.add(buildActionButtonFull(
            context, Icons.favorite, "Favorites", () {
          if (filter == ItemsFilter.favorite) {
            if (mounted) {
              setState(() {
                filter = ItemsFilter.all;
              });
            }
          } else {
            if (mounted) {
              setState(() {
                filter = ItemsFilter.favorite;
              });
            }
          }
        }, false,
            imageColor: (filter == ItemsFilter.favorite)
                ? DesignColors.accent()
                : DesignColors.fore2()));

        leftButtons.add(Expanded(child: Container()));
        leftButtons.addAll(rightButtons);
        return Row(
          children: leftButtons,
        );
      },
    );
  }

  Widget buildForm(BuildContext context) {
    return Expanded(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildToolbar(context),
        Container(
          color: DesignColors.fore2(),
          height: 1,
        ),
        buildContent(context),
      ],
    ));
  }

  Widget buildContent(BuildContext context) {
    if (loading()) {
      return const LoadIndicator();
    }

    if (errorMessage().isNotEmpty) {
      return ErrorBlock(errorMessage());
    }

    List<ResListItemItemResponse> itemsAndFolders = [];
    itemsAndFolders.addAll(folders);
    itemsAndFolders.addAll(items);

    var itemsToShowInFolder = itemsAndFolders.where((element) {
      var elFolder = element.getProp("folder");
      if (currentFolder.isNotEmpty) {
        if (elFolder != currentFolder) {
          return false;
        }
      } else {
        bool folderExists = false;
        for (var f in folders) {
          if (f.id == elFolder) {
            folderExists = true;
            break;
          }
        }
        if (folderExists && elFolder != currentFolder) {
          return false;
        }
      }
      return true;
    });

    var itemsToShow = itemsToShowInFolder.where((element) {
      if (filter == ItemsFilter.all) {
        return true;
      }
      if (element.type.endsWith("_folder")) {
        return true;
      }
      if (filter == ItemsFilter.favorite) {
        if (element.getProp("favorite").isNotEmpty) {
          return true;
        }
      }
      return false;
    });

    if (itemsToShowInFolder.isEmpty) {
      return buildEmptyNodeList(context);
    }

    return Expanded(
      child: DesignColors.buildScrollBar(
        controller: scrollController2,
        child: SingleChildScrollView(
          controller: scrollController2,
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              children: itemsToShow.map<Widget>(
                (e) {
                  return DragTarget<ResListItemItemResponse>(
                    builder: (context, candidateData, rejectedData) {
                      return ResourceItemCard(
                        widget.arg.connection,
                        e,
                        widget.arg.iconData,
                        itemsInFolder(e.id),
                        () {
                          if (e.type == widget.arg.type) {
                            widget.arg.onClick(context, e);
                          }

                          if (e.type == widget.arg.type + "_folder") {
                            Navigator.of(context)
                                .pushNamed(
                              "/select_resource",
                              arguments: ResourcesFormArgument(
                                widget.arg.connection,
                                widget.arg.type,
                                widget.arg.typeName,
                                widget.arg.typeNamePlural,
                                widget.arg.iconData,
                                false,
                                true,
                                e.id,
                                e.getProp("name"),
                                widget.arg.onClick,
                                widget.arg.onCreated,
                              ),
                            )
                                .then((value) {
                              load();
                            }).catchError((err) {
                              showErrorDialog(context, "$err");
                            });
                          }
                          //Navigator.pop(context, e);
                        },
                        () {
                          Navigator.of(context)
                              .pushNamed("/resource_rename",
                                  arguments: ResourceChangeFormArgument(
                                      widget.arg.connection,
                                      e.id,
                                      e,
                                      widget.arg.type,
                                      widget.arg.typeName,
                                      widget.arg.typeNamePlural))
                              .then((value) {
                            load();
                          });
                        },
                        () {
                          Repository()
                              .client(widget.arg.connection)
                              .resPropSet(e.id, {"folder": ""}).then((value) {
                            load();
                          }).catchError((err) {
                            showErrorDialog(context, "$err");
                          });
                        },
                        () {
                          load();
                        },
                        () {
                          Repository()
                              .client(widget.arg.connection)
                              .resRemove(e.id)
                              .then((value) {
                            //print("load after remove");
                            load();
                          }).catchError((err) {
                            showErrorDialog(context, "$err");
                          });
                        },
                        () {
                          Navigator.of(context)
                              .pushNamed("/resource_info",
                                  arguments: ResourceInfoFormArgument(
                                      widget.arg.connection,
                                      e.id,
                                      e,
                                      widget.arg.type,
                                      widget.arg.typeName,
                                      widget.arg.typeNamePlural))
                              .then((value) {
                            load();
                          });
                        },
                        key: Key(widget.arg.type + "item_card_" + e.id),
                      );
                    },
                    onAcceptWithDetails: (details) {
                      if (e.type == widget.arg.type + "_folder") {
                        if (details.data.id != e.id) {
                          Repository().client(widget.arg.connection).resPropSet(
                              details.data.id, {"folder": e.id}).then((value) {
                            load();
                          }).catchError((err) {
                            showErrorDialog(context, "$err");
                          });
                        }
                      }
                    },
                  );
                },
              ).toList(),
            ),
          ),
        ),
      ),
    );
  }

  void addFolder() {
    Navigator.of(context)
        .pushNamed("/resource_add",
            arguments: ResourceItemAddFormArgument(
                widget.arg.connection,
                "${widget.arg.type}_folder",
                currentFolder,
                "Folder",
                "Folders"))
        .then((value) {
      if (value != null) {
        load();
      }
    });
  }

  void addItem() {
    Navigator.of(context)
        .pushNamed("/resource_add",
            arguments: ResourceItemAddFormArgument(
                widget.arg.connection,
                widget.arg.type,
                currentFolder,
                widget.arg.typeName,
                widget.arg.typeNamePlural))
        .then((value) {
      if (value != null) {
        load();
        processOnCreated(value as ResAddResponse);
      }
    });
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
            "${widget.arg.typeNamePlural} ${fullFolderName()}",
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
                      buildForm(context),
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
