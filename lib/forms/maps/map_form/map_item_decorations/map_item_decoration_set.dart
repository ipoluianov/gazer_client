import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gazer_client/core/tools/hex_colors.dart';
import 'package:gazer_client/core/workspace/workspace.dart';
import 'package:gazer_client/forms/maps/map_form/map_item.dart';

import 'map_item_decoration.dart';

class MapItemDecorationList {
  List<MapItemDecoration> items = [];
  MapItemDecorationList(this.items);

  void moveItemToPosition(int index, int newIndex) {
    print("moving $index to $newIndex");
    if (index < 0 || index >= items.length) {
      return;
    }
    if (newIndex < 0 || newIndex >= items.length) {
      return;
    }

    var item = items[index];
    items.removeAt(index);
    items.insert(newIndex, item);
  }

  void moveUp(int index) {
    if (index < 0 || index >= items.length) {
      return;
    }
    if (index < 1) {
      return;
    }

    moveItemToPosition(index, index - 1);
  }

  void moveDown(int index) {
    if (index < 0 || index >= items.length) {
      return;
    }
    if (index >= items.length - 1) {
      return;
    }
    moveItemToPosition(index, index + 1);
  }
}
