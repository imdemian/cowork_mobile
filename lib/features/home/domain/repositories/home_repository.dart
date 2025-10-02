import 'package:dartz/dartz.dart';
import 'package:cowork_frontend/core/errors/failures.dart';
import '../entities/space_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<SpaceEntity>>> getSpaces();
  Future<Either<Failure, List<SpaceEntity>>> getFeaturedSpaces();
  Future<Either<Failure, List<SpaceEntity>>> searchSpaces(String query);
}
