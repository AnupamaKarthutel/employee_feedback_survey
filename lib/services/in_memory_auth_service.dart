import 'dart:async';

import '../models/app_user.dart';
import 'auth_service.dart';

class InMemoryAuthService implements AuthService {
  final _users = <String, AppUser>{};
  final _passwords = <String, String>{};
  AppUser? _currentUser;
  late final StreamController<AppUser?> _controller;

  InMemoryAuthService() {
    _controller = StreamController<AppUser?>.broadcast(
      onListen: () => _controller.add(_currentUser),
    );
  }

  @override
  Stream<AppUser?> get authStateChanges => _controller.stream;

  @override
  Future<AppUser?> getCurrentUser() async => _currentUser;

  @override
  Future<AppUser> signIn(String email, String password) async {
    final normalized = email.trim().toLowerCase();
    if (!_users.containsKey(normalized)) {
      throw Exception('No account found for that email.');
    }
    if (_passwords[normalized] != password) {
      throw Exception('Incorrect password.');
    }
    _currentUser = _users[normalized];
    _controller.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AppUser> signUp(String email, String password, Role role) async {
    final normalized = email.trim().toLowerCase();
    if (_users.containsKey(normalized)) {
      throw Exception('An account already exists for that email.');
    }
    final user = AppUser(
      id: 'u_${_users.length + 1}',
      email: normalized,
      role: role,
    );
    _users[normalized] = user;
    _passwords[normalized] = password;
    _currentUser = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _controller.add(null);
  }
}
