import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff4e9df4),
      surfaceTint: Color(0xff005bbe),
      onPrimary: Color(0xffffffff),
      secondary: Color(0xff4e9df4),
      onSecondary: Color(0xffffffff),
      error: Color(0xffec3332),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffd83831),
      onErrorContainer: Color(0xfffffbff),
      surface: Color(0xffF6F5FA),
      onSurface: Color(0xff1c1b1c),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff0059b9),
      surfaceTint: Color(0xff005bbe),
      onPrimary: Color(0xffffffff),
      secondary: Color(0xff5b5e65),
      onSecondary: Color(0xffffffff),
      error: Color(0xffb41c1b),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffd83831),
      onErrorContainer: Color(0xfffffbff),
      surface: Color(0xfffdf8f8),
      onSurface: Color(0xff1c1b1c),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }


  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: colorScheme.surface,
  );


  List<ExtendedColor> get extendedColors => [
  ];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
