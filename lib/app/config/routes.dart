import 'package:flutter/material.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/onboard_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboard = '/onboard';
  static const String login = '/login';
  static const String home = '/home';

  static Map<String, WidgetBuilder> get routes => {
    splash: (context) => const SplashScreen(),
    onboard: (context) => const OnboardScreen(),
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
  };
}
