import 'package:google_sign_in/google_sign_in.dart';
import '../../../core/constants/sheets_constants.dart';
import '../../../core/errors/exceptions.dart';

class GoogleAuthRemoteDataSource {
  static bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(
      scopes: [
        'email',
        'profile',
        SheetsConstants.scopeSpreadsheets,
        SheetsConstants.scopeDriveFile,
      ],
    );
    _initialized = true;
  }

  Future<GoogleSignInAccount> signIn() async {
    try {
      await initialize();
      final account = await GoogleSignIn.instance.signIn();
      if (account == null) {
        throw const AuthException('Sign in cancelled by user');
      }
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
    } catch (e) {
      throw AuthException('Sign out failed: $e');
    }
  }

  Future<GoogleSignInAccount?> signInSilently() async {
    try {
      await initialize();
      return await GoogleSignIn.instance.signInSilently();
    } catch (_) {
      return null;
    }
  }

  GoogleSignInAccount? get currentAccount =>
      GoogleSignIn.instance.currentUser;
}
