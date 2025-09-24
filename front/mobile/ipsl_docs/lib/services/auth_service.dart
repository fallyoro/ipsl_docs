import 'dart:convert';
import 'package:dio/dio.dart';

class UserService {
  Dio dio;
  UserService({required this.dio});

  Future<Map<String, dynamic>> editProfile(
    String classe,
    String userName,
    String newUserName,
  ) async {
    try {
      final response = await dio.put(
        "edit-profile",
        data: jsonEncode({
          'user_name': userName,
          'new_user_name': newUserName,
          "classe": classe,
        }),
      );
      return {
        'user_name': response.data['user_name'],
        'classe': response.data['classe'],
      };
    } catch (e) {
      return {"error": "Erreur inconnue : $e"};
    }
  }
}

class AuthService {
  Dio dio;

  AuthService({required this.dio});

  Future<Map<String, dynamic>> login(String userName, String password) async {
    try {
      final response = await dio.post(
        "/login",
        data: jsonEncode({'user_name': userName, 'password': password}),
      );

      /*
      await tokens.saveTokens(
        response.data['access_token'],
        response.data['refresh_token'],
      );

      */

      return {
        'id': response.data['user']['id'],
        'user_name': response.data['user']['user_name'],
        'number_contribution': response.data['user']['number_contribution'],
        'classe': response.data['user']['classe'],
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
    String password,
    String classe,
  ) async {
    try {
      final resp = await dio.post(
        "/sign-up",
        data: jsonEncode({
          'user_name': userName,
          'password': password,
          'classe': classe,
        }),
      );

      if (resp.statusCode == 200) {
        return {
          'id': resp.data['id'],
          'user_name': resp.data['user_name'],
          'number_contribution': resp.data['number_contribution'],
        };
      }

      return {'error': 'Erreur serveur: code ${resp.statusCode}'};
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return {'error': e.response?.data['detail']};
      }

      return {'error': 'Erreur API: ${e.message}'};
    } catch (e) {
      return {'error': 'Erreur inconnue: $e'};
    }
  }
}
