import 'package:flutter/material.dart';

import '../../core/design.dart';
import '../../core/navigation/route_generator.dart';

abstract class HomeItem extends StatefulWidget {
  final HomeFormArgument arg;
  final String config;
  HomeItem(this.arg, this.config, {super.key});

  Map<String, String> configMap = {};

  String toJson() {
    return "";
  }

  Widget buildH1(String text) {
    List<Widget> ws = [];
    ws.add(
      Container(
        constraints: const BoxConstraints(minHeight: 6),
        color: Colors.transparent,
      ),
    );

    ws.add(
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 24, fontFamily: "RobotoMono"),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
        ],
      ),
    );

    ws.add(
      Container(
        constraints: const BoxConstraints(minHeight: 1),
        color: DesignColors.fore1(),
      ),
    );

    ws.add(Container(
      height: 6,
    ));

    return Container(
      margin: EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: ws,
      ),
    );
  }
}
