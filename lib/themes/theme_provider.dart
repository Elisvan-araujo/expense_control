import 'package:controle_despesas/themes/dark_mode.dart';
import 'package:controle_despesas/themes/light_mode.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _currentTheme;

  ThemeProvider(this._currentTheme);

  ThemeData get currentTheme => _currentTheme;

  void toggleTheme() {
    if (_currentTheme == lightMode) {
      _currentTheme = darkMode;
    } else {
      _currentTheme = lightMode;
    }
    notifyListeners();
  }
}
