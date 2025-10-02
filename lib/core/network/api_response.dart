import 'package:dartz/dartz.dart';
import 'package:cowork_frontend/core/errors/failures.dart';

// Response estándar para todas las llamadas API
class ApiResponse<T> {
  final Either<Failure, T> result;

  ApiResponse.success(T data) : result = Right(data);
  ApiResponse.failure(Failure failure) : result = Left(failure);

  bool get isSuccess => result.isRight();
  bool get isFailure => result.isLeft();

  T? get data => result.fold((_) => null, (data) => data);
  Failure? get failure => result.fold((failure) => failure, (_) => null);

  // Helper methods
  void fold({
    required Function(T data) onSuccess,
    required Function(Failure failure) onFailure,
  }) {
    result.fold(onFailure, onSuccess);
  }
}
