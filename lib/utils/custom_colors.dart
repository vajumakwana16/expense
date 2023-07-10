import 'package:flutter/material.dart';

class Custom_Colors {
  static const _customCyan = 0xAA00FFFF;

  static const MaterialColor customCyan = MaterialColor(
    _customCyan,
    <int, Color>{
      50: Color(0xAA00FFFF),
      100: Color(0xAA00FFFF),
      200: Color(0xAA00FFFF),
      300: Color(0xAA00FFFF),
      400: Color(0xAA00FFFF),
      500: Color(_customCyan),
      600: Color(0xAA00FFFF),
      700: Color(0xAA00FFFF),
      800: Color(0xAA00FFFF),
      900: Color(0xAA00FFFF),
    },
  );

  static const _customBrown = 0xff273238;

  static const MaterialColor customBrown = MaterialColor(
    _customBrown,
    <int, Color>{
      50: Color(0xFFe0e0e0),
      100: Color(0xFFb3b3b3),
      200: Color(0xFF808080),
      300: Color(0xFF4d4d4d),
      400: Color(0xff273238),
      500: Color(_customBrown),
      600: Color(0xff273238),
      700: Color(0xff273238),
      800: Color(0xff273238),
      900: Color(0xff273238),
    },
  );

  static const _customRed = 0xffE60012;

  static const MaterialColor customRed = MaterialColor(
    _customRed,
    <int, Color>{
      50: Color(0xFFE60012),
      100: Color(0xFFE60012),
      200: Color(0xFFE60012),
      300: Color(0xFFE60012),
      400: Color(0xffE60012),
      500: Color(_customBrown),
      600: Color(0xffE60012),
      700: Color(0xffE60012),
      800: Color(0xffE60012),
      900: Color(0xffE60012),
    },
  );
}
