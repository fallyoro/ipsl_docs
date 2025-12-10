import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ipsl_docs/src/core/failure.dart';
import 'package:ipsl_docs/src/core/notification_service.dart';

import '../core/network_exception.dart';
import '../core/utils.dart';

/* TODO refactoriser pour eviter la duplication de code entre AuthService et UserService
IL yas une duplication entre AuthService et UserService.
 La raison est que plus tard je compte passer a la programmation fonctionnelle avec
le package dartz. Donc je prefere garder les deux services separes pour l'instant.
*/
final String baseUrl = dotenv.env['API_BASE_URL'] as String;

class UserService {
  late final Dio dio;
  UserService() {
    BaseOptions options = BaseOptions(
      baseUrl: '$baseUrl/auth',
      connectTimeout: Duration(seconds: 100),
      receiveTimeout: Duration(minutes: 1),
    );
    dio = Dio(options);
  }

  Future<Either<NetworkFailure, Map<String, dynamic>>> editProfile(
    String classe,
    String userId,
    String newUserName,
  ) async {
    try {
      final response = await dio.put(
        "/edit-profile",
        data: {'id': userId, 'new_user_name': newUserName, "classe": classe},
      );
      return Right({
        'user_name': response.data['user_name'],
        'classe': response.data['classe'],
      });
    } on DioException catch (e) {
      final error = NetworkException.fromDioError(e);
      return Left(NetworkFailure(error.message));
    } catch (e) {
      return Left(NetworkFailure("Erreur réseau ou inconnue : $e"));
    }
  }

  Future<Either<NetworkFailure, Map<String, dynamic>>> loginWithGoogle(
    String googleIdToken,
  ) async {
    try {
      final resp = await dio.post(
        "/google",
        data: {
          "id_token": googleIdToken,
          'fcm_token': NotificationService.token,
        },
      );
      return Right({
        'id': resp.data['user']['id'],
        'user_name': resp.data['user']['user_name'],
        'email': resp.data['user']['email'],
        'number_contribution': resp.data['user']['number_contribution'],
        'classe': resp.data['user']['classe'],
        'picture_url': resp.data['user']['picture_url'],
      });
    } on DioException catch (e) {
      final String error = NetworkException.fromDioError(e).message;
      return Left(NetworkFailure(error));
    } catch (e) {
      return Left(NetworkFailure("Erreur réseau ou inconnue : $e"));
    }
  }

  Future<void> updateFcmToken(String email, String fcmToken) async {
    try {
      await dio.put(
        "/update-fcm-token/$email",
        data: jsonEncode({'fcm_token': fcmToken}),
      );
    } on DioException catch (e) {
      logError(e.response?.data['detail'] ?? "Erreur inconnue");
    } catch (e) {
      logError("Erreur inconnue : $e");
    }
  }
}
