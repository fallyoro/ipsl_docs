import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/core/theme.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/view_models/document.dart';
import 'package:ipsl_docs/views/home.dart';
import 'package:ipsl_docs/widget_tree.dart';
import 'package:ipsl_docs/database/database.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //final sqlite = SQLiteService();
  //await sqlite.init();
  final dir = await getApplicationDocumentsDirectory();

  logInfo('📁 DB path: ${dir.path}/ipsl_docs.db');
  _setup();

  print("===========================================================");
  //sqlite.insertMockData();
  ///final viewModel = DocumentViewModel(sqlite);
  //await viewModel.loadDocuments();

  runApp(const MyApp());
}

Future<void> _setup() async {
  final sqlite = await SQLiteService.init(); // 🔄 instance prête
  sqlite.insertMockData();
  viewModel = DocumentViewModel(sqlite);
  await viewModel.loadDocuments();
  //logInfo(viewModel.getRootFolders().first);
  logInfo("message");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeController.isDarkModeNotifier,
      builder: (context, isDark, child) {
        final theme = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;

        return AnimatedTheme(
          data: theme,
          curve: Curves.bounceOut,
          duration: const Duration(seconds: 1),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: theme,
            home: WidgetTree(),
          ),
        );
      },
    );
  }
}
