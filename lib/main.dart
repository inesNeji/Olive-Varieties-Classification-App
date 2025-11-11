import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Controllers
import 'package:olive_leaf_analyzer/controllers/main_controller.dart';

// Views
import 'package:olive_leaf_analyzer/views/main_view.dart';
import 'package:olive_leaf_analyzer/views/historique_view.dart';
import 'package:olive_leaf_analyzer/views/profile_view.dart';
import 'package:olive_leaf_analyzer/views/analysis_view.dart';
import 'package:olive_leaf_analyzer/views/results_view.dart';
import 'package:olive_leaf_analyzer/views/welcome_vienw.dart';
import 'package:olive_leaf_analyzer/views/dashboard_view.dart';
import 'package:olive_leaf_analyzer/views/signup_view.dart';
import 'package:olive_leaf_analyzer/views/login_view.dart';
import 'package:olive_leaf_analyzer/views/ResetPasswordView.dart';
import 'package:olive_leaf_analyzer/views/change_password_view.dart';
import 'package:olive_leaf_analyzer/views/ConfirmCodeView.dart';
import 'package:olive_leaf_analyzer/views/modifypass_view.dart';

// Translations
import 'package:olive_leaf_analyzer/translations/translations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  // System UI setup
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Load stored locale or default to French
  final box = GetStorage();
  final savedLocale = box.read('locale');
final initialLocale = savedLocale != null
    ? Locale(savedLocale['languageCode'], savedLocale['countryCode'])
    : const Locale('fr', 'FR');


  runApp(MyApp(initialLocale: initialLocale));
}

class MyApp extends StatelessWidget {
  final Locale initialLocale;

  const MyApp({super.key, required this.initialLocale});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LeafScan',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      translations: AppTranslationstr(),
      locale: initialLocale,
      fallbackLocale: const Locale('fr', 'FR'),
      initialRoute: '/welcome',
      getPages: [
        GetPage(name: '/welcome', page: () => const WelcomePage()),
        GetPage(
          name: '/',
          page: () => MainView(),
          binding: BindingsBuilder(() => Get.put(MainController())),
        ),
        GetPage(name: '/historique', page: () => HistoriqueView()),
        GetPage(name: '/profile', page: () => const ProfileView()),
        GetPage(name: '/analysis', page: () => AnalysisView(imagePath: Get.arguments)),
        GetPage(
          name: '/results',
          page: () {
            final args = Get.arguments as Map<String, dynamic>? ?? {};
            return ResultsView(
              imagePath: args['imagePath'] ?? '',
              resultat: args['resultat'] ?? 'No result available',
              confidence: args['confidence'] ?? 0.0,
            );
          },
        ),
        GetPage(name: '/dashboard', page: () => const DashboardView()),
        GetPage(name: '/signup', page: () => SignupView()),
        GetPage(name: '/login', page: () => const LoginView()),
        GetPage(name: '/reset', page: () => ResetPasswordView()),
        GetPage(name: '/confirm-code', page: () => ConfirmCodeView()),
        GetPage(name: '/change-password', page: () => ChangePasswordView()),
        GetPage(name: '/modifypass', page: () => ModifypassView()),
      ],
    );
  }
}
