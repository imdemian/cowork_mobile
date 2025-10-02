import 'package:get_it/get_it.dart';
import 'package:cowork_frontend/core/network/dio_client.dart';
import 'package:cowork_frontend/features/home/data/datasources/home_remote_datasource.dart';
import 'package:cowork_frontend/features/home/data/repositories/home_repository_impl.dart';
import 'package:cowork_frontend/features/home/domain/repositories/home_repository.dart';
import 'package:cowork_frontend/features/home/domain/usecases/get_spaces_usecase.dart';

final GetIt getIt = GetIt.instance;

class DependencyInjection {
  static void init() {
    // Core dependencies
    getIt.registerSingleton<DioClient>(DioClient());

    // Home feature
    getIt.registerSingleton<HomeRemoteDataSource>(
      HomeRemoteDataSourceImpl(getIt()),
    );
    getIt.registerSingleton<HomeRepository>(
      HomeRepositoryImpl(getIt()),
    );
    getIt.registerSingleton<GetSpacesUseCase>(
      GetSpacesUseCase(getIt()),
    );
  }

  static void reset() {
    getIt.reset();
  }
}