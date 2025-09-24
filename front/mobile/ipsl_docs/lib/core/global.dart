import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/view_models/document.dart';
import 'package:ipsl_docs/view_models/navigation.dart';
import 'package:ipsl_docs/view_models/user.dart';

Future<void> setupDependencies() async {
  final getIt = GetIt.instance;
  final bool isConnected = await isConnectedToInternet();
  final db = DatabaseHelper.instance;
  if (isConnected) {
    //  await db.insertAllDoc();
  }

  final DocumentViewModel documentViewModel = DocumentViewModel(db);
  final NavigationViewModel navigationViewModel = NavigationViewModel(
    documentViewModel,
  );
  // documentViewModel.deleteAlldoc();
  await documentViewModel.loadDocuments();

  final userViewModel = UserViewModel(db);
  userViewModel.getUser();
  getIt.registerSingleton<DocumentViewModel>(documentViewModel);
  getIt.registerSingleton<UserViewModel>(userViewModel);
  getIt.registerSingleton<NavigationViewModel>(navigationViewModel);
}
