enum OtpFlowType {
  signUp,
  signIn,
  profilePhoneVerification,
}

class OtpFlowArgs {
  const OtpFlowArgs({
    required this.flowType,
    required this.phoneNumber,
    required this.verificationId,
    this.resendToken,
    this.name,
    this.email,
    this.password,
  });

  final OtpFlowType flowType;
  final String phoneNumber;
  final String verificationId;
  final int? resendToken;
  final String? name;
  final String? email;
  final String? password;
  bool get isProfilePhoneVerification => flowType == OtpFlowType.profilePhoneVerification;

  bool get isSignUp => flowType == OtpFlowType.signUp;

  OtpFlowArgs copyWith({
    OtpFlowType? flowType,
    String? phoneNumber,
    String? verificationId,
    int? resendToken,
    String? name,
    String? email,
    String? password,
  }) {
    return OtpFlowArgs(
      flowType: flowType ?? this.flowType,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
    );
  }
}
