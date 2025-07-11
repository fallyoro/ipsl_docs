import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:ipsl_docs/services/token_service.dart';

class AuthService {
  Dio dio;
  TokenService tokens;

  AuthService({required this.dio, required this.tokens});

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dio.post(
        "/login",
        data: jsonEncode({'email': email, 'password': password}),
      );

      // Si on arrive ici, c’est forcément un 200
      await tokens.saveTokens(
        response.data['access_token'],
        response.data['refresh_token'],
      );

      return {
        'id': response.data['user']['id'],
        'user_name': response.data['user']['user_name'],
        'email': response.data['user']['email'],
      };
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return {'error': e.response?.data['detail']};
      } else {
        return {'error': "Erreur serveur : ${e.response?.statusCode}"};
      }
    } catch (e) {
      return {"error": "Erreur réseau ou inconnue : $e"};
    }
  }

  Future<Map<String, dynamic>> signUp(
    String userName,
    String email,
    String password,
    String classe,
  ) async {
    try {
      final resp = await dio.post(
        "/sign-up",
        data: jsonEncode({
          'user_name': userName,
          'email': email,
          'password': password,
          'classe': classe,
        }),
      );

      if (resp.statusCode == 200) {
        return {
          'id': resp.data['id'],
          'user_name': resp.data['user_name'],
          'email': resp.data['email'],
        };
      }

      return {'error': 'Erreur serveur: code ${resp.statusCode}'};
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return {'error': e.response?.data['detail']};
      }
      // Timeout, pas de connexion, etc.
      /* if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      throw Exception('Problème réseau, réessaye plus tard.');
    }*/
      // Autre erreur Dio
      // throw Exception('Erreur API: ${e.message}');
      return {'error': 'Erreur API: ${e.message}'};
    } catch (e) {
      return {'error': 'Erreur inconnue: $e'};
    }
  }
}
