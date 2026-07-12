import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Stream<AppUser?> get authStateChanges =>
      _auth.authStateChanges().asyncMap(_toAppUser);

  @override
  Future<AppUser?> getCurrentUser() => _toAppUser(_auth.currentUser);

  @override
  Future<AppUser> signIn(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = await _toAppUser(credential.user);
    if (user == null) throw Exception('Unable to retrieve user after sign-in.');
    return user;
  }

  @override
  Future<AppUser> signUp(String email, String password, Role role) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) throw Exception('Account creation failed.');

    await _firestore.collection('users').doc(user.uid).set({
      'email': email,
      'role': role.name,
    });

    return AppUser(id: user.uid, email: email, role: role);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  Future<AppUser?> _toAppUser(User? user) async {
    if (user == null) return null;
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      final roleName = data?['role'] as String? ?? 'employee';
      final role = Role.values.byName(roleName);
      return AppUser(id: user.uid, email: user.email ?? '', role: role);
    } catch (_) {
      return AppUser(id: user.uid, email: user.email ?? '', role: Role.employee);
    }
  }
}
