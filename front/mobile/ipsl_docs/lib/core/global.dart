import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/view_models/document.dart';
import 'package:ipsl_docs/view_models/user.dart';


Future<void> setupDependencies() async {
  final getIt = GetIt.instance;
  final db = DatabaseHelper.instance;

  try {
    final DocumentViewModel documentViewModel = DocumentViewModel(db);

    try {
      await documentViewModel.deleteAlldoc();
    } catch (e, stack) {
      logInfo("Error deleting documents: $e\n$stack");
    }

    try {
      await documentViewModel.loadDocuments();
    } catch (e, stack) {
      logInfo("Error loading documents: $e\n$stack");
    }

    final userViewModel = UserViewModel(db);

    logInfo("Before getting the user in the setup dependencies");

    try {
      await userViewModel.init();
    } catch (e, stack) {
      logInfo("Error initializing user: $e\n$stack");
    }

    logInfo("After getting the user in the setup dependencies");

    try {
      getIt.registerSingleton<DocumentViewModel>(documentViewModel);
      getIt.registerSingleton<UserViewModel>(userViewModel);
    } catch (e, stack) {
      logInfo("Error registering dependencies: $e\n$stack");
    }
  } catch (e, stack) {
    logInfo("Unexpected error in setupDependencies: $e\n$stack");
  }
}
