import 'dart:math';

import 'package:flutter/material.dart';

class Palette {
  final Color primary;
  final Color light;
  final Color dark;
  final Color textColor;

  Palette({
    required this.primary,
    required this.light,
    required this.dark,
    required this.textColor,
  });

  static final _rng = Random();

  /// List of MaterialColor swatches to choose from
  static final List<MaterialColor> _swatches = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.amber,
    Colors.orange,
  ];

  /// Create palette from random MaterialColor tonal family
  static Palette random() {
    final swatch = _swatches[_rng.nextInt(_swatches.length)];

    return Palette(
      primary: swatch.shade400,
      light: swatch.shade300,
      dark: swatch.shade600,
      textColor: swatch.shade400.computeLuminance() > 0.5
          ? Colors.black
          : Colors.white,
    );
  }
}
