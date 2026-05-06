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
      return await GoogleSignIn.instance.authenticate();
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
      return await GoogleSignIn.instance.authenticateIfRequired();
    } catch (_) {
      return null;
    }
  }

  Future<GoogleSignInAccount?> getCurrentAccount() =>
      GoogleSignIn.instance.currentUser.first;
}
