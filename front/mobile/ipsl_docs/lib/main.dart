import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ipsl_docs/src/core/constant.dart';
import 'package:ipsl_docs/src/core/global.dart';
import 'package:ipsl_docs/src/core/notifiers.dart';
import 'package:ipsl_docs/src/core/theme.dart';
import 'package:ipsl_docs/src/core/utils.dart';
import 'package:ipsl_docs/src/database/database.dart';
import 'package:ipsl_docs/src/models/user.dart';
import 'package:ipsl_docs/src/core/notification_service.dart';
import 'package:ipsl_docs/src/core/stokage_service.dart';
import 'package:ipsl_docs/src/pages/introduction/onboarding.dart';
import 'package:ipsl_docs/src/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'src/core/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await setupDependencies();
  } catch (e) {
    logError("Error during setupDependencies: $e");
  }
  try {
    await NotificationService.init();
  } catch (e) {
    logError("Error during NotificationService.init: $e");
  }
  await StorageService.init();
  User? userData = await DatabaseHelper.instance.getUser();
  if (userData == null) {
    await StorageService.setBool("isLoged", false);
    await StorageService.setBool("isDark", isDarkModePrefer());
  }
  ThemeController.loadTheme();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.isDarkModeNotifier,
      builder: (context, isDark, _) {
        // ✅ Appelé à chaque changement
        Future.microtask(() {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              systemNavigationBarColor:
                  isDark
                      ? AppColors.darkSecondarySystemBackground
                      : Colors.white,
              systemNavigationBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
            ),
          );
        });

        final theme = isDark ? AppTheme.darkTheme : AppTheme.lightTheme;
        final isLoged = StorageService.getBool("isLoged");

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          theme: theme,
          home: isLoged ? const WidgetTree() : const IntroductionScreen(),
        );
      },
    );
  }
}
