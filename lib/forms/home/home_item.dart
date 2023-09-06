import 'package:flutter/material.dart';

import '../../core/navigation/route_generator.dart';

abstract class HomeItem extends StatefulWidget {
  final HomeFormArgument arg;
  final String config;
  const HomeItem(this.arg, this.config, {super.key});

  String title() {
    return "";
  }
}
