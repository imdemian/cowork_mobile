import 'package:get_it/get_it.dart';
import 'package:cowork_frontend/core/network/dio_client.dart';

final GetIt getIt = GetIt.instance;

class DependencyInjection {
  static void init() {
    // Core dependencies
    getIt.registerSingleton<DioClient>(DioClient());

    // Repositories (se agregarán después)
    // getIt.registerSingleton<AuthRepository>(AuthRepositoryImpl());

    // Use cases (se agregarán después)
    // getIt.registerSingleton<LoginUseCase>(LoginUseCase());

    // Providers (se agregarán después)
    // getIt.registerFactory<AuthProvider>(() => AuthProvider());
  }

  static void reset() {
    getIt.reset();
  }
}
