import 'package:gazer_client/core/navigation/route_generator.dart';
import 'package:flutter/material.dart';
import 'forms/nodes/main_form/main_form.dart';

void main() {
  FontWeight fontWeight = FontWeight.w400;

  runApp(
    MaterialApp(
      title: 'Gazer Client',
      debugShowCheckedModeBanner: false,
      home: const MainForm(),
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        fontFamily: "Roboto",
        textTheme: TextTheme(
          bodySmall: TextStyle(fontWeight: fontWeight),
          bodyLarge: TextStyle(fontWeight: fontWeight),
          bodyMedium: TextStyle(fontWeight: fontWeight),
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: RouteGenerator.generateRoute,
    ),
  );

  return;
}
