import 'dart:io';

// Base Failure class
abstract class Failure {
  final String message;
  final int? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure: $message';
}

// Specific failures
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

// Helper para manejar excepciones
class FailureHandler {
  static Failure handleException(dynamic error) {
    if (error is SocketException) {
      return const NetworkFailure('No hay conexión a internet');
    }

    if (error is HttpException) {
      return ServerFailure('Error HTTP: ${error.message}');
    }

    if (error is FormatException) {
      return const ServerFailure('Error de formato en la respuesta');
    }

    if (error is Failure) {
      return error;
    }

    return ServerFailure(error.toString());
  }
}
