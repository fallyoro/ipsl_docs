import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/view_models/document.dart';
import 'package:ipsl_docs/view_models/user.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final sqlite = await SQLiteService.init();
  await sqlite.insertMockData();

  final documentViewModel = DocumentViewModel(sqlite);
  await documentViewModel.loadDocuments();

  final userViewModel = UserViewModel(sqlite);

  getIt.registerSingleton<DocumentViewModel>(documentViewModel);
  getIt.registerSingleton<UserViewModel>(userViewModel);
}
