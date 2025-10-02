import 'package:dartz/dartz.dart';
import 'package:cowork_frontend/core/errors/failures.dart';
import 'package:cowork_frontend/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register(
    String email,
    String password,
    String firstName,
    String lastName,
  );
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, bool>> isAuthenticated();
}
