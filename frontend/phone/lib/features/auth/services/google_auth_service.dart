import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  GoogleAuthService() {
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    await _googleSignIn.initialize(
      serverClientId: "130382157522-fh2klmgqgsem919l0bhp35u7d5f8eqlk.apps.googleusercontent.com",
    );

    _isGoogleSignInInitialized = true;
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _initializeGoogleSignIn();
    }
  }

  Future<String?> getGoogleIdToken() async {
    await _ensureGoogleSignInInitialized();

    try {
      final GoogleSignInAccount user = await _googleSignIn.authenticate(
        scopeHint: ['profile', 'email'],
      );

      final String? idToken = user.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw Exception('Failed to retrieve Google ID token.');
      }

      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null; // User closed the picker
      }
      rethrow;
    }
  }
}
