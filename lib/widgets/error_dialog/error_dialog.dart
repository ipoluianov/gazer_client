import 'package:flutter/material.dart';

import '../../core/design.dart';

Future<void> showErrorDialog(BuildContext context, String text) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: DesignColors.back(),
        shadowColor: DesignColors.fore(),
        title: Text(
          "Error",
          style: TextStyle(
            color: DesignColors.fore1(),
            fontSize: 16,
          ),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                text,
                style: TextStyle(
                  color: DesignColors.fore(),
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            child: const SizedBox(
              width: 70,
              child: Center(child: Text('OK')),
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );
}
