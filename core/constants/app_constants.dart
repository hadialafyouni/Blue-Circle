import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF2B7FFF);
  static const Color darkBlue = Color(0xff1c398e);
  static const Color secondary = Color(0xFFC4D9FF);
  static const Color background = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color error = Color(0xFFF75555);
  static const Color success = Color(0xFF4ADE80);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color kgreen = Color(0xff10B981);
  static const Color kpurple = Color(0xff8b5cf6);

  
  // Aliases and New Colors for Custom Components
  static const Color kprimaryColor = primary;
  static const Color primarywhiteColor = Colors.white;
  static const Color kwhite = Colors.white;
  static const Color kformborderColor = grey300;
  static const Color kgrableColor4 = textSecondary;
  static const Color primarybackColor = textPrimary;
  static const Color headingcolor = textPrimary;
  static const Color kHeadingColor = textPrimary;
  static const Color kContainerColor = grey200;
  static const Color lightblue = secondary;
  static const Color greyColor = grey500;
  static const Color backgroundColor = background;
  static const Color primaryappcolor = primary;
  static const Color searchIconColor = grey500;
  static const Color textfieldcolor = grey100;
  static const Color kbluedark = darkBlue;
}

class AppStrings {
  static const String appName = "Blue Circle";
  static const String getStartedTitle = "Easy to Use";
  static const String getStartedSubtitle = "Simple language layout and voice aids designed for everyone to your family.";
  static const String signInTitle = "Sign In To Blue Circle";
  static const String signUpTitle = "Sign Up To Blue Circle";
}

class AppAiConfig {
  static const String openAiBaseUrl = 'https://api.openai.com/v1';
  static const String openAiApiKey = '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';
  static const String openAiModel = 'gpt-3.5-turbo';
}
