import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/bluetooth/bluetooth_devices_screen.dart';
import '../screens/admin/admin_home_screen.dart';
import '../screens/admin/admin_settings_screen.dart';
import '../screens/admin/management_screen.dart';
import '../screens/auth/admin_login_screen.dart';
import '../screens/auth/admin_register_screen.dart';
import '../screens/auth/change_password_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_selection_screen.dart';
import '../screens/auth/user_login_screen.dart';
import '../screens/auth/user_register_screen.dart';
import '../screens/home/create_report_screen.dart';
import '../screens/home/splash_screen.dart';
import '../screens/home/user_home_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/profile/user_profile_screen.dart';
import '../screens/settings/user_settings_screen.dart';

/// App router configuration using GoRouter
class AppRouter {
  AppRouter._();

  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      // Bluetooth Devices Screen
      GoRoute(
        path: '/bluetooth-devices',
        name: 'bluetooth-devices',
        builder: (context, state) => const BluetoothDevicesScreen(),
      ),

      // Splash Screen
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) {
          final userType = state.uri.queryParameters['type'] ?? 'user';
          return OnboardingScreen(userType: userType);
        },
      ),

      // Login Selection
      GoRoute(
        path: '/login-selection',
        name: 'login-selection',
        builder: (context, state) => const LoginSelectionScreen(),
      ),

      // User Auth
      GoRoute(
        path: '/user-login',
        name: 'user-login',
        builder: (context, state) => const UserLoginScreen(),
      ),
      GoRoute(
        path: '/user-register',
        name: 'user-register',
        builder: (context, state) => const UserRegisterScreen(),
      ),

      // Admin Auth
      GoRoute(
        path: '/admin-login',
        name: 'admin-login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/admin-register',
        name: 'admin-register',
        builder: (context, state) => const AdminRegisterScreen(),
      ),

      // User Home
      GoRoute(
        path: '/user-home',
        name: 'user-home',
        builder: (context, state) => const UserHomeScreen(),
      ),

      // باقي المسارات كما هي...
      GoRoute(
        path: '/user-profile',
        name: 'user-profile',
        builder: (context, state) => const UserProfileScreen(),
      ),
      GoRoute(
        path: '/user-settings',
        name: 'user-settings',
        builder: (context, state) => const UserSettingsScreen(),
      ),
      GoRoute(
        path: '/change-password',
        name: 'change-password',
        builder: (context, state) => const ChangePasswordScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/create-report',
        name: 'create-report',
        builder: (context, state) => const CreateReportScreen(),
      ),
      GoRoute(
        path: '/admin-home',
        name: 'admin-home',
        builder: (context, state) => const AdminHomeScreen(),
      ),
      GoRoute(
        path: '/management',
        name: 'management',
        builder: (context, state) => const ManagementScreen(),
      ),
      GoRoute(
        path: '/admin-settings',
        name: 'admin-settings',
        builder: (context, state) => const AdminSettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
  );
}

/// Route names
class Routes {
  Routes._();

  static const String bluetoothDevices = '/bluetooth-devices';
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String loginSelection = '/login-selection';
  static const String userLogin = '/user-login';
  static const String userRegister = '/user-register';
  static const String adminLogin = '/admin-login';
  static const String adminRegister = '/admin-register';
  static const String userHome = '/user-home';
  static const String userProfile = '/user-profile';
  static const String userSettings = '/user-settings';
  static const String changePassword = '/change-password';
  static const String forgotPassword = '/forgot-password';
  static const String adminHome = '/admin-home';
  static const String management = '/management';
  static const String adminSettings = '/admin-settings';
}

/// Navigation helpers
extension GoRouterExtension on BuildContext {
  void goToBluetoothDevices() => go(Routes.bluetoothDevices);
  void goToSplash() => go(Routes.splash);
  void goToOnboarding({String type = 'user'}) =>
      go('${Routes.onboarding}?type=$type');
  void goToLoginSelection() => go(Routes.loginSelection);
  void goToUserLogin() => go(Routes.userLogin);
  void goToUserRegister() => go(Routes.userRegister);
  void goToAdminLogin() => go(Routes.adminLogin);
  void goToAdminRegister() => go(Routes.adminRegister);
  void goToUserHome() => go(Routes.userHome);
  void goToUserProfile() => go(Routes.userProfile);
  void goToUserSettings() => go(Routes.userSettings);
  void goToAdminHome() => go(Routes.adminHome);
  void goToManagement() => go(Routes.management);
  void goToAdminSettings() => go(Routes.adminSettings);
}
