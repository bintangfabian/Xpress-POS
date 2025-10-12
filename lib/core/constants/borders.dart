import 'package:flutter/material.dart';

class AppBorders {
  /// Container border radius
  static const double containerRadius = 24.0;
  
  /// Button border radius
  static const double buttonRadius = 6.0;
  
  /// Input field border radius
  static const double inputRadius = 8.0;
  
  /// Card border radius
  static const double cardRadius = 16.0;
  
  /// Small component border radius
  static const double smallRadius = 6.0;
  
  /// Get BorderRadius for containers
  static BorderRadius get containerBorderRadius => BorderRadius.circular(containerRadius);
  
  /// Get BorderRadius for buttons
  static BorderRadius get buttonBorderRadius => BorderRadius.circular(buttonRadius);
  
  /// Get BorderRadius for input fields
  static BorderRadius get inputBorderRadius => BorderRadius.circular(inputRadius);
  
  /// Get BorderRadius for cards
  static BorderRadius get cardBorderRadius => BorderRadius.circular(cardRadius);
  
  /// Get BorderRadius for small components
  static BorderRadius get smallBorderRadius => BorderRadius.circular(smallRadius);
}