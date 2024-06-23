import 'package:flutter/material.dart';
import 'package:music_app/themes/dark_mode.dart';
import 'package:music_app/themes/light_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier{
  late ThemeData _themeData=darkMode;

  ThemeProvider(bool isDark){
    _themeData=isDark?darkMode:lighMode;
  }

  ThemeData get themeData=> _themeData;

  bool get isDarkMode=> _themeData==darkMode;

  set themeData(ThemeData themeData){
    _themeData=themeData;

    notifyListeners();
  }

  Future<void> toggleTheme() async {
    SharedPreferences prefs=await SharedPreferences.getInstance();
    if(_themeData==lighMode){
      themeData=darkMode;
      prefs.setBool('isDarkMode', true);
    }
    else{
      themeData=lighMode;
      prefs.setBool('isDarkMode', false);
    }
  }
}