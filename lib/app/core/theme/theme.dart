import 'package:flutter/material.dart';

class TasklyTheme {
  const TasklyTheme._();

  static ThemeData get lightTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 143, 192, 131),
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    fontFamily: 'Monospace',
  );

  static ThemeData get darkTheme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6750A4),
      brightness: Brightness.dark,
    ),
    useMaterial3: true,
    fontFamily: 'Monospace',
  );
}
