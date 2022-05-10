import 'package:flutter/material.dart';

class ErrorBlock extends StatelessWidget {
  final String errorMessage;
  const ErrorBlock(this.errorMessage, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      errorMessage,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.red,
      ),
    );
  }
}
