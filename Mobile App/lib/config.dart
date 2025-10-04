class Config {

  static const String baseUrl = "http://127.0.0.1:8000";
  // For Android emulator
  // static const String baseUrl = "http://10.0.2.2:8000";

  // For iOS simulator (use this instead for iOS)
  // static const String baseUrl = "http://localhost:8000";

  // For real device (replace with your computer's IP)
  // static const String baseUrl = "http://192.168.1.100:8000";

  static String get signupUrl => "$baseUrl/api/v2/signup";
  static String get loginUrl => "$baseUrl/api/v2/login";
  static String get reportsUrl => "$baseUrl/api/v2/reports";
  static String get verifyTokenUrl => "$baseUrl/api/v2/verify-token";
}
