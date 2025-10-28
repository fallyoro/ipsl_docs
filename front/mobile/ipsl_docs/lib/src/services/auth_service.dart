import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:ipsl_docs/src/core/failure.dart';
import 'package:ipsl_docs/src/core/notification_service.dart';
import '../core/constant.dart';
import '../core/utils.dart';
import 'package:dartz/dartz.dart';
import '../core/network_exception.dart';

/* TODO refactoriser pour eviter la duplication de code entre AuthService et UserService
IL yas une duplication entre AuthService et UserService.
 La raison est que plus tard je compte passer a la programmation fonctionnelle avec
le package dartz. Donc je prefere garder les deux services separes pour l'instant.
*/

class UserService {
  late final Dio dio;
  UserService() {
    BaseOptions options = BaseOptions(
      baseUrl: 'http://$host:$port/auth',
      connectTimeout: Duration(seconds: 3),
      // receiveTimeout: Duration(minutes: 1),
    );
    dio = Dio(options);
  }

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

  Future<void> updateFcmToken(String userName, String fcmToken) async {
    try {
      await dio.put(
        "/update-fcm-token/$userName",
        data: jsonEncode({'fcm_token': fcmToken}),
      );
    } on DioException catch (e) {
      logError(e.response?.data['detail'] ?? "Erreur inconnue");
    } catch (e) {
      logError("Erreur inconnue : $e");
    }
  }

  Future<Either<NetworkFailure, Map<String, dynamic>>> login(
    String userName,
    String password,
  ) async {
    try {
      final response = await dio.post(
        "/login",
        data: jsonEncode({
          'user_name': userName,
          'password': password,
          'fcm_token': NotificationService.token,
        }),
      );

      /*
      await tokens.saveTokens(
        response.data['access_token'],
        response.data['refresh_token'],
      );

      */

      logInfo("Login data : ${response.data.toString()}");

      return Right({
        'id': response.data['user']['id'],
        'user_name': response.data['user']['user_name'],
        'number_contribution': response.data['user']['number_contribution'],
        'classe': response.data['user']['classe'],
      });
    } on DioException catch (e) {
      final error = NetworkException.fromDioError(e);
      return Left(NetworkFailure(error.message));
    } catch (e) {
      return Left(NetworkFailure("Erreur réseau ou inconnue : $e"));
    }
  }

  Future<Either<NetworkFailure, Map<String, dynamic>>> signUp(
    String userName,
    String password,
    String classe,
  ) async {
    try {
      final resp = await dio.post(
        "/sign-up",
        data: {
          'user_name': userName,
          'password': password,
          'classe': classe,
          'fcm_token': NotificationService.token,
        },
      );
      logInfo("Sinup data : ${resp.data.toString()}");

      return Right({
        'id': resp.data['id'],
        'user_name': resp.data['user_name'],
        'number_contribution': resp.data['number_contribution'],
        'classe': resp.data['classe'],
      });
    } on DioException catch (e) {
      final error = NetworkException.fromDioError(e);
      return Left(NetworkFailure(error.message));
    } catch (e) {
      logError("Erreur inconnue : $e");
      return Left(NetworkFailure('Erreur inconnue'));
    }
  }
}
