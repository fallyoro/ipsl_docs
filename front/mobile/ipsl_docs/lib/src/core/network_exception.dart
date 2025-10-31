import 'package:dio/dio.dart';
import 'package:ipsl_docs/src/core/utils.dart';

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  factory NetworkException.fromDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionError:
        return NetworkException(
          "Erreur de connexion réseau. Vérifiez votre connexion.",
        );
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException("Délai de connexion dépassé");
      case DioExceptionType.badResponse:
        //return NetworkException("Erreur serveur : ${e.response?.statusCode}");
        final statusCode = e.response?.statusCode;
        if (statusCode == 400) {
          return NetworkException(
            "Requête invalide. Veuillez vérifier vos données.",
          );
        } else if (statusCode == 409) {
          return NetworkException("L'utilisateur existe déjà.");
        } else if (statusCode == 401) {
          return NetworkException(
            "Identifiants invalides. Veuillez réessayer.",
          );
        } else if (statusCode == 403) {
          return NetworkException("Accès refusé.");
        } else if (statusCode == 404) {
          return NetworkException("Ressource non trouvée.");
        } else if (statusCode == 500) {
          return NetworkException(
            "Erreur interne du serveur. Veuillez réessayer plus tard.",
          );
        } else {
          return NetworkException("Erreur serveur inconnue");
        }
      default:
        return NetworkException("Erreur inattendue");
    }
  }
}
