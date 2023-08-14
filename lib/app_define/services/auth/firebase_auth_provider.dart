import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth,FirebaseException,FirebaseAuthException;
import 'package:firebase_core/firebase_core.dart';
import 'package:note/app_define/services/auth/auth_exception.dart';
import 'package:note/app_define/services/auth/auth_provider.dart';
import 'package:note/app_define/services/auth/auth_user.dart';
import 'package:note/firebase_options.dart';

class FirebaseAuthProvider implements AuthProvider {

@override
  Future<void> initialize() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }

  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    try {
      await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      final user = currentUser;
      if (user != null) {
        return user;
      }
      throw UserNotLoginedAuthException();
    } on FirebaseAuthException catch (exception) {
      if (exception.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (exception.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (exception.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } on FirebaseException catch (_) {
      throw GenericAuthException();
    } on Exception catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return AuthUser.fromFirebase(user);
    }
    return null;
  }

  @override
  Future<AuthUser> login(
      {required String email, required String password}) async {
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      if (user != null) {
        return AuthUser.fromFirebase(user);
      }
      throw UserNotLoginedAuthException();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw WrongPasswordAuthException();
      } else if (e.code == 'user-not-found') {
        throw UserNotFoundAuthException();
      } else {
        throw GenericAuthException();
      }
    } on FirebaseException catch (_) {
      throw GenericAuthException();
    } on Exception catch (_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logout() {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        return FirebaseAuth.instance.signOut();
      }
      else {
        throw UserNotLoginedAuthException();
      }
    }
    on FirebaseException catch(_) {
      throw GenericAuthException();
    }
    on Exception catch(_) {
      throw GenericAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw UserNotFoundAuthException();
      }
      if (user.emailVerified == false){
        await user.sendEmailVerification();
      }
      else {
        throw UserNotLoginedAuthException();
      }
    }
    on FirebaseException catch (_){
      throw GenericAuthException();
    }
  }
}
