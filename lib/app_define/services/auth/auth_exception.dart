
// login exception
class UserNotFoundAuthException implements Exception{}

class WrongPasswordAuthException implements Exception{}

// register exception
class EmailAlreadyInUseAuthException implements Exception{}

class WeakPasswordAuthException implements Exception{}

class InvalidEmailAuthException implements Exception{}

// generic excpetion
class GenericAuthException implements Exception{}

class UserNotLoginedAuthException implements Exception{}