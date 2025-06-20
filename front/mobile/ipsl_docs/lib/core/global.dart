import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:ipsl_docs/view_models/document.dart';

final getIt = GetIt.instance;

Future<void> setupDependencies() async {
  final sqlite = await SQLiteService.init();
  await sqlite.insertMockData();

  final viewModel = DocumentViewModel(sqlite);
  await viewModel.loadDocuments();

  getIt.registerSingleton<DocumentViewModel>(viewModel);
}
