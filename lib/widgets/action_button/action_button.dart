import 'package:flutter/material.dart';
import 'package:gazer_client/core/design.dart';
import 'package:gazer_client/widgets/borders/border_04_action_button.dart';

class ActionButton extends StatefulWidget {
  final IconData? icon;
  final String? tooltip;
  final Function()? onPress;
  final bool? checked;
  final Color? imageColor;
  final Color? backColor;

  const ActionButton({this.icon, this.tooltip, this.onPress, this.backColor, this.checked, this.imageColor, Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ActionButtonState();
  }
}

class ActionButtonState extends State<ActionButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    Widget markerTop = Container(
      height: 1,
      color: Colors.transparent,
    );
    Widget markerBottom = Container(
      height: 1,
      color: Colors.transparent,
    );
    if (widget.checked ?? false) {
      markerTop = Container(
        height: 1,
        color: Colors.blueAccent,
      );
      markerBottom = Container(
        height: 1,
        color: Colors.blueAccent,
      );
    }

    Color imageColor = widget.imageColor ?? DesignColors.fore();
    Color backColor = widget.backColor ?? Colors.black38;

    return SizedBox(
      width: 56,
      height: 56,
      child: Padding(
        key: Key(widget.key.toString() + "_button_content"),
        padding: const EdgeInsets.all(3),
        child: Stack(
          children: [
            Border04Painter.build(hover),
            MouseRegion(
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
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    markerTop,
                    IconButton(
                      tooltip: widget.tooltip,
                      onPressed: () {
                        if (widget.onPress != null) {
                          widget.onPress!();
                        }
                      },
                      icon: Icon(widget.icon),
                      color: imageColor,
                      //label: const Text("Home"),
                    ),
                    markerBottom,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
