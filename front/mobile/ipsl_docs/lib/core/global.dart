import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/services/auth_service.dart';
import 'package:ipsl_docs/services/document.dart';
import 'package:ipsl_docs/view_models/document.dart';
import 'package:ipsl_docs/view_models/user.dart';

import 'constant.dart';

final optionsUserService = BaseOptions(
  baseUrl: 'http://$host:$port/auth/',
  connectTimeout: Duration(seconds: 3),
  receiveTimeout: Duration(seconds: 10),
);
final dioUserService = Dio(optionsUserService);
Future<void> setupDependencies() async {
  final getIt = GetIt.instance;
  final db = DatabaseHelper.instance;

  final DocumentServive documentService = DocumentServive();
  final DocumentViewModel documentViewModel = DocumentViewModel(
    db,
    documentService,
  );

  //  await documentViewModel.deleteAlldoc();

  await documentViewModel.loadDocuments();
  // await documentViewModel.syncDocumentFromServer();
  final UserService userService = UserService(dio: dioUserService);
  final userViewModel = UserViewModel(db, userService);

  logInfo("Before getting the user in the setup dependencies");
  await userViewModel.init();

  logInfo("After getting the user in the setup dependencies");

  getIt.registerSingleton<DocumentViewModel>(documentViewModel);
  getIt.registerSingleton<UserViewModel>(userViewModel);
  getIt.registerSingleton<DocumentServive>(documentService);
}
