class ApiConfig {
  static const String baseUrl = 'https://api.gymovo.com';
  static const String workoutsEndpoint = '/workouts';
  static const String exercisesEndpoint = '/exercises';
  static const String usersEndpoint = '/users';

  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Timeout settings
  static const int connectTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
}
