import 'package:flutter/widgets.dart';
import 'package:ipsl_docs/src/core/notification_service.dart';
import '../core/utils.dart';
import '../database/database.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum ViewState { idle, loading, success, error }

class UserViewModel {
  final DatabaseHelper _db;
  final UserService _userService;
  ValueNotifier<User?> userNotifier = ValueNotifier(null);
  ValueNotifier<String?> errorNotifier = ValueNotifier(null);
  ValueNotifier<ViewState> authState = ValueNotifier(ViewState.idle);

  UserViewModel(this._db, this._userService);
  Future<void> addUser(User user) async {
    await _db.insertUser(user);
    userNotifier.value = user;
  }

  Future<void> updateUser(String userName, String classe) async {
    await _db.updateUser(classe, userName);
    userNotifier.value = await _db.getUser();
  }

  Future<void> updateNumberContribution(int numberContribution) async {
    await _db.updateNumberContribution(numberContribution);
    await init();
  }

  Future<void> init() async {
    final User? user = await _db.getUser();
    if (user != null) {
      userNotifier.value = user;
    } else {
      // Gérer le cas où l'utilisateur est null
      userNotifier.value = User(
        id: "23",
        classe: "N/A",
        numberContribution: 000,
        userName: "N/A",
      );
    }
  }

  Future<bool> userExist() async {
    final User? user = await _db.getUser();
    return user != null;
  }

  /*Future<User?> getUser() async {
    final User? user = await _db.getUser();
    if (user != null) {
      user.toString();
      // userNotifier.value = user;
    }

    return user;
  }*/

  Future<void> updateFcmToken() async {
    String? fcmToken = NotificationService.token;
    String userName = userNotifier.value?.userName ?? "";
    if (userName.isNotEmpty && fcmToken != null) {
      try {
        await _userService.updateFcmToken(userName, fcmToken);
        logInfo("FCM token registered for user: $userName");
      } catch (e) {
        logError("Failed to register FCM token: $e");
      }
    } else {
      logError("No user found to register FCM token or token is null");
    }
  }

  Future<void> login(String userName, String password) async {
    authState.value = ViewState.loading;
    final result = await _userService.login(userName, password);
    result.fold(
      (failure) {
        authState.value = ViewState.error;
        logError("Login failed: ${failure.message}");
        errorNotifier.value = failure.message;
      },
      (userData) async {
        authState.value = ViewState.success;
        User newUser = User(
          id: userData['id'],
          userName: userName,
          classe: userData['classe'],
          numberContribution: userData['number_contribution'],
        );

        //      StorageService.setBool("isLoged", true);
        await addUser(newUser);
        authState.value = ViewState.success;
      },
    );
  }

  Future<void> signUp(String userName, String password, String classe) async {
    authState.value = ViewState.loading;
    final result = await _userService.signUp(userName, password, classe);
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
          classe: userData['classe'],
          numberContribution: userData['number_contribution'],
        );

        //      StorageService.setBool("isLoged", true);
        await addUser(newUser);
      },
    );
  }
}
