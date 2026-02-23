/// Configuration de l'api
class ApiConfig {
  ApiConfig._();

  /// Base URL de l'API ce qui est deja heberger.
  static const String baseUrl = 'https://ai4bmi.cabinet-xaviertermeau.com/api';

  /// Base URL pour backend local c'est la base url pour le developpement mais on va utiliser la base url pour le production.
  static const String localBaseUrl = 'http://10.0.2.2:8000/api';
}
