// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mamasave/utils/app_colors.dart';
import 'package:mamasave/utils/app_styles.dart';
import 'package:mamasave/services/auth_service.dart';
import 'package:mamasave/services/data_manager.dart';
import 'package:mamasave/services/theme_notifier.dart';
import 'package:mamasave/pages/splash_screen.dart';
import 'package:mamasave/pages/onboarding_screen.dart';
import 'package:mamasave/pages/home_page.dart';
import 'package:mamasave/pages/login_page.dart';
import 'package:mamasave/pages/signup_page.dart';
import 'package:mamasave/pages/mother_dashboard.dart';
import 'package:mamasave/pages/chw_dashboard.dart';
import 'package:mamasave/pages/midwife_dashboard.dart';
import 'package:mamasave/pages/all_mothers_list_screen.dart';
import 'package:mamasave/pages/mother_profile_screen.dart';
import 'package:mamasave/pages/settings_screen.dart';
import 'package:mamasave/pages/visit_history_screen.dart';
import 'package:mamasave/pages/health_tips_screen.dart';
import 'package:mamasave/pages/vitals_graph_screen.dart';
import 'package:mamasave/pages/panic_history_screen.dart';
import 'package:mamasave/pages/documents_upload_screen.dart';
import 'package:mamasave/pages/pregnancy_progress_screen.dart';
import 'package:mamasave/pages/help_support_screen.dart';
import 'package:mamasave/pages/add_edit_health_visit.dart';
import 'package:mamasave/pages/report_emergency.dart';
import 'package:mamasave/pages/notifications.dart';
import 'package:mamasave/pages/backend_demo_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; 
import 'package:mamasave/services/api_service.dart';
import 'package:mamasave/pages/login_page.dart'; // Your existing login page
import 'package:mamasave/pages/backend_demo_page.dart'; // Your existing backend demo page
import 'package:mamasave/pages/mother_dashboard.dart'; // YOUR EXISTING MOTHER DASHBOARD
import 'package:mamasave/pages/chw_dashboard.dart';    // YOUR EXISTING CHW DASHBOARD
import 'package:mamasave/pages/midwife_dashboard.dart'; // YOUR EXISTING MIDWIFE DASHBOARD
// Make sure this is correctly imported

// lib/main.dart (inside MultiProvider)

// ... (existing imports at the top, ensure api_service.dart is imported)

void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );  
  // ... (your existing main function code before runApp) ...

  runApp(
    MultiProvider(
      providers: [
        // 1. Provide ApiService as a plain Provider, as it has no dependencies.
        Provider<ApiService>(create: (_) => ApiService()),

        // 2. Provide AuthService using ProxyProvider, as it depends on ApiService.
        //    AuthService is a ChangeNotifier, so we use ChangeNotifierProxyProvider.
        ChangeNotifierProvider(
          create: (_) => AuthService(), // AuthService now initializes ApiService internally
        ),

        // 3. Provide DataManager using ProxyProvider, as it also depends on ApiService.
        //    DataManager is a ChangeNotifier, so we use ChangeNotifierProxyProvider.
        ChangeNotifierProxyProvider<ApiService, DataManager>(
          create: (context) => DataManager(context.read<ApiService>()), // Initial creation
          update: (context, apiService, dataManager) => DataManager(apiService), // Update if ApiService changes
        ),

        // 4. Keep your ThemeNotifier as a standard ChangeNotifierProvider.
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
      ],
      child: const MamaSaveApp(),
    ),
  );
}

class MamaSaveApp extends StatefulWidget {
  const MamaSaveApp({super.key});

  @override
  State<MamaSaveApp> createState() => _MamaSaveAppState();
}

class _MamaSaveAppState extends State<MamaSaveApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'MamaSave',
      debugShowCheckedModeBanner: false,
      // Define the light theme for the application.
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: AppColors.primaryColor,
        hintColor: AppColors.accentColor, // Used for accent elements like icons
        scaffoldBackgroundColor: AppColors.backgroundColor,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: AppColors.whiteTextColor, // Correct: direct access
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppStyles.headline2.copyWith(
              color: AppColors.whiteTextColor), // Correct: direct access
        ),
        textTheme: TextTheme(
          displayLarge: AppStyles.headline1,
          displayMedium: AppStyles.headline2,
          displaySmall: AppStyles.headline3,
          titleLarge: AppStyles.subTitle,
          bodyLarge: AppStyles.bodyText1,
          bodyMedium: AppStyles.bodyText2,
          labelLarge: AppStyles.buttonTextStyle,
        ).apply(
          bodyColor: AppColors.textColor,
          displayColor: AppColors.textColor,
        ),
        inputDecorationTheme: AppStyles.inputDecorationTheme.copyWith(
          fillColor: AppColors.surfaceColor,
          labelStyle:
              AppStyles.bodyText1.copyWith(color: AppColors.secondaryTextColor),
          hintStyle: AppStyles.bodyText2
              .copyWith(color: AppColors.secondaryTextColor.withOpacity(0.7)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppColors.dividerColor, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2.0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppStyles.primaryButtonStyle.copyWith(
            backgroundColor: MaterialStateProperty.all(AppColors.primaryColor),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: AppStyles.secondaryButtonStyle.copyWith(
            foregroundColor: MaterialStateProperty.all(AppColors.primaryColor),
            side: MaterialStateProperty.all(
                const BorderSide(color: AppColors.primaryColor, width: 1.5)),
          ),
        ),
        // Changed from CardTheme to CardThemeData
        cardTheme: CardThemeData( 
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          margin: EdgeInsets.zero,
          color: AppColors.surfaceColor,
        ),

        iconTheme: const IconThemeData(
          color: AppColors.textColor,
        ),
        dividerColor: AppColors.dividerColor,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Changed from DialogTheme to DialogThemeData
        dialogTheme: DialogThemeData( 
          backgroundColor: AppColors.surfaceColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          titleTextStyle: AppStyles.headline3.copyWith(color: AppColors.textColor),
          contentTextStyle: AppStyles.bodyText1.copyWith(color: AppColors.secondaryTextColor),
        ),

        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle: AppStyles.bodyText1.copyWith(color: AppColors.textColor),
          menuStyle: MenuStyle(
            backgroundColor: MaterialStateProperty.all(AppColors.surfaceColor),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0))),
          ),
        ),
        listTileTheme: ListTileThemeData(
          iconColor: AppColors.secondaryTextColor,
          textColor: AppColors.textColor,
          selectedTileColor: AppColors.primaryColor.withOpacity(0.1),
          selectedColor: AppColors.primaryColor,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryColor,
            textStyle:
                AppStyles.linkTextStyle.copyWith(color: AppColors.primaryColor),
          ),
        ),
      ),
      // Define the dark theme for the application.
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.primaryColorDark,
        hintColor: AppColors.accentColorDark,
        scaffoldBackgroundColor: AppColors.backgroundColorDark,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryColorDark,
          foregroundColor: AppColors.whiteTextColor, // Correct: direct access
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppStyles.headline2.copyWith(
              color: AppColors.whiteTextColor), // Correct: direct access
        ),
        textTheme: TextTheme(
          displayLarge: AppStyles.headline1,
          displayMedium: AppStyles.headline2,
          displaySmall: AppStyles.headline3,
          titleLarge: AppStyles.subTitle,
          bodyLarge: AppStyles.bodyText1,
          bodyMedium: AppStyles.bodyText2,
          labelLarge: AppStyles.buttonTextStyle,
        ).apply(
          bodyColor: AppColors.textColorDark,
          displayColor: AppColors.textColorDark,
        ),
        inputDecorationTheme: AppStyles.inputDecorationTheme.copyWith(
          fillColor: AppColors.surfaceColorDark,
          labelStyle: AppStyles.bodyText1
              .copyWith(color: AppColors.secondaryTextColorDark),
          hintStyle: AppStyles.bodyText2.copyWith(
              color: AppColors.secondaryTextColorDark.withOpacity(0.7)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide:
                BorderSide(color: AppColors.dividerColorDark, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide:
                BorderSide(color: AppColors.primaryColorDark, width: 2.0),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: AppStyles.primaryButtonStyle.copyWith(
            backgroundColor:
                MaterialStateProperty.all(AppColors.primaryColorDark),
            foregroundColor: MaterialStateProperty.all(
                AppColors.whiteTextColor), // Correct: direct access
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: AppStyles.secondaryButtonStyle.copyWith(
            foregroundColor:
                MaterialStateProperty.all(AppColors.primaryColorDark),
            side: MaterialStateProperty.all(
                BorderSide(color: AppColors.primaryColorDark, width: 1.5)),
          ),
        ),
        // Changed from CardTheme to CardThemeData
        cardTheme: CardThemeData( 
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          margin: EdgeInsets.zero,
          color: AppColors.surfaceColorDark,
        ),

        iconTheme: const IconThemeData(
          color: AppColors.textColorDark,
        ),
        dividerColor: AppColors.dividerColorDark,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        // Changed from DialogTheme to DialogThemeData
        dialogTheme: DialogThemeData( 
          backgroundColor: AppColors.surfaceColorDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          titleTextStyle: AppStyles.headline3.copyWith(color: AppColors.textColorDark),
          contentTextStyle: AppStyles.bodyText1.copyWith(color: AppColors.secondaryTextColorDark),
        ),

        dropdownMenuTheme: DropdownMenuThemeData(
          textStyle:
              AppStyles.bodyText1.copyWith(color: AppColors.textColorDark),
          menuStyle: MenuStyle(
            backgroundColor:
                MaterialStateProperty.all(AppColors.surfaceColorDark),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0))),
          ),
        ),
        listTileTheme: ListTileThemeData(
          iconColor: AppColors.secondaryTextColorDark,
          textColor: AppColors.textColorDark,
          selectedTileColor: AppColors.primaryColorDark.withOpacity(0.1),
          selectedColor: AppColors.primaryColorDark,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primaryColorDark,
            textStyle: AppStyles.linkTextStyle
                .copyWith(color: AppColors.primaryColorDark),
          ),
        ),
      ),
      themeMode: themeNotifier.themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        // Corrected: Provide a default userName for HomePage when used as role_selection
        '/role_selection': (context) => const HomePage(userName: 'Guest'),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignupPage(),
        '/mother_dashboard': (context) => const MotherDashboard(),
        '/chw_dashboard': (context) => const ChwDashboard(),
        '/midwife_dashboard': (context) => const MidwifeDashboard(),
        '/all_mothers': (context) => const AllMothersListScreen(),
        '/mother_profile': (context) => const MotherProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/health_tips': (context) => const HealthTipsScreen(),
        '/vitals_graph': (context) =>
            const VitalsGraphScreen(motherId: 'mother_001'),
        '/panic_history': (context) => const PanicHistoryScreen(),
        '/documents_upload': (context) => const DocumentsUploadScreen(),
        '/pregnancy_progress': (context) => const PregnancyProgressScreen(),
        '/help_support': (context) => const HelpSupportScreen(),
        '/backend_demo': (context) => const BackendDemoPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/visit_history') {
          final args = settings.arguments as Map<String, String>?;
          return MaterialPageRoute(
            builder: (context) {
              return VisitHistoryScreen(
                userId: args?['userId'],
                role: args?['role'],
              );
            },
          );
        } else if (settings.name == '/vitals_graph') {
          final args = settings.arguments as Map<String, String>?;
          return MaterialPageRoute(
            builder: (context) {
              return VitalsGraphScreen(
                motherId: args?['motherId'] ?? 'mother_001',
              );
            },
          );
        }
        // This part handles routes not explicitly defined in the 'routes' map,
        // ensuring 'HomePage' always gets a userName.
        return MaterialPageRoute(builder: (context) {
          switch (settings.name) {
            case '/':
              return const SplashScreen();
            case '/onboarding':
              return const OnboardingScreen();
            case '/role_selection':
              // Corrected: Ensure HomePage receives a userName here too
              return const HomePage(userName: 'Guest');
            case '/login':
              return const LoginPage();
            case '/signup':
              return const SignupPage();
            case '/mother_dashboard':
              return const MotherDashboard();
            case '/chw_dashboard':
              return const ChwDashboard();
            case '/midwife_dashboard':
              return const MidwifeDashboard();
            case '/all_mothers':
              return const AllMothersListScreen();
            case '/mother_profile':
              return const MotherProfileScreen();
            case '/settings':
              return const SettingsScreen();
            case '/health_tips':
              return const HealthTipsScreen();
            case '/panic_history':
              return const PanicHistoryScreen();
            case '/documents_upload':
              return const DocumentsUploadScreen();
            case '/pregnancy_progress':
              return const PregnancyProgressScreen();
            case '/help_support':
              return const HelpSupportScreen();
            case '/backend_demo':
              return const BackendDemoPage();
            default:
              return Scaffold(
                appBar: AppBar(title: const Text('Error')),
                body: Center(
                  child: Text('Error: Unknown route ${settings.name}',
                      style: AppStyles.bodyText1),
                ),
              );
          }
        });
      },
    );
  }
}