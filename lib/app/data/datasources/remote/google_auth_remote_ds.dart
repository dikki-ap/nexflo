import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/sheets_constants.dart';
import '../../../core/errors/exceptions.dart';

class GoogleAuthRemoteDataSource {
  static bool _initialized = false;
  static GoogleSignInAccount? _currentAccount;

  Future<void> initialize() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(
      scopes: [
        SheetsConstants.scopeSpreadsheets,
        SheetsConstants.scopeDriveFile,
      ],
    );
    _initialized = true;
  }

  Future<GoogleSignInAccount> signIn() async {
    try {
      await initialize();
      final account = await GoogleSignIn.instance.authenticate();
      _currentAccount = account;
      return account;
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Google sign in failed: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
      _currentAccount = null;
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      await initialize();
      return _currentAccount;
    } catch (_) {
      return null;
    }
  }

  static GoogleSignInAccount? get currentUser => _currentAccount;
}
