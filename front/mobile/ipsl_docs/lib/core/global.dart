import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/view_models/document.dart';
import 'package:ipsl_docs/view_models/user.dart';

Future<void> setupDependencies() async {
  final getIt = GetIt.instance;
  final bool isConnected = await isConnectedToInternet();
  final sqlite = await SQLiteService.init();
  if (isConnected) {
    //  await sqlite.insertAllDoc();
  }

  final documentViewModel = DocumentViewModel(sqlite);
  // documentViewModel.deleteAlldoc();
  await documentViewModel.loadDocuments();

  final userViewModel = UserViewModel(sqlite);
  userViewModel.getUser();
  getIt.registerSingleton<DocumentViewModel>(documentViewModel);
  getIt.registerSingleton<UserViewModel>(userViewModel);
}
