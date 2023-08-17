import 'package:note/app_define/services/auth/auth_exception.dart';
import 'package:note/app_define/services/auth/auth_provider.dart';
import 'package:note/app_define/services/auth/auth_user.dart';
import 'package:test/test.dart';

void main() async {
  group('Mock AuthService', () {
    final provider = MockAuthProvider();
    test('should not be initialized to begin with', () {
      expect(provider.isInitialized, false);
    });

    test('cannot log out if not initialized', () {
      expect(
        provider.logout(),
        throwsA(const TypeMatcher<NotInitializedAuthException>()),
      );
    });

     test('should be able to initialized', () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      });

      test('user should be null after initialized', () {
        expect(provider.currentUser, isNull);
      });

      test('shoud be initialized less than 2 seconds', () async {
        await provider.initialize();
        expect(provider.isInitialized, true);
      }, timeout: const Timeout(Duration(seconds: 2)));

      test('create user should delegate to login function', () async {
        final badEmailUser = 
            provider.createUser(email: 'foo@bar.com', password: 'anypassword');
        expect(
          badEmailUser,
          throwsA(const TypeMatcher<UserNotFoundAuthException>())
          );

        final badPasswordUser =
             provider.createUser(email: 'foo@bar.com', password: 'foobar');
        expect(
          badPasswordUser,
          throwsA(const TypeMatcher<WrongPasswordAuthException>())
          );
        final user = await provider.createUser(email: 'foo', password: 'bar');
        expect(provider.currentUser, user);
        expect(user.isEmailVerified, true);
      });

      test('logined in user shoudl be able to get verified', () {
        provider.sendEmailVerification();
        final user = provider.currentUser;
        expect(user, isNotNull);
        expect(user!.isEmailVerified, true);
      });

      test('should be able to log out and log in again', () async {
        await provider.logout();
        await provider.login(email: 'email', password: 'password');
        final user = provider.currentUser;
        expect(user, isNotNull);
      });
  });
}

class NotInitializedAuthException implements Exception {}

class MockAuthProvider implements AuthProvider {
  AuthUser? _user;
  var _isInitialized = false;

  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser(
      {required String email, required String password}) async {
    if (!_isInitialized) throw NotInitializedAuthException();
    await Future.delayed(const Duration(seconds: 1));
    return login(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;
  @override
  Future<void> initialize() async {
    await Future.delayed(const Duration(seconds: 1));
    _isInitialized = true;
  }

  @override
  Future<AuthUser> login({required String email, required String password}) {
    if (!_isInitialized) throw NotInitializedAuthException();
    if (email == 'foo@bar.com') throw UserNotFoundAuthException();
    if (password == 'foobar') throw WrongPasswordAuthException();
    final user = AuthUser(email: email, isEmailVerified: true);
    _user = user;
    return Future.value(user);
  }

  @override
  Future<void> logout() async {
    if (!_isInitialized) throw NotInitializedAuthException();
    await Future.delayed(const Duration(seconds: 1));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    if (!_isInitialized) throw NotInitializedAuthException();
    final user = _user;
    if (user == null) throw UserNotLoginedAuthException();
    final newUser = AuthUser(email: user.email, isEmailVerified: true);
    if (newUser.isEmailVerified) return;
    _user = newUser;
  }
}
