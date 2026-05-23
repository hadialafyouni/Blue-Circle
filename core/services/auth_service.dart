import 'dart:developer' as dev;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signUp(String email, String password) async {
    try {
      dev.log("SignUp Attempt: $email", name: "AUTH_SERVICE");
      
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      dev.log("SignUp Success: ${result.user?.uid}", name: "AUTH_SERVICE");

      return result;
    } on FirebaseAuthException catch (e) {
      dev.log("SignUp Firebase Error", error: e, name: "AUTH_SERVICE");
      rethrow;
    } catch (e) {
      dev.log("SignUp Unknown Error", error: e, name: "AUTH_SERVICE");
      rethrow;
    }
  }

  Future<UserCredential> signIn(String email, String password) async {
    try {
      dev.log("SignIn Attempt: $email", name: "AUTH_SERVICE");

      final result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      dev.log("SignIn Success: ${result.user?.uid}", name: "AUTH_SERVICE");

      return result;
    } on FirebaseAuthException catch (e) {
      dev.log("SignIn Firebase Error", error: e, name: "AUTH_SERVICE");
      rethrow;
    } catch (e) {
      dev.log("SignIn Unknown Error", error: e, name: "AUTH_SERVICE");
      rethrow;
    }
  }

  Future<void> signOut() async {
    dev.log("User Signing Out", name: "AUTH_SERVICE");
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    dev.log("Sending Reset Email: $email", name: "AUTH_SERVICE");
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> sendEmailVerification() async {
    dev.log("Sending Email Verification", name: "AUTH_SERVICE");
    await _auth.currentUser?.sendEmailVerification();
  }

  Future<void> deleteAccount() async {
    dev.log("Deleting Account", name: "AUTH_SERVICE");
    await _auth.currentUser?.delete();
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) codeSent,
    required void Function(FirebaseAuthException error) verificationFailed,
    void Function(PhoneAuthCredential credential)? verificationCompleted,
    void Function(String verificationId)? codeAutoRetrievalTimeout,
    int? forceResendingToken,
  }) async {
    dev.log("Phone verification started for: $phoneNumber", name: "AUTH_SERVICE");

    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: forceResendingToken,
      verificationCompleted: verificationCompleted ?? (_) {},
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout ?? (_) {},
    );
  }

  PhoneAuthCredential buildPhoneAuthCredential({
    required String verificationId,
    required String smsCode,
  }) {
    return PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
  }

  Future<UserCredential> signInWithPhoneCredential(AuthCredential credential) async {
    dev.log("Phone sign-in started", name: "AUTH_SERVICE");
    return _auth.signInWithCredential(credential);
  }

  Future<UserCredential> linkPhoneCredential(AuthCredential credential) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user found to link the phone number.',
      );
    }

    dev.log("Linking phone credential for user: ${user.uid}", name: "AUTH_SERVICE");
    return user.linkWithCredential(credential);
  }

  Future<void> attachPhoneCredential(AuthCredential credential) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'No signed-in user found to verify the phone number.',
      );
    }

    final hasPhoneProvider = user.providerData.any(
      (provider) => provider.providerId == PhoneAuthProvider.PROVIDER_ID,
    );

    dev.log(
      hasPhoneProvider
          ? "Updating phone credential for user: ${user.uid}"
          : "Attaching phone credential for user: ${user.uid}",
      name: "AUTH_SERVICE",
    );

    if (hasPhoneProvider) {
      await user.updatePhoneNumber(credential as PhoneAuthCredential);
    } else {
      await user.linkWithCredential(credential);
    }

    await user.reload();
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      dev.log("Google SignIn Attempt", name: "AUTH_SERVICE");
      
      final googleSignIn = GoogleSignIn();
      final googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        dev.log("Google SignIn Cancelled", name: "AUTH_SERVICE");
        return null;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _auth.signInWithCredential(credential);
      dev.log("Google SignIn Success: ${result.user?.uid}", name: "AUTH_SERVICE");
      
      return result;
    } catch (e) {
      dev.log("Google SignIn Error", error: e, name: "AUTH_SERVICE");
      rethrow;
    }
  }
}
