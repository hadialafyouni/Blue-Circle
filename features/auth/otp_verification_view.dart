import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/widgets/c_text.dart';
import '../../shared/widgets/custom_buttons.dart';
import '../../shared/widgets/custom_textfield.dart';
import 'auth_controller.dart';
import 'otp_flow_args.dart';

class OtpVerificationView extends StatefulWidget {
  const OtpVerificationView({super.key});

  @override
  State<OtpVerificationView> createState() => _OtpVerificationViewState();
}

class _OtpVerificationViewState extends State<OtpVerificationView> {
  late OtpFlowArgs _flowArgs;
  final AuthController _controller = Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    _flowArgs = Get.arguments as OtpFlowArgs;
    _controller.otpController.clear();
  }

  @override
  void dispose() {
    _controller.otpController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _flowArgs.isSignUp
        ? 'Verify Phone Number'
        : _flowArgs.isProfilePhoneVerification
            ? 'Verify Your Phone'
            : 'Login with OTP';
    final subtitle = _flowArgs.isSignUp
        ? 'Enter the 6-digit code sent to ${_flowArgs.phoneNumber} to finish creating your parent account.'
        : _flowArgs.isProfilePhoneVerification
            ? 'Enter the 6-digit code sent to ${_flowArgs.phoneNumber} to mark this phone number as verified for your profile.'
            : 'Enter the 6-digit code sent to ${_flowArgs.phoneNumber} to continue.';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
              Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.secondary,
                    width: 4.w,
                  ),
                ),
                child: Icon(
                  Icons.sms_outlined,
                  size: 38.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 32.h),
              CText(
                text: title,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              SizedBox(height: 12.h),
              CText(
                text: subtitle,
                fontSize: 14,
                color: AppColors.textSecondary,
                alignText: TextAlign.center,
              ),
              SizedBox(height: 36.h),
              Align(
                alignment: Alignment.centerLeft,
                child: CText(
                  text: "OTP Code",
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              CustomTextField(
                hintText: "Enter 6-digit OTP",
                preffixIcon: const Icon(Icons.password_outlined, color: AppColors.grey500),
                controller: _controller.otpController,
                keyboardType: TextInputType.number,
                hasPreffix: true,
                maxLength: 6,
                textcolor: AppColors.textPrimary,
              ),
              SizedBox(height: 24.h),
              Obx(
                () => PrimaryIconButton(
                  text: _controller.isOtpVerifying.value ? "Verifying..." : "Verify OTP",
                  icon: Icons.verified_outlined,
                  iconEnable: !_controller.isOtpVerifying.value,
                  width: double.infinity,
                  isLoading: _controller.isOtpVerifying.value,
                  onTap: () => _controller.verifyOtp(_flowArgs),
                ),
              ),
              SizedBox(height: 18.h),
              Obx(
                () => TextButton(
                  onPressed: _controller.isOtpSending.value
                      ? null
                      : () async {
                          final updatedArgs = await _controller.resendOtp(_flowArgs);
                          if (updatedArgs != null && mounted) {
                            setState(() {
                              _flowArgs = updatedArgs;
                            });
                          }
                        },
                  child: CText(
                    text: _controller.isOtpSending.value ? "Resending code..." : "Resend OTP",
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Get.back(),
                child: CText(
                  text: "Back",
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
