import '../models/app_user.dart';

abstract class AuthService {
  Stream<AppUser?> get authStateChanges;

  Future<AppUser?> getCurrentUser();

  Future<AppUser> signIn(String email, String password);

  Future<AppUser> signUp(String email, String password, Role role);

  Future<void> signOut();
}
