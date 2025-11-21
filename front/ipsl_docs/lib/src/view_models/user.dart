import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ipsl_docs/src/core/notification_service.dart';

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
      );
    }
  }

  Future<void> login({required String email, required String password}) async {
    authState.value = ViewState.loading;
    loginMethod = LoginMethod.email;
    final result = await _userService.login(email: email, password: password);
    result.fold(
      (failure) {
        logInfo("Login failed: ${failure.message}");
        authState.value = ViewState.error;
        logError("Login failed: ${failure.message}");
        errorNotifier.value = failure.message;
      },
      (userData) async {
        authState.value = ViewState.success;
        logInfo("Login successfuly");
        try {
          User newUser = User(
            id: userData['id'],
            userName: userData['user_name'],
            email: userData['email'],
            classe: userData['classe'],
            numberContribution: userData['number_contribution'],
          );
          await addUser(newUser);
        } catch (e) {
          logError("Can't create a user : ${e.toString()}");
        }
      },
    );
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
          // await _userService.updateFcmToken(
          //   newUser.email,
          //   NotificationService.token!,
          // );
          authState.value = ViewState.success;
          // Future.microtask(() {
          //   authState.value = ViewState.success;
          // });
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

  Future<void> signUp(
    String userName,
    String password,
    String email,
    String classe,
  ) async {
    authState.value = ViewState.loading;
    final result = await _userService.signUp(
      email: email,
      userName: userName,
      password: password,
      classe: classe,
    );
    result.fold(
      (failure) {
        authState.value = ViewState.error;
        logError("SignUp failed: ${failure.message}");
        errorNotifier.value = failure.message;
      },
      (userData) async {
        authState.value = ViewState.success;
        User newUser = User(
          id: userData['id'],
          userName: userName,
          email: email,
          classe: userData['classe'],
          numberContribution: userData['number_contribution'],
        );

        await addUser(newUser);
      },
    );
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
}

enum ViewState { idle, loading, success, error }
