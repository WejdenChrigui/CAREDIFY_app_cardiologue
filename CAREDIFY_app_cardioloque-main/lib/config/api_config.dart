class ApiConfig {
  static const String baseUrl = 'http://10.181.146.152:5000';
  
  // Routes
  static const String registerDoctor = '$baseUrl/doctor/register';
  static const String loginDoctor = '$baseUrl/doctor/login';
  static const String getProfile = '$baseUrl/doctor/profile';
  static const String getPatients = '$baseUrl/doctor/patients';
}
