import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/constants/app_constants.dart';

class CText extends StatelessWidget {
  final String text;
  final TextAlign alignText;
  final int? maxLines;
  final Color? color;
  final double fontSize;
  final bool softWrap;
  final FontWeight fontWeight;
  final double? minFontSize;
  final bool ellipsisText;
  final double? lineHeight;
  final String? fontFamily;
  final TextDecoration? textDecoration;
  final TextOverflow? overflow;
  final Color? decorationColor;

  final TextStyle? style;
  
  const CText({
    super.key,
    required this.text,
    this.color,
    this.style,
    required this.fontSize,
    this.alignText = TextAlign.start,
    this.maxLines,
    this.fontWeight = FontWeight.normal,
    this.ellipsisText = true,
    this.softWrap = true,
    this.minFontSize,
    this.textDecoration,
    this.fontFamily,
    this.lineHeight,
    this.overflow,
    this.decorationColor,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: alignText,
      maxLines: maxLines,
      overflow: overflow ?? (ellipsisText ? TextOverflow.ellipsis : null),
      softWrap: softWrap,
      style: style ?? TextStyle(
        color: color ?? AppColors.headingcolor,
        fontSize: fontSize.sp,
        fontWeight: fontWeight,
        height: lineHeight,
        decoration: textDecoration,
        decorationColor: decorationColor,
        fontFamily: fontFamily ?? "Poppins",
      ),
    );
  }
}
