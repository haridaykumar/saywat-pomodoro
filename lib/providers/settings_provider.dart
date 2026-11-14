import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  int workMinutes = 25;
  int restMinutes = 5;
  int longRestMinutes = 15;
  int cyclesBeforeLongRest = 4;
  bool isStrictMode = false;
  bool isDarkMode = false;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    workMinutes = prefs.getInt('workMinutes') ?? 25;
    restMinutes = prefs.getInt('restMinutes') ?? 5;
    longRestMinutes = prefs.getInt('longRestMinutes') ?? 15;
    cyclesBeforeLongRest = prefs.getInt('cyclesBeforeLongRest') ?? 4;
    isStrictMode = prefs.getBool('isStrictMode') ?? false;
    isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> updateWorkMinutes(int value) async {
    workMinutes = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('workMinutes', value);
    notifyListeners();
  }

  Future<void> updateRestMinutes(int value) async {
    restMinutes = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('restMinutes', value);
    notifyListeners();
  }

  Future<void> toggleStrictMode(bool value) async {
    isStrictMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isStrictMode', value);
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    notifyListeners();
  }
}
