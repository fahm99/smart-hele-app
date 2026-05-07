import 'package:flutter/material.dart';

/// Provider for general app state
class AppProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  int _currentNavIndex = 0;
  bool _isOffline = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentNavIndex => _currentNavIndex;
  bool get isOffline => _isOffline;

  /// Set loading state
  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error
  void setError(String? message) {
    _error = message;
    notifyListeners();
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Set navigation index
  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  /// Set offline status
  void setOffline(bool value) {
    _isOffline = value;
    notifyListeners();
  }

  /// Show snackbar message
  void showMessage(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
