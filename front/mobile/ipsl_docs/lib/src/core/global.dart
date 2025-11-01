import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/core/utils.dart';
import '../database/database.dart';
import '../services/auth_service.dart';
import '../services/document.dart';
import '../view_models/document.dart';
import '../view_models/user.dart';

Future<void> setupDependencies() async {
  final getIt = GetIt.instance;
  final db = DatabaseHelper.instance;

  final DocumentService documentService = DocumentService();
  final DocumentViewModel documentViewModel = DocumentViewModel(
    db,
    documentService
  );

  try {
    await documentViewModel.syncDocumentFromServer();
  } catch (e) {
    logError("Can't sync document from the server");
  }
  await documentViewModel.loadDocuments();
  final UserService userService = UserService();
  final userViewModel = UserViewModel(db, userService);
  await userViewModel.init();
  getIt.registerSingleton<DocumentViewModel>(documentViewModel);
  getIt.registerSingleton<UserViewModel>(userViewModel);
  getIt.registerSingleton<DocumentService>(documentService);
  getIt.registerSingleton<UserService>(userService);
}
