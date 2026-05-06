import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/sheets_constants.dart';
import '../../../core/errors/exceptions.dart';

class GoogleAuthRemoteDataSource {
  static bool _initialized = false;

  final _signIn = GoogleSignIn(
    scopes: [
      'email',
      'profile',
      SheetsConstants.scopeSpreadsheets,
      SheetsConstants.scopeDriveFile,
    ],
  );

  GoogleSignIn get googleSignIn => _signIn;

  Future<void> initialize() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize();
    _initialized = true;
  }

  Future<GoogleSignInAccount> signIn() async {
    try {
      await initialize();
      final account = await _signIn.signIn();
      if (account == null) throw const AuthException('Sign in cancelled');
      return account;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Google sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await _signIn.signOut();
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      await initialize();
      return await _signIn.signInSilently();
    } catch (_) {
      return null;
    }
  }

  GoogleSignInAccount? get currentUser => _signIn.currentUser;
}
