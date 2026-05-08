import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/firebase_service.dart';

/// Provider for managing authentication state
class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseService _firebaseService = FirebaseService();

  User? _firebaseUser;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  User? get firebaseUser => _firebaseUser;
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _firebaseUser != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isDriver => _user?.isDriver ?? false;

  AuthProvider() {
    _init();
  }

  /// Initialize auth state
  void _init() {
    _auth.authStateChanges().listen((User? user) async {
      _firebaseUser = user;
      if (user != null) {
        await _loadUserData(user.uid);
      } else {
        _user = null;
        notifyListeners();
      }
    });
  }

  /// Load user data from Firestore
  Future<void> _loadUserData(String userId) async {
    try {
      _user = await _firebaseService.getUser(userId);
      notifyListeners(); // إشعار المستمعين بتحديث بيانات المستخدم
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Sign in with email and password
  Future<bool> signIn(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // انتظر حتى تكتمل عملية تحميل بيانات المستخدم
        await _loadUserData(result.user!.uid);

        // إذا لم يتم تحميل البيانات، جرب مرة أخرى
        if (_user == null) {
          // انتظر إضافياً للتأكد من تحميل البيانات
          await Future.delayed(const Duration(milliseconds: 500));
          await _loadUserData(result.user!.uid);
        }

        // تأكد من أن بيانات المستخدم محملة قبل الإرجاع
        if (_user != null) {
          _setLoading(false);
          return true;
        } else {
          _setError(
              'لم يتم العثور على بيانات المستخدم. يرجى التواصل مع المسؤول');
          _setLoading(false);
          return false;
        }
      }
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e));
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
    return false;
  }

  /// Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String userType,
    String? phone,
    String? idNumber,
    String? vehicleType,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Create user document in Firestore
        final newUser = UserModel(
          id: result.user!.uid,
          email: email,
          name: name,
          userType: userType,
          phone: phone,
          idNumber: idNumber,
          vehicleType: vehicleType,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firebaseService.createUser(newUser);
        _user = newUser;
        _setLoading(false);
        notifyListeners();
        return true;
      }
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e));
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
    return false;
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _auth.signOut();
      _user = null;
      _firebaseUser = null;
    } catch (e) {
      _setError(e.toString());
    }
    _setLoading(false);
  }

  /// Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e));
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
    return false;
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? vehicleType,
    String? avatarUrl,
  }) async {
    if (_user == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final updatedUser = _user!.copyWith(
        name: name,
        phone: phone,
        vehicleType: vehicleType,
        avatarUrl: avatarUrl,
        updatedAt: DateTime.now(),
      );

      await _firebaseService.updateUser(updatedUser);
      _user = updatedUser;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
    return false;
  }

  /// Update user status
  Future<bool> updateStatus(bool isActive) async {
    if (_user == null) return false;

    try {
      final updatedUser = _user!.copyWith(
        isActive: isActive,
        updatedAt: DateTime.now(),
      );

      await _firebaseService.updateUser(updatedUser);
      _user = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Clear error
  void _clearError() {
    _error = null;
  }

  /// Set loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Set error message
  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  /// Check if user data is fully loaded
  bool get isUserDataLoaded => _user != null;

  /// Reload user data from Firestore
  Future<void> reloadUser() async {
    if (_firebaseUser != null) {
      await _loadUserData(_firebaseUser!.uid);
    }
  }

  /// Get human-readable error message
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'لم يتم العثور على مستخدم بهذا البريد الإلكتروني';
      case 'wrong-password':
        return 'كلمة المرور غير صحيحة';
      case 'email-already-in-use':
        return 'البريد الإلكتروني مستخدم بالفعل';
      case 'invalid-email':
        return 'البريد الإلكتروني غير صالح';
      case 'weak-password':
        return 'كلمة المرور ضعيفة جداً';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب';
      default:
        return e.message ?? 'حدث خطأ غير متوقع';
    }
  }
}
