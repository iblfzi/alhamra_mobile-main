import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/services/seeder_service.dart';
import 'core/services/language_service.dart';
import 'core/providers/auth_provider.dart';
import 'core/utils/app_styles.dart';
import 'core/localization/app_localizations.dart';
import 'app/config/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set status bar color
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: AppStyles.primaryColor,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  
  // Initialize services
  final languageService = LanguageService();
  await languageService.initializeLanguage();
  
  await SeederService().seedAll();
  await initializeDateFormatting('id_ID', null);
  await initializeDateFormatting('en_US', null);
  
  runApp(MyApp(languageService: languageService));
}

class MyApp extends StatelessWidget {
  final LanguageService languageService;
  
  const MyApp({super.key, required this.languageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider.value(value: languageService),
      ],
      child: Consumer<LanguageService>(
        builder: (context, languageService, child) {
          return MaterialApp(
        title: 'Alhamra App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppStyles.primaryColor),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
          primarySwatch: Colors.blue,
          primaryColor: AppStyles.primaryColor,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: AppBarTheme(
            backgroundColor: AppStyles.primaryColor,
            foregroundColor: Colors.white,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: AppStyles.primaryColor,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
            ),
          ),
        ),
            locale: languageService.currentLocale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            initialRoute: AppRoutes.splash,
            routes: AppRoutes.routes,
          );
        },
      ),
    );
  }
}
