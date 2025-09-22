class RobleConfig {
  static const String baseUrl = 'https://roble-api.openlab.uninorte.edu.co';
  static const String dbName = 'movilapp_a4de2ed3d7';
  
  // Auth Endpoints
  static String get loginEndpoint => '/auth/$dbName/login';
  static String get signupEndpoint => '/auth/$dbName/signup';
  static String get signupDirectEndpoint => '/auth/$dbName/signup-direct';
  static String get refreshTokenEndpoint => '/auth/$dbName/refresh-token';
  static String get verifyEmailEndpoint => '/auth/$dbName/verify-email';
  static String get forgotPasswordEndpoint => '/auth/$dbName/forgot-password';
  static String get resetPasswordEndpoint => '/auth/$dbName/reset-password';
  static String get logoutEndpoint => '/auth/$dbName/logout';
  static String get verifyTokenEndpoint => '/auth/$dbName/verify-token';
  
  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };
}