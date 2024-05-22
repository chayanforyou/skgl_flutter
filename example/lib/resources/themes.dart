import 'package:flutter/material.dart';

import 'colors.dart';

class Themes {
  Themes._();

  static ThemeData appTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      splashFactory: InkSplash.splashFactory,
      colorSchemeSeed: primaryColor,
      textTheme: Theme.of(context).textTheme.copyWith(
            bodyLarge: const TextStyle(fontSize: 14), // https://stackoverflow.com/a/75900012/5280371
          ),
      chipTheme: const ChipThemeData(
        showCheckmark: false,
        selectedColor: primaryColor,
        backgroundColor: whiteBackgroundColor,
        labelStyle: TextStyle(color: ChipLabelColor()),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: backgroundColor,
        surfaceTintColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.all(10),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: borderColor),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: errorBorderColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: errorBorderColor),
        ),
      ),
    );
  }
}

class ChipLabelColor extends Color implements MaterialStateColor {
  const ChipLabelColor() : super(_default);

  static const int _default = 0xFF000000;

  @override
  Color resolve(Set<MaterialState> states) {
    if (states.contains(MaterialState.selected)) {
      return Colors.white;
    }
    return Colors.black;
  }
}
