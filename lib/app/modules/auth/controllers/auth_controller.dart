import 'package:get/get.dart';
import '../../../config/routes/app_routes.dart';
import '../../../data/datasources/local/category_local_ds.dart';
import '../../../data/datasources/local/settings_local_ds.dart';
import '../../../data/datasources/local/user_local_ds.dart';
import '../../../data/datasources/remote/google_auth_remote_ds.dart';
import '../../../data/database/app_database.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/auth/sign_in_google_usecase.dart';
import '../../../domain/usecases/auth/sign_out_usecase.dart';
import '../../../domain/usecases/usecase.dart';
import '../../../services/auth_service.dart';

class AuthController extends GetxController {
  final _isLoading = false.obs;
  final _error = ''.obs;

  bool get isLoading => _isLoading.value;
  String get error => _error.value;

  late final SignInGoogleUseCase _signIn;
  late final SignOutUseCase _signOut;

  @override
  void onInit() {
    super.onInit();
    final db = Get.find<AppDatabase>();
    final repo = AuthRepositoryImpl(
      GoogleAuthRemoteDataSource(),
      UserLocalDataSource(db),
    );
    _signIn = SignInGoogleUseCase(repo);
    _signOut = SignOutUseCase(repo);
  }

  Future<void> signInWithGoogle() async {
    _isLoading.value = true;
    _error.value = '';

    final result = await _signIn(NoParams());

    result.fold(
      (failure) => _error.value = (failure).message,
      (user) async {
        Get.find<AuthService>().setUser(user as UserEntity);

        final db = Get.find<AppDatabase>();
        final settingsDs = SettingsLocalDataSource(db);
        final existing = await settingsDs.getByUserId(user.id);

        if (existing == null) {
          Get.offAllNamed(AppRoutes.onboarding);
        } else {
          Get.offAllNamed(AppRoutes.main);
        }
      },
    );

    _isLoading.value = false;
  }

  Future<void> signOut() async {
    await _signOut(NoParams());
    Get.find<AuthService>().clearUser();
    Get.offAllNamed(AppRoutes.login);
  }
}
