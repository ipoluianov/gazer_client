import 'package:flutter/material.dart';

class MessagesWidget extends StatefulWidget {

  final Color backgroundColor;

  const MessagesWidget(this.backgroundColor, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MessagesWidgetState();
  }

}

class MessagesWidgetState extends State<MessagesWidget> {
  String message = "";

  Widget buildMessages(BuildContext context) {
    if (message.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: Container()),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.green.withOpacity(0.5),
            ),
            constraints: const BoxConstraints(minWidth: 200),
            padding: const EdgeInsets.all(10),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    } else {
      return Container();
    }
  }


  @override
  Widget build(BuildContext context) {
    return buildMessages(context);
  }
}
