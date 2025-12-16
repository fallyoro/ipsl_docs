import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ipsl_docs/src/core/notification_service.dart';
import 'package:ipsl_docs/src/view_models/document.dart';

import '../core/utils.dart';
import '../database/database.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum LoginMethod { google, email }

class UserViewModel {
  final DatabaseHelper _db;
  final UserService _userService;
  ValueNotifier<User?> userNotifier = ValueNotifier(null);
  ValueNotifier<String?> errorNotifier = ValueNotifier(null);
  ValueNotifier<ViewState> authState = ValueNotifier(ViewState.idle);
  LoginMethod? loginMethod;

  UserViewModel(this._db, this._userService);
  Future<void> addUser(User user) async {
    await _db.insertUser(user);
    userNotifier.value = user;
  }

  Future<void> editProfile({
    required String classe,
    required userId,
    required String newUserName,
  }) async {
    authState.value = ViewState.loading;
    final result = await _userService.editProfile(classe, userId, newUserName);
    result.fold(
      (failure) {
        authState.value = ViewState.error;
        errorNotifier.value = failure.message;
      },
      (userData) async {
        authState.value = ViewState.success;
        await updateUser(newUserName, classe);
      },
    );
  }

  Future<void> init() async {
    final User? user = await _db.getUser();
    if (user != null) {
      userNotifier.value = user;
    } else {
      userNotifier.value = User(
        id: "23",
        email: "N/A",
        classe: "N/A",
        numberContribution: 000,
        userName: "N/A",
        canUpload: false,
      );
    }
  }

  Future<void> loginWithGoogle() async {
    authState.value = ViewState.loading;
    loginMethod = LoginMethod.google;
    final googleSignIn = GoogleSignIn.instance;
    googleSignIn.authorizationClient;
    googleSignIn.initialize(serverClientId: dotenv.env["CLIENT_ID"]);
    try {
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate(
        scopeHint: ['email'],
      );
      logInfo(googleUser.toString());
      final String idToken = googleUser.authentication.idToken!;
      final result = await _userService.loginWithGoogle(idToken);
      result.fold(
        (failure) {
          authState.value = ViewState.error;
          logError("Login with google failed: ${failure.message}");
          errorNotifier.value = failure.message;
        },
        (userData) async {
          logInfo("User data ${userData.toString()}");
          User newUser = User.fromJson(userData);
          await addUser(newUser);
          DocumentViewModel documentViewModel = GetIt.I<DocumentViewModel>();
          await documentViewModel.syncDocumentFromServer();
          await documentViewModel.loadDocuments();
          authState.value = ViewState.success;
        },
      );
    } on GoogleSignInException catch (e) {
      if (e.code.name == 'canceled') {
        authState.value = ViewState.idle;
        logError("Connexion Google annulée ${e.toString()}");
        errorNotifier.value = 'Connexion Google annulée';
      } else {
        logError("Error login google ${e.toString()}");
        authState.value = ViewState.error;
        errorNotifier.value = 'Erreur connexion Google';
      }
      return;
    }
  }

  Future<void> updateFcmToken() async {
    String? fcmToken = NotificationService.token;
    String email = userNotifier.value?.email ?? "";
    if (email.isNotEmpty && fcmToken != null) {
      try {
        await _userService.updateFcmToken(email, fcmToken);
        logInfo("FCM token registered for user: $email");
      } catch (e) {
        logError("Failed to register FCM token: $e");
      }
    } else {
      logError("No user found to register FCM token or token is null");
    }
  }

  Future<void> updateNumberContribution(int numberContribution) async {
    await _db.updateNumberContribution(numberContribution);
    await init();
  }

  Future<void> updateUser(String userName, String classe) async {
    await _db.updateUser(classe, userName);
    userNotifier.value = userNotifier.value!.copyWith(
      userName: userName,
      classe: classe,
    );
  }

  Future<bool> userExist() async {
    final User? user = await _db.getUser();
    return user != null;
  }

  Future<void> syncUploadPermission() async {
    final result = await _userService.canUserUpload(userNotifier.value!.id);
    result.fold(
      (failure) {
        logError("Failed to check if the user can upload merde");
      },
      (data) async {
        if (data['can_upload'] == 1) {
          await _db.updateCanUploadField();
          userNotifier.value!.copyWith(canUpload: true);
        } else {
          logInfo("The user can not upload according to the server");
        }
      },
    );
  }
}

enum ViewState { idle, loading, success, error }
