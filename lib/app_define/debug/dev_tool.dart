import 'dart:developer' as developer show log;

class DevTool {
  static void log(Object? message ) {
    developer.log(message.toString());
  }
}
