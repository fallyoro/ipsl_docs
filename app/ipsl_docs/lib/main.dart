import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
import 'package:ipsl_docs/src/core/constant.dart';
import 'package:ipsl_docs/src/core/global.dart';
import 'package:ipsl_docs/src/core/theme_controller.dart';
import 'package:ipsl_docs/src/core/theme.dart';
import 'package:ipsl_docs/src/core/utils.dart';
import 'package:ipsl_docs/src/core/notification_service.dart';
import 'package:ipsl_docs/src/core/stokage_service.dart';
import 'package:ipsl_docs/src/pages/introduction/onboarding.dart';
import 'package:ipsl_docs/src/view_models/user.dart';
import 'package:ipsl_docs/src/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:toastification/toastification.dart';
import 'src/core/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
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
  UserViewModel userViewModel = GetIt.I<UserViewModel>();
  final bool isLoged = await userViewModel.userExist();
  await StorageService.setBool("isLoged", isLoged);
  if (!isLoged) {
    await StorageService.setBool("isDark", isDarkModePrefer());
  }
  ThemeController.loadTheme();

  runApp(ToastificationWrapper(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ThemeController.isDarkModeNotifier,
      builder: (context, isDark, _) {
        Future.microtask(() {
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              systemNavigationBarColor: isDark
                  ? AppColors.darkSecondarySystemBackground
                  : Colors.white,
              systemNavigationBarIconBrightness: isDark
                  ? Brightness.light
                  : Brightness.dark,
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
