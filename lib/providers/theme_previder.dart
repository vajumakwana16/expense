import 'package:flutter/material.dart';

import '../utils/webservice.dart';

enum Themesname { cyan, purple, red, green }

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = (Webservice.pref!.getBool('darkmode') != true)
      ? ThemeMode.light
      : ThemeMode.dark;
  bool get isDarkMode => themeMode == ThemeMode.dark;
  Themesname ctheme = getThemefomePref();
  Themesname get currenttheme => ctheme;

  static Themesname getThemefomePref() {
    final String themeFormPref = Webservice.pref!.getString('theme').toString();
    switch (themeFormPref) {
      case 'Themesname.cyan':
        return Themesname.cyan;
      case 'Themesname.purple':
        return Themesname.purple;
      case 'Themesname.red':
        return Themesname.red;
      case 'Themesname.green':
        return Themesname.green;
      default:
        return Themesname.cyan;
    }
  }

  void toggleTheme(bool isOn) {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void changeTheme(Themesname color) {
    switch (color) {
      case Themesname.purple:
        ctheme = Themesname.purple;
        notifyListeners();
        break;
      case Themesname.red:
        ctheme = Themesname.red;
        notifyListeners();
        break;
      case Themesname.green:
        ctheme = Themesname.green;
        notifyListeners();
        break;
      default:
        ctheme = Themesname.cyan;
        notifyListeners();
        break;
    }
  }
}

class MyTheme {
  //all themes
  static ThemeData dynamicTheme(
      BuildContext context, Themesname theme, isDarkMode) {
    switch (theme) {
      case Themesname.purple:
        return purpleTheme(context, isDarkMode);
      case Themesname.red:
        return redTheme(context, isDarkMode);
      case Themesname.green:
        return greenTheme(context, isDarkMode);
      case Themesname.cyan:
        if (isDarkMode) {
          return darkTheme(context);
        }
        return lightTheme(context);
      default:
        if (isDarkMode) {
          return darkTheme(context);
        }
        return lightTheme(context);
    }
  }

  //light
  static ThemeData lightTheme(BuildContext context) => ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primarySwatch: Colors.cyan,
        fontFamily: 'Quicksand',
        textTheme: const TextTheme(
            bodyLarge: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 14,
          fontWeight: FontWeight.bold,
        )),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        useMaterial3: false,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            enableFeedback: true,
            landscapeLayout: null,
            type: BottomNavigationBarType.shifting,
            backgroundColor: Colors.cyan,
            selectedItemColor: Colors.white),
      );

  //dark
  static ThemeData darkTheme(BuildContext context) => ThemeData(
      useMaterial3: false,
      brightness: Brightness.dark,
      //accentColor: Colors.cyan,
      fontFamily: 'Quicksand',
      textTheme: const TextTheme(
          bodyLarge: TextStyle(
        fontFamily: 'Quicksand',
        fontSize: 14,
        fontWeight: FontWeight.bold,
      )),
      appBarTheme: const AppBarTheme(
          backgroundColor: Colors.cyan,
          titleTextStyle: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          )),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          enableFeedback: true,
          backgroundColor: Colors.cyan,
          selectedItemColor: Colors.white),
      floatingActionButtonTheme:
          FloatingActionButtonThemeData(backgroundColor: Colors.cyan));

  //purple
  static ThemeData purpleTheme(BuildContext context, isDarkMode) => ThemeData(
      useMaterial3: false,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primarySwatch: Colors.purple,
      //accentColor: Colors.purple,
      fontFamily: 'Quicksand',
      textTheme: const TextTheme(
          bodyLarge: TextStyle(
        fontFamily: 'Quicksand',
        fontSize: 14,
        fontWeight: FontWeight.bold,
      )),
      appBarTheme: const AppBarTheme(
          backgroundColor: Colors.purple,
          titleTextStyle: TextStyle(
            fontFamily: 'Quicksand',
            fontSize: 14,
            fontWeight: FontWeight.bold,
          )),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          enableFeedback: true,
          landscapeLayout: null,
          type: BottomNavigationBarType.shifting,
          backgroundColor: Colors.purple,
          selectedItemColor: Colors.white),
      floatingActionButtonTheme:
          FloatingActionButtonThemeData(backgroundColor: Colors.purple));

  //red
  static ThemeData redTheme(BuildContext context, isDarkMode) => ThemeData(
      useMaterial3: false,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primarySwatch: Colors.red,
      //accentColor: Colors.red,
      fontFamily: 'Quicksand',
      textTheme: const TextTheme(
          bodyLarge: TextStyle(
        fontFamily: 'Quicksand',
        fontSize: 14,
        fontWeight: FontWeight.bold,
      )),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.red,
        titleTextStyle: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          enableFeedback: true,
          landscapeLayout: null,
          type: BottomNavigationBarType.shifting,
          backgroundColor: Colors.red,
          selectedItemColor: Colors.white),
      floatingActionButtonTheme:
          FloatingActionButtonThemeData(backgroundColor: Colors.red));

  //green
  static ThemeData greenTheme(BuildContext context, isDarkMode) => ThemeData(
      useMaterial3: false,
      brightness: isDarkMode ? Brightness.dark : Brightness.light,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primarySwatch: Colors.green,
      //accentColor: Colors.green,
      fontFamily: 'Quicksand',
      textTheme: const TextTheme(
          bodyLarge: TextStyle(
        fontFamily: 'Quicksand',
        fontSize: 14,
        fontWeight: FontWeight.bold,
      )),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.green,
        titleTextStyle: TextStyle(
          fontFamily: 'Quicksand',
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          enableFeedback: true,
          landscapeLayout: null,
          type: BottomNavigationBarType.shifting,
          backgroundColor: Colors.green,
          selectedItemColor: Colors.white),
      floatingActionButtonTheme:
          FloatingActionButtonThemeData(backgroundColor: Colors.green));
}
