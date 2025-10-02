class ApiEndpoints {
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // User endpoints
  static const String users = '/users';
  static const String userProfile = '/users/me';
  static const String updateProfile = '/users/profile';

  // Coworking spaces endpoints (ajusta según tu API)
  static const String spaces = '/spaces';
  static const String bookings = '/bookings';
  static const String reviews = '/reviews';
}
