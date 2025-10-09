import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/services/document.dart';
import 'package:ipsl_docs/view_models/document.dart';
import 'package:ipsl_docs/view_models/user.dart';

Future<void> setupDependencies() async {
  final getIt = GetIt.instance;
  final db = DatabaseHelper.instance;

  final DocumentViewModel documentViewModel = DocumentViewModel(db);

  await documentViewModel.deleteAlldoc();

  await documentViewModel.loadDocuments();

  final userViewModel = UserViewModel(db);

  logInfo("Before getting the user in the setup dependencies");
  final DocumentServive documentServive = DocumentServive();
  await userViewModel.init();

  logInfo("After getting the user in the setup dependencies");

  getIt.registerSingleton<DocumentViewModel>(documentViewModel);
  getIt.registerSingleton<UserViewModel>(userViewModel);
  getIt.registerSingleton<DocumentServive>(documentServive);
}
