import 'dart:typed_data';

import 'snake_counter.dart';

class Session {
  int id = 0;
  Uint8List aesKey = Uint8List(0);
  DateTime lastAccessDT = DateTime.now();
  SnakeCounter snakeCounter = SnakeCounter(10, 1);
}
