import 'dart:convert';
import 'dart:typed_data';

import 'package:gazer_client/core/protocol/unit_type/unit_type_list.dart';
import 'package:flutter/material.dart';
import 'package:gazer_client/widgets/borders/border_01_item.dart';

class UnitType extends StatefulWidget {
  final Function(String, String) onClicked;
  final UnitTypeListItemResponse unitType;
  final int index;
  const UnitType(this.onClicked, this.unitType, this.index, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return UnitTypeState();
  }
}

class UnitTypeState extends State<UnitType> with TickerProviderStateMixin {
  bool hover = false;

  late final Uint8List _bytesImage = const Base64Decoder().convert(widget.unitType.Image);

  @override
  Widget build(BuildContext context) {
    return buildUnit();
  }

  @override
  void dispose() {
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  void gotoUnit(String unitType, String unitId) {
    widget.onClicked(unitType, unitId);
  }

  late final AnimationController _controller = AnimationController(
    vsync: this,
  )..animateTo(1,
      duration: Duration(
        milliseconds: widget.index * 20,
      ),
      curve: Curves.linear);
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

  Widget buildUnit() {
    return ScaleTransition(
      scale: _animation,
      child: MouseRegion(
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
            gotoUnit(widget.unitType.type, "");
          },
          child: Container(
            color: Colors.black26,
            child: Container(
              padding: const EdgeInsets.all(10),
              width: 300,
              height: 80,
              child: Stack(
                children: [
                  Border01Painter.build(hover),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.mode(Colors.orange, BlendMode.srcATop),
                          child: Image.memory(_bytesImage),
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            widget.unitType.displayName,
                            overflow: TextOverflow.fade,
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      Card(
                          color: Colors.black38,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Container()),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
