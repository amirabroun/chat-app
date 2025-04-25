import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<UserCredential?> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw handleAuthError(e);
    }
  }

  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw handleAuthError(e);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'آدرس ایمیل نامعتبر است.';
      case 'user-disabled':
        return 'این حساب کاربری غیرفعال شده است.';
      case 'user-not-found':
        return 'کاربری با این ایمیل پیدا نشد.';
      case 'wrong-password':
        return 'رمز عبور اشتباه است.';
      case 'email-already-in-use':
        return 'این ایمیل قبلاً استفاده شده است.';
      case 'weak-password':
        return 'رمز عبور باید حداقل ۶ کاراکتر باشد.';
      case 'operation-not-allowed':
        return 'ورود با ایمیل و رمز فعال نیست.';
      default:
        return 'خطای نامشخص: ${e.message}';
    }
  }
}
