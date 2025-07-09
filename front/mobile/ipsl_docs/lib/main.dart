import 'package:flutter/material.dart';
import 'package:ipsl_docs/core/global.dart';
import 'package:ipsl_docs/core/notifiers.dart';
import 'package:ipsl_docs/core/theme.dart';
import 'package:ipsl_docs/core/utils.dart';
import 'package:ipsl_docs/stokage_service.dart';
import 'package:ipsl_docs/views/sign_up.dart';
import 'package:ipsl_docs/widget_tree.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  ThemeController.loadTheme();
  // await StorageService.setBool("isLoged", false); //xdcdcdcdcd

  final dir = await getApplicationDocumentsDirectory();

  logInfo('DB path: ${dir.path}/ipsl_docs.db');

  await setupDependencies();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: ThemeController.isDarkModeNotifier,
      builder: (context, isDark, child) {
        bool isLoged = StorageService.getBool("isLoged");
        final theme = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
        return AnimatedTheme(
          data: theme,
          curve: Curves.decelerate,
          duration: const Duration(seconds: 1),
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: theme,

            home: isLoged ? WidgetTree() : SignUpPage(),
          ),
        );
      },
    );
  }
}

