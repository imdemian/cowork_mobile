import 'package:flutter/material.dart';

// Extensiones útiles para BuildContext
extension ContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => Theme.of(this).textTheme;
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => mediaQuery.size.width;
  double get screenHeight => mediaQuery.size.height;
}

// Extensiones para String
extension StringExtensions on String {
  String get capitalize =>
      isEmpty ? '' : '${this[0].toUpperCase()}${substring(1)}';

  String get trimAll => replaceAll(RegExp(r'\s+'), ' ');
}

// Extensiones para DateTime
extension DateTimeExtensions on DateTime {
  String toReadableString() {
    return '$day/$month/$year';
  }
}
