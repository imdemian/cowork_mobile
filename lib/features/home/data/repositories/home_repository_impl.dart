import 'package:dartz/dartz.dart';
import 'package:cowork_frontend/core/errors/failures.dart';
import '../../domain/entities/space_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<SpaceEntity>>> getSpaces() async {
    try {
      final spaces = await remoteDataSource.getSpaces();
      return Right(spaces.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(FailureHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<SpaceEntity>>> getFeaturedSpaces() async {
    try {
      final spaces = await remoteDataSource.getFeaturedSpaces();
      return Right(spaces.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(FailureHandler.handleException(e));
    }
  }

  @override
  Future<Either<Failure, List<SpaceEntity>>> searchSpaces(String query) async {
    try {
      final spaces = await remoteDataSource.searchSpaces(query);
      return Right(spaces.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(FailureHandler.handleException(e));
    }
  }
}
