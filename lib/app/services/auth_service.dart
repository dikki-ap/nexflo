import 'package:get/get.dart';

import '../data/database/app_database.dart';
import '../data/datasources/local/user_local_ds.dart';
import '../data/datasources/remote/google_auth_remote_ds.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/entities/user_entity.dart';
import '../domain/usecases/auth/get_current_user_usecase.dart';
import '../domain/usecases/usecase.dart';

class AuthService extends GetxService {
  final _currentUser = Rxn<UserEntity>();
  UserEntity? get currentUser => _currentUser.value;
  bool get isLoggedIn => _currentUser.value != null;

  late final GetCurrentUserUseCase _getCurrentUser;

  Future<AuthService> init() async {
    final remoteDs = GoogleAuthRemoteDataSource();
    final db = Get.find<AppDatabase>();
    final localDs = UserLocalDataSource(db);
    final repo = AuthRepositoryImpl(remoteDs, localDs);
    _getCurrentUser = GetCurrentUserUseCase(repo);

    await _checkCurrentUser();
    return this;
  }

  Future<void> _checkCurrentUser() async {
    final result = await _getCurrentUser(NoParams());
    result.fold(
      (_) => _currentUser.value = null,
      (user) => _currentUser.value = user as UserEntity?,
    );
  }

  void setUser(UserEntity user) => _currentUser.value = user;

  void clearUser() => _currentUser.value = null;

  Future<void> refresh() => _checkCurrentUser();
}
