import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';

/// Provider for managing app language and RTL support
class LanguageProvider extends ChangeNotifier {
  Locale _locale = const Locale('ar'); // Default to Arabic
  bool _isRTL = true;

  Locale get locale => _locale;
  bool get isRTL => _isRTL;
  bool get isArabic => _locale.languageCode == 'ar';
  bool get isEnglish => _locale.languageCode == 'en';

  LanguageProvider() {
    _loadLanguage();
  }

  /// Load saved language preference
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(AppConstants.languageKey) ?? 'ar';
    _locale = Locale(languageCode);
    _isRTL = languageCode == 'ar';
    notifyListeners();
  }

  /// Set language
  Future<void> setLanguage(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.languageKey, languageCode);
    
    _locale = Locale(languageCode);
    _isRTL = languageCode == 'ar';
    notifyListeners();
  }

  /// Toggle between Arabic and English
  Future<void> toggleLanguage() async {
    final newLanguage = isArabic ? 'en' : 'ar';
    await setLanguage(newLanguage);
  }

  /// Get text direction
  TextDirection get textDirection => _isRTL ? TextDirection.rtl : TextDirection.ltr;

  /// Get text align
  TextAlign get textAlign => _isRTL ? TextAlign.right : TextAlign.left;

  /// Get cross axis alignment
  CrossAxisAlignment get crossAxisAlignment => 
      _isRTL ? CrossAxisAlignment.end : CrossAxisAlignment.start;

  /// Get main axis alignment for rows
  MainAxisAlignment get mainAxisAlignment => 
      _isRTL ? MainAxisAlignment.end : MainAxisAlignment.start;
}
