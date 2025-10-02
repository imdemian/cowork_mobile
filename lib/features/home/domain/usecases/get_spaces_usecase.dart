import 'package:dartz/dartz.dart';
import 'package:cowork_frontend/core/errors/failures.dart';
import '../entities/space_entity.dart';
import '../repositories/home_repository.dart';

class GetSpacesUseCase {
  final HomeRepository repository;

  GetSpacesUseCase(this.repository);

  Future<Either<Failure, List<SpaceEntity>>> call() async {
    return await repository.getSpaces();
  }
}
