import 'package:note/app_define/services/auth/auth_provider.dart';
import 'package:note/app_define/services/auth/auth_user.dart';
import 'package:note/app_define/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final FirebaseAuthProvider provider;
  const AuthService(this.provider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  Future<AuthUser> createUser({required String email, required String password}) {
    return provider.createUser(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<AuthUser> login({required String email, required String password}) {
    return provider.login(email: email, password: password);
  }

  @override
  Future<void> logout() {
    return provider.logout();
  }

  @override
  Future<void> sendEmailVerification() {
    return provider.sendEmailVerification();
  }
  
  @override
  Future<void> initialize() {
    return provider.initialize();
  }

}