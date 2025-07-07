import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:ipsl_docs/services/token_service.dart';

class AuthService {
  Dio dio;
  TokenService tokens;

  AuthService({required this.dio, required this.tokens});

  Future<Map<String, dynamic>?> login(String email, String password) async {
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
      if (e.response?.statusCode == 403) {
        throw Exception("Identifiants incorrects");
      } else {
        throw Exception("Erreur serveur : ${e.response?.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur réseau ou inconnue : $e");
    }
  }

  Future<Map<String, dynamic>?> signUp(
    String userName,
    String email,
    String password,
    String classe,
  ) async {
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
      // await tokens.saveTokens(resp.data['access'], resp.data['refresh']);
      return {
        'id': resp.data['id'],
        'user_name': resp.data['user_name'],
        'email': resp.data['email'],
      };
    }
    return null;
  }
}
