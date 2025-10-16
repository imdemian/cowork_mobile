import 'package:dio/dio.dart';
<<<<<<< Updated upstream
=======
import 'package:logger/logger.dart';
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
import 'package:cowork_frontend/core/constants/app_constants.dart';
import 'package:cowork_frontend/core/errors/failures.dart';

class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio()
      ..options.baseUrl = AppConstants.baseUrl
      ..options.connectTimeout = Duration(
        milliseconds: AppConstants.connectTimeout,
      )
      ..options.receiveTimeout = Duration(
        milliseconds: AppConstants.receiveTimeout,
      )
      ..options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Log de requests
          print('🌐 REQUEST: ${options.method} ${options.uri}');
          if (options.data != null) {
            print('📦 BODY: ${options.data}');
          }
<<<<<<< Updated upstream
<<<<<<< Updated upstream

          // Agregar token de autenticación si existe
          // final token = await _getToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }

=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print(
            '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
          );
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          print('❌ ERROR: ${error.type} - ${error.message}');

<<<<<<< Updated upstream
<<<<<<< Updated upstream
          // Convertir errores de Dio a nuestros Failures
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: const NetworkFailure('Timeout de conexión'),
                type: error.type,
              ),
            );
          }

          if (error.type == DioExceptionType.connectionError) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: const NetworkFailure('Error de conexión'),
                type: error.type,
              ),
            );
          }

          if (error.response != null) {
            final statusCode = error.response!.statusCode;
            final errorMessage = _getErrorMessage(error.response!.data);

            if (statusCode == 401) {
              return handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  error: AuthenticationFailure(errorMessage),
                  type: DioExceptionType.badResponse,
                  response: error.response,
                ),
              );
            } else if (statusCode == 403) {
              return handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  error: PermissionFailure(errorMessage),
                  type: DioExceptionType.badResponse,
                  response: error.response,
                ),
              );
            } else if (statusCode != null && statusCode >= 500) {
              return handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  error: ServerFailure('Error del servidor: $statusCode'),
                  type: DioExceptionType.badResponse,
                  response: error.response,
                ),
              );
            } else {
              return handler.reject(
                DioException(
                  requestOptions: error.requestOptions,
                  error: ServerFailure(errorMessage, code: statusCode),
                  type: DioExceptionType.badResponse,
                  response: error.response,
                ),
              );
            }
          }

          return handler.next(
            DioException(
              requestOptions: error.requestOptions,
              error: ServerFailure(error.message ?? 'Error desconocido'),
              type: error.type,
              response: error.response,
            ),
          );
        },
      ),
    );
  }

  String _getErrorMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
<<<<<<< Updated upstream
<<<<<<< Updated upstream
      return data['detail'] ?? data['message'] ?? 'Error desconocido';
=======
=======
>>>>>>> Stashed changes
      return data['detail'] ??
          data['message'] ??
          data['error'] ??
          'Ocurrió un error';
>>>>>>> Stashed changes
    }
    return 'Error desconocido';
  }

  Dio get dio => _dio;
}
