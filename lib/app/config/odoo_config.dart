class OdooConfig {
  // URL server
  static const String baseUrl = 'https://v16alhamra.cendana2000.id/';
  
  // Database server
  static const String database = 'db_sipp';
  
  // API endpoints
  static const String loginEndpoint = '/api/v1/session/authenticate';
  static const String logoutEndpoint = '/web/session/destroy';
  
  // Timeout settings
  static const int timeoutSeconds = 30;
}