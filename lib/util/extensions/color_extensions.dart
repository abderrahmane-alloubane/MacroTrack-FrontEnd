import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  Color darken([int amount = 40]) {
    return Color.fromRGBO(
      ((r * 255) - amount).round().clamp(0, 255),
      ((g * 255) - amount).round().clamp(0, 255),
      ((b * 255) - amount).round().clamp(0, 255),
      1,
    );
  }
}
