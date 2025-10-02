import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:injectable/injectable.dart';

import 'package:cowork_frontend/core/constants/app_constants.dart';
import 'package:cowork_frontend/core/errors/failures.dart';

@lazySingleton // Esto le dice a `get_it` que cree una sola instancia de esta clase
class DioClient {
  late final Dio _dio;
  final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  DioClient() {
    _dio = Dio()
      ..options.baseUrl = AppConstants.baseUrl
      ..options.connectTimeout = const Duration(
        milliseconds: AppConstants.connectTimeout,
      )
      ..options.receiveTimeout = const Duration(
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
          _logger.d('🌐 REQUEST: ${options.method} ${options.uri}');
          if (options.data != null) {
            _logger.d('📦 BODY: ${options.data}');
          }

          // Aquí puedes agregar lógica para el token de autenticación
          // final token = await _getToken();
          // if (token != null) {
          //   options.headers['Authorization'] = 'Bearer $token';
          // }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.i(
            '✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
          );
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          _logger.e(
            '❌ ERROR: ${error.type} - ${error.message}',
            error: error.error,
            stackTrace: error.stackTrace,
          );

          // Convertir errores de Dio a nuestros Failures personalizados
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
                error: const NetworkFailure('Error de conexión a internet'),
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
      // Busca en llaves comunes como 'detail', 'message' o 'error'
      return data['detail'] ??
          data['message'] ??
          data['error'] ??
          'Ocurrió un error';
    }
    return 'Ocurrió un error inesperado';
  }

  Dio get dio => _dio;
}
