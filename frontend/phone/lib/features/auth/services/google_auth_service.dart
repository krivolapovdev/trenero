import 'package:google_sign_in/google_sign_in.dart';
import 'package:phone/core/constants/app_constants.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  new() {
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    await _googleSignIn.initialize(
      serverClientId: AppConstants.googleOAuth2ServerClientId,
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
        return null;
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _ensureGoogleSignInInitialized();
    await _googleSignIn.signOut();
  }
}

final GoogleAuthService googleAuthService = GoogleAuthService();
