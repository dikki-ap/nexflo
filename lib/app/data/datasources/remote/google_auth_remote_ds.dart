import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/sheets_constants.dart';
import '../../../core/errors/exceptions.dart';

class GoogleAuthRemoteDataSource {
  static bool _initialized = false;
  static GoogleSignInAccount? _currentAccount;

  static const List<String> scopes = <String>[
    SheetsConstants.scopeSpreadsheets,
    SheetsConstants.scopeDriveFile,
  ];

  Future<void> initialize() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize();
    GoogleSignIn.instance.authenticationEvents.listen((event) {
      switch (event) {
        case GoogleSignInAuthenticationEventSignIn():
          _currentAccount = event.user;
        case GoogleSignInAuthenticationEventSignOut():
          _currentAccount = null;
      }
    });
    _initialized = true;
  }

  Future<GoogleSignInAccount> signIn() async {
    try {
      await initialize();
      await GoogleSignIn.instance.authenticate();
      // Allow stream event to propagate before reading _currentAccount
      await Future<void>.delayed(Duration.zero);
      final account = _currentAccount;
      if (account == null) throw const AuthException('Sign in failed');
      await account.authorizationClient.authorizeScopes(scopes);
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
      await initialize().timeout(const Duration(seconds: 10));
      final result = GoogleSignIn.instance.attemptLightweightAuthentication();
      if (result != null) {
        await result.timeout(const Duration(seconds: 10));
        await Future<void>.delayed(Duration.zero);
      }
      return _currentAccount;
    } catch (_) {
      return null;
    }
  }

  static GoogleSignInAccount? get currentUser => _currentAccount;
}
