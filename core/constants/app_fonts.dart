import 'package:flutter/material.dart';


class AppFonts {
  ///// Font Family
  static const String fontFamily = 'Poppins';

  // Font Weights
  static const FontWeight light = FontWeight.w300;
  static const FontWeight regular = FontWeight.w400;
  static const FontWeight medium = FontWeight.w500;
  static const FontWeight bold = FontWeight.w700;

  // Font Sizes
  static const double small = 12.0;
  static const double mediumSize = 16.0;
  static const double large = 20.0;
  static const double extraLarge = 26.0;

  // Text Styles
  static TextStyle get smallRegular => const TextStyle(
        fontFamily: fontFamily,
        fontWeight: regular,
        fontSize: small,
      );

  static TextStyle get mediumBold => const TextStyle(
        fontFamily: fontFamily,
        fontWeight: bold,
        fontSize: mediumSize,
      );

  static TextStyle get largeMedium => const TextStyle(
        fontFamily: fontFamily,
        fontWeight: medium,
        fontSize: large,
      );
      static TextStyle get exterLarge => const TextStyle(
        fontFamily: fontFamily,
        fontWeight: bold,
        fontSize: extraLarge,
      );
}