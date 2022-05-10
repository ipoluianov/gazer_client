import 'package:flutter/material.dart';
import 'package:gazer_client/widgets/borders/border_05_left_navigator.dart';

class LeftNavigatorButton extends StatefulWidget {
  final int index;
  final String text;
  final IconData iconData;
  final Function()? onPress;
  final Color color;
  final bool isCurrent;

  const LeftNavigatorButton(this.index, this.text, this.iconData, this.onPress, this.color, this.isCurrent, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return LeftNavigatorButtonState();
  }

}

class LeftNavigatorButtonState extends State<LeftNavigatorButton> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      height: 90,
      padding: const EdgeInsets.all(3),
      child: GestureDetector(
        onTap: widget.onPress,
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
          child: Stack(
            children: [
              Border05Painter.build(hover, widget.isCurrent),
              SizedBox(
                width: 60,
                height: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.iconData,
                      size: 36,
                      color: widget.color,
                    ),
                    Text(
                      widget.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: widget.color,
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

}