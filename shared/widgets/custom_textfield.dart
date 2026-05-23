import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import '../../core/constants/app_constants.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final TextInputType keyboardType;
  final int maxLines;
  final bool isPassword;
  final bool enable;
  final Widget? suffixIcon;
  final Widget? preffixIcon;
  final EdgeInsets? padding;
  final bool hasSuffix;
  final bool hasPreffix;
  final bool hasTopIcon;
  final int? maxLength;
  final VoidCallback? onTap;
  final Color suffixIconColor;
  final double suffixIconSize;
  final Color preffixIconColor;
  final double preffixIconSize;
  final VoidCallback? suffixIconFunction;
  final Color themeColor;
  final Color backcolor;
  final String? Function(String?)? function;
  final String? Function(String?)? onChange;
  final String? Function(String?)? onComplete;
  final String? Function(String?)? onSaved;
  final String? Function()? onEditingComplete;
  final double? textFieldheight;
  final TextAlign? textAlign;
  final String? Function(String?)? validator;

  final RxBool? obscureText; // ✅ Same as second field
  final Color? textcolor;

  CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.enable = true,
    this.suffixIcon,
    this.suffixIconFunction,
    this.function,
    this.hasSuffix = false,
    this.hasPreffix = false,
    this.backcolor = Colors.transparent,
    this.themeColor = AppColors.primaryappcolor,
    this.suffixIconColor = AppColors.primarybackColor,
    this.suffixIconSize = 25,
    this.preffixIconColor = AppColors.searchIconColor,
    this.preffixIconSize = 30,
    this.onChange,
    this.onTap,
    this.onComplete,
    this.preffixIcon,
    this.onSaved,
    this.onEditingComplete,
    this.maxLines = 1,
    this.padding,
    this.hasTopIcon = false,
    this.maxLength,
    this.textFieldheight,
    this.textAlign,
    this.textcolor,
    this.obscureText,
    this.validator,
  });

  final RxBool defaultObscureText = true.obs; // ✅ default fallback

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: double.infinity,
      height: textFieldheight ?? 60,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Obx(() {
        final obscureValue =
            obscureText?.value ?? defaultObscureText.value;

        return TextFormField(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          enabled: enable,
          controller: controller,
          maxLines: isPassword ? 1 : maxLines,
          onTap: onTap,
          textAlign: textAlign ?? TextAlign.start,
          textInputAction: TextInputAction.next,
          cursorColor: themeColor,
          textAlignVertical: TextAlignVertical.center,
          maxLength: maxLength,
          obscureText: isPassword ? obscureValue : false,
          obscuringCharacter: "*",
          keyboardType: keyboardType,
          onFieldSubmitted: onComplete,
          onChanged: onChange,
          onSaved: onSaved,
          onEditingComplete: onEditingComplete,

          style: TextStyle(
            color: textcolor ?? AppColors.headingcolor,
            fontSize: 16.sp,
          ),

          validator: validator,

          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: AppColors.primarybackColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w400,
              fontSize: 16.sp,
              fontFamily: 'Poppins',
            ),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 10, horizontal: 13),
            fillColor: Colors.white,
            filled: true,

            prefixIcon: hasPreffix ? preffixIcon : null,

            suffixIcon: hasSuffix
                ? (isPassword && suffixIcon == null
                    ? IconButton(
                        icon: Icon(
                          obscureValue
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          if (obscureText != null) {
                            obscureText!.value =
                                !obscureText!.value;
                          } else {
                            defaultObscureText.value =
                                !defaultObscureText.value;
                          }
                        },
                      )
                    : suffixIcon)
                : null,

            isDense: true,

            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color:
                    AppColors.kformborderColor.withValues(alpha: 0.5),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),

            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: AppColors.kformborderColor,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10.r),
            ),

            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(10.r),
            ),

            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red),
              borderRadius: BorderRadius.circular(10.r),
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(
                color:
                    AppColors.kformborderColor.withValues(alpha: 0.5),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class CustomSecondTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final Widget? preffixIcon;
  final Widget? suffixIcon;
  final bool isPassword;
  final bool hasPreffix;
  final bool hasSuffix;
  final RxBool? obscureText;
  final TextInputType? keyboardType;
  final Color? textcolor;
  final Color backcolor;
  final int maxLines;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final bool readOnly;
  final VoidCallback? onTap;

  CustomSecondTextField({
    super.key,
    this.controller,
    required this.hintText,
    this.preffixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.hasPreffix = false,
    this.hasSuffix = false,
    this.obscureText,
    this.keyboardType,
    this.textcolor,
    this.backcolor = Colors.transparent,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.readOnly = false,
    this.onTap,
  });

  final RxBool defaultObscureText = true.obs;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final obscureValue =
          obscureText?.value ?? defaultObscureText.value;

      return TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: isPassword ? 1 : maxLines,
        readOnly: readOnly,
        onTap: onTap,
        onChanged: onChanged,
        obscureText: isPassword ? obscureValue : false,

        style: TextStyle(
          color: textcolor ?? AppColors.textPrimary,
          fontSize: 15.sp,
        ),

        decoration: InputDecoration(
          hintText: hintText,

          hintStyle: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14.sp,
          ),

          filled: true,
          fillColor: backcolor == Colors.transparent
              ? AppColors.grey100
              : backcolor,

          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 18.h,
          ),

          prefixIcon: hasPreffix
              ? Padding(
                  padding:
                      EdgeInsets.only(left: 12.w, right: 8.w),
                  child: preffixIcon,
                )
              : null,

          suffixIcon: hasSuffix
              ? (isPassword && suffixIcon == null
                  ? IconButton(
                      icon: Icon(
                        obscureValue
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.grey500,
                      ),
                      onPressed: () {
                        if (obscureText != null) {
                          obscureText!.value =
                              !obscureText!.value;
                        } else {
                          defaultObscureText.value =
                              !defaultObscureText.value;
                        }
                      },
                    )
                  : suffixIcon)
              : null,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide.none,
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide.none,
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide.none,
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide.none,
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20.r),
            borderSide: BorderSide.none,
          ),
        ),
      );
    });
  }
}




class CustomSearchTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final TextInputType keyboardType;
  final int maxLines;
  final bool isPassword;
  final bool enable;
  final Widget? suffixIcon;
  final Widget? preffixIcon;
  final EdgeInsets? padding;
  final bool hasSuffix;
  final bool hasPreffix;
  final bool hasTopIcon;
  final int? maxLength;
  final VoidCallback? onTap;
  final Color suffixIconColor;
  final double suffixIconSize;
  final Color preffixIconColor;
  final double preffixIconSize;
  final VoidCallback? suffixIconFunction;
  final Color themeColor;
  final Color backcolor;
  final String? Function(String?)? function;
  final String? Function(String?)? onChange;
  final String? Function(String?)? onComplete;
  final String? Function(String?)? onSaved;
  final String? Function()? onEditingComplete;
  final double? textFieldheight;
  final TextAlign? textAlign;
  final double width;
  final double height;
  final ValueNotifier<bool> defaultObscureText = ValueNotifier(true);
  final ValueNotifier<bool>? obscureText;
  final Color? textcolor;

  CustomSearchTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    this.enable = true,
    this.suffixIcon,
    this.suffixIconFunction,
    this.function,
    this.hasSuffix = false,
    this.hasPreffix = true,
    this.backcolor = Colors.transparent,
    this.themeColor = AppColors.primaryappcolor,
    this.suffixIconColor = AppColors.primarybackColor,
    this.suffixIconSize = 25,
    this.preffixIconColor = AppColors.searchIconColor,
    this.preffixIconSize = 30,
    this.onChange,
    this.onTap,
    this.onComplete,
    this.preffixIcon,
    this.onSaved,
    this.onEditingComplete,
    this.maxLines = 1,
    this.padding,
    this.hasTopIcon = false,
    this.maxLength,
    this.textFieldheight,
    this.textAlign,
    this.width = 388,
    this.height = 60,
    this.textcolor,
    this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: double.infinity,
      height: textFieldheight ?? 60,

      decoration: BoxDecoration(
        color: const Color(0xffECECEC),
        borderRadius: BorderRadius.circular(25.r),
      ),
      
      padding: const EdgeInsets.all(16),
      child: ValueListenableBuilder<bool>(
        valueListenable: obscureText ?? defaultObscureText,
        builder: (context, obscureValue, child) {
          return TextFormField(
            enabled: enable,
            controller: controller,
            maxLines: maxLines,
            onTap: onTap,
            textAlign: textAlign ?? TextAlign.start,
            textInputAction: TextInputAction.next,
            cursorColor: themeColor,
            maxLength: maxLength,
            obscureText: isPassword ? obscureValue : false,
            obscuringCharacter: "*",
            keyboardType: keyboardType,
            onFieldSubmitted: onComplete,
            onChanged: onChange,
            onSaved: onSaved,
            onEditingComplete: onEditingComplete,
            inputFormatters: [
              if (keyboardType == TextInputType.phone)
                FilteringTextInputFormatter.allow(RegExp(r'[0-9]'))
              else
                FilteringTextInputFormatter.allow(
                  RegExp(
                    r'[a-zA-ZÀ-ÿ0-9 @/:?\-_.]',
                  ), // Allows accented letters like é
                ),

              if (keyboardType == TextInputType.phone)
                FilteringTextInputFormatter.deny(
                  RegExp(r'[\.,\-_]'),
                ) // Deny special characters in phone numbers
              else
                FilteringTextInputFormatter.deny(RegExp(r'[#]')), // Restrict #
            ],
            style: TextStyle(color: AppColors.primaryappcolor, fontSize: 16.sp),
            validator: function,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(
                color: AppColors.primarybackColor.withValues(alpha: 0.8),
                fontWeight: FontWeight.w400,
                fontSize: 16.sp,
                fontFamily: 'Poppins',
              ),
              contentPadding:
                  padding ?? const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              suffixIcon: hasSuffix
                  ? InkWell(
                      child: isPassword
                          ? Icon(obscureValue
                                ? Icons.visibility
                                : Icons.visibility_off)
                          : suffixIcon,
                    )
                  : const SizedBox(),
              prefixIcon: hasPreffix ? preffixIcon : null,
              isDense: true,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.kformborderColor.withValues(alpha: 0.5), // Light border
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: AppColors.kformborderColor,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: const BorderSide(
                  color: Colors.red,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(10.r),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: BorderSide(
                  color: AppColors.kformborderColor.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
            ),
          );
        }
      ),
    );
  }
}
