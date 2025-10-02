class AppConstants {
  // Información básica de la app
  static const String appName = 'Cowork Frontend';
  static const String appVersion = '1.0.0';

  // Configuración de la API (FastAPI)
  static const String baseUrl = 'http://10.0.2.2:8000'; // Para emulador Android
  // static const String baseUrl = 'http://localhost:8000'; // Para iOS
  // static const String baseUrl = 'http://192.168.1.X:8000'; // Para dispositivo físico

  // Timeouts
  static const int connectTimeout = 30000; // 30 segundos
  static const int receiveTimeout = 30000; // 30 segundos

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';
}
