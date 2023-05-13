import 'package:flutter/material.dart';

InputDecoration textInputDecoration() {
  return const InputDecoration(
    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 6),
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.transparent),
    ),
    fillColor: Colors.black,
    filled: true,
    hoverColor: Colors.black12,
    constraints: BoxConstraints(maxHeight: 30),
  );
}
