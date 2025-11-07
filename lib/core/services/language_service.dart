import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  Locale _currentLocale = const Locale('id', 'ID'); // Default Indonesian
  
  Locale get currentLocale => _currentLocale;
  
  bool get isIndonesian => _currentLocale.languageCode == 'id';
  bool get isEnglish => _currentLocale.languageCode == 'en';
  
  String get currentLanguageName => isIndonesian ? 'Bahasa Indonesia' : 'English';
  String get currentLanguageCode => _currentLocale.languageCode.toUpperCase();
  
  // Initialize language from SharedPreferences
  Future<void> initializeLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey) ?? 'id';
    
    if (savedLanguage == 'en') {
      _currentLocale = const Locale('en', 'US');
    } else {
      _currentLocale = const Locale('id', 'ID');
    }
    notifyListeners();
  }
  
  // Change language and save to SharedPreferences
  Future<void> changeLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (languageCode == 'en') {
      _currentLocale = const Locale('en', 'US');
    } else {
      _currentLocale = const Locale('id', 'ID');
    }
    
    await prefs.setString(_languageKey, languageCode);
    notifyListeners();
  }
  
  // Toggle between Indonesian and English
  Future<void> toggleLanguage() async {
    final newLanguage = isIndonesian ? 'en' : 'id';
    await changeLanguage(newLanguage);
  }
}
