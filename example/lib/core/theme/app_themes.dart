import 'package:flutter/material.dart';

class AppThemes {
  static ThemeData light() => ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Colors.blue,
      secondary: Colors.blueAccent,
    ),
    useMaterial3: true,
  );

  static ThemeData dark() => ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: Colors.blue.shade300,
      secondary: Colors.blueAccent.shade200,
    ),
    useMaterial3: true,
  );

  static ThemeData custom() => ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Colors.purple,
      secondary: Colors.deepPurple,
      surface: Colors.purple.shade50,
    ),
    useMaterial3: true,
  );
}
