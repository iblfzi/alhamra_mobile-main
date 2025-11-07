import 'package:alhamra_1/core/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../core/utils/app_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Set status bar for splash screen (dark icons on white background)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    // Reset status bar to app theme when leaving splash screen
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: AppStyles.primaryColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    super.dispose();
  }

  void _checkAuthAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Wait for minimum splash time (1.5 seconds) for better UX
    final minimumSplashTime = Future.delayed(const Duration(milliseconds: 1500));
    
    // Wait for auth check to complete
    while (authProvider.status == AuthStatus.uninitialized ||
           authProvider.status == AuthStatus.authenticating) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted) return;
    }
    
    // Ensure minimum splash time has passed
    await minimumSplashTime;
    
    if (mounted) {
      if (authProvider.status == AuthStatus.authenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/onboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Logo perfectly centered
          Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8,
                maxHeight: MediaQuery.of(context).size.height * 0.25,
              ),
              child: Image.asset(
                'assets/logo/alhamra_splashscreen.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
          
          // Loading animation at bottom
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: LoadingAnimationWidget.dotsTriangle(
                color: AppStyles.primaryColor,
                size: 40,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


