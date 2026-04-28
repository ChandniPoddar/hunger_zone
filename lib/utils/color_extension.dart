import 'package:flutter/material.dart';
import 'package:hunger_zone/utils/theme.dart';

extension ColorExtension on BuildContext {
  Color get primaryColor => Theme.of(this).primaryColor;
  Color get bgColor => Theme.of(this).scaffoldBackgroundColor;
  Color get cardColor => Theme.of(this).colorScheme.surface;
  
  Color get textColor => Theme.of(this).brightness == Brightness.light 
      ? AppTheme.darkNavy
      : Colors.white;

  Color get subTextColor => Theme.of(this).brightness == Brightness.light 
      ? AppTheme.mediumGray
      : Colors.white70;

  Color get borderColor => Theme.of(this).brightness == Brightness.light 
      ? AppTheme.borderGray
      : Colors.white10;
}
