import 'package:flutter/material.dart';

class LoadIndicator extends StatelessWidget {
  const LoadIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Expanded(
          child: LinearProgressIndicator(
            minHeight: 3,
          ),
        ),
      ],
    );
  }
}
