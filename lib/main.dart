import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:flutter/material.dart';
import 'forms/nodes/main_form/main_form.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Gazer Client',
      debugShowCheckedModeBanner: false,
      home: const MainForm(),
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        textTheme: const TextTheme(
          bodyText2: TextStyle(fontWeight: FontWeight.w300),
          bodyText1: TextStyle(fontWeight: FontWeight.w300),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    ),
  );

  return;
}
