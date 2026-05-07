import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // App
      'app_name': 'SSH - Smart Safety Helmet',
      'app_title': 'SSH-APP',
      'dashboard': 'Dashboard',
      'safe': 'Safe',
      'safety_status': 'Safety Status',

      // Auth
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'name': 'Name',
      'phone': 'Phone Number',
      'id_number': 'ID Number',
      'vehicle_type': 'Vehicle Type',
      'logout': 'Logout',
      'sign_out': 'Sign Out',
      'forgot_password': 'Forgot Password?',
      'reset_password': 'Reset Password',
      'reset_password_title': 'Reset Your Password',
      'reset_password_description':
          'Enter your email address and we will send you instructions to reset your password',
      'send_reset_link': 'Send Reset Link',
      'reset_link_sent': 'Password reset link has been sent to your email',
      'enter_email': 'Enter your email',

      // Navigation
      'home': 'Home',
      'main': 'Main',
      'settings': 'Settings',
      'my_account': 'My Account',

      // Profile
      'profile': 'Profile',
      'driver_info': 'Driver Information',
      'safety_record': 'Safety Record',
      'total_trips': 'Total Trips',
      'safety_alerts': 'Safety Alerts',
      'safe_trips': 'Safe Trips',
      'last_trip': 'Last Trip',
      'driver_rating': 'Driver Rating',
      'status': 'Status',
      'active': 'Active',
      'inactive': 'Inactive',
      'no_trips': 'No trips yet',

      // Helmet
      'helmet': 'Helmet',
      'helmet_status': 'Helmet Status',
      'connected': 'Connected',
      'disconnected': 'Disconnected',
      'battery_level': 'Battery Level',
      'last_connection': 'Last Connection',
      'reconnect_helmet': 'Reconnect Helmet',
      'now': 'Now',
      'not_available': 'Not Available',

      // Settings
      'user_settings': 'User Settings',
      'account': 'Account',
      'profile_settings': 'Profile Settings',
      'change_password': 'Change Password',
      'notifications': 'Notifications',
      'enable_notifications': 'Enable Notifications',
      'accident_alerts': 'Accident Alerts',
      'speed_alerts': 'Speed Alerts',
      'battery_alerts': 'Battery Alerts',
      'connection': 'Connection',
      'bluetooth': 'Bluetooth',
      'gps': 'GPS',
      'privacy_security': 'Privacy & Security',
      'location_sharing': 'Location Sharing',
      'account_protection': 'Account Protection',
      'language': 'Language',
      'app': 'Application',
      'about_app': 'About App',
      'privacy_policy': 'Privacy Policy',
      'updates': 'Updates',

      // Privacy
      'edit_data': 'Edit Data',
      'enable_location_tracking': 'Enable Location Tracking',
      'password_protection': 'Password Protection',

      // Sensor Data
      'heart_rate': 'Heart Rate',
      'temperature': 'Temperature',
      'humidity': 'Humidity',
      'location': 'Location',
      'speed': 'Speed',
      'shock_detected': 'Shock Detected',
      'fall_detected': 'Fall Detected',
      'blood_pressure': 'Blood Pressure',
      'heart_rate_measurement': 'Heart Rate Measurement',
      'temperature_measurement': 'Temperature Measurement',
      'bluetooth_connection': 'Bluetooth Connection',
      'emergency_call': 'Emergency Call',
      'driver': 'Driver',
      'sos_sent': 'SOS signal sent',

      // Alerts
      'alerts': 'Alerts',
      'recent_alerts': 'Recent Alerts',
      'no_alerts': 'No alerts',
      'alert_heart_rate': 'Heart Rate Alert',
      'alert_temperature': 'Temperature Alert',
      'alert_shock': 'Shock Alert',
      'alert_fall': 'Fall Alert',
      'alert_battery': 'Battery Alert',
      'alert_sos': 'SOS Emergency',

      // Common
      'save': 'Save',
      'cancel': 'Cancel',
      'ok': 'OK',
      'yes': 'Yes',
      'no': 'No',
      'back': 'Back',
      'next': 'Next',
      'done': 'Done',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'unknown': 'Unknown',
      'not_specified': 'Not Specified',

      // Admin
      'admin_welcome': 'Welcome, System Administrator',
      'admin_settings': 'Admin Settings',
      'drivers': 'Drivers',
      'reports': 'Reports',
      'reports_tab': 'Reports',
      'recent_reports': 'Recent Reports',
      'today_report': 'Today\'s Report',
      'view_all': 'View All',
      'view_report': 'View Report',
      'details_management': 'Details & Management',
      'control_panel': 'Control Panel',
      'notifications_tab': 'Notifications',
      'no_reports': 'No reports',
      'no_notifications': 'No notifications',
      'organization_name': 'Organization Name',
      'smart_safety_organization': 'Smart Safety Organization',
      'account_type': 'Account Type',
      'system_admin': 'System Administrator',
      'account_status': 'Account Status',
      'emergency_alerts': 'Emergency Alerts (SOS)',
      'fall_alerts': 'Fall Alerts',
      'vital_signs_alerts': 'Vital Signs Alerts',
      'tracking_monitoring': 'Tracking & Monitoring',
      'enable_live_tracking': 'Enable Live Tracking',
      'route_history': 'Route History',
      'tracking_data_retention': 'Tracking Data Retention Period',
      'reports_analytics': 'Reports & Analytics',
      'performance_reports': 'Performance Reports',
      'export_reports': 'Export Reports',
      'incident_log': 'Incident Log',
      'account_management': 'Account Management',
      'manage_drivers': 'Manage Drivers',
      'manage_smart_helmets': 'Manage Smart Helmets',
      'permissions_access': 'Permissions & Access Levels',

      // Bluetooth
      'bluetooth_disabled': 'Bluetooth is Disabled',
      'enable_bluetooth_message':
          'Please enable Bluetooth to connect to the smart helmet',
      'enable_bluetooth': 'Enable Bluetooth',
      'scanning_devices': 'Scanning for devices...',
      'scanning_hint': 'Make sure the helmet is turned on and near your phone',
      'tips': 'Tips',
      'tip1': 'Turn on the smart helmet',
      'tip2': 'Keep the helmet close to your phone',
      'tip3': 'Make sure location is enabled',
      'no_devices_found': 'No devices found',
      'no_devices_hint':
          'Make sure:\n• The smart helmet is turned on\n• Bluetooth is enabled on your phone\n• The helmet is near your phone',
      'scan_again': 'Scan Again',
      'smart_helmet': 'Smart Helmet',
      'other_devices': 'Other Devices',
      'unknown_device': 'Unknown Device',
      'connect': 'Connect',
      'connecting_to': 'Connecting to',
      'connection_success': 'Connected successfully',
      'connection_failed': 'Connection failed',
      'disconnect': 'Disconnect',
      'disconnect_helmet': 'Disconnect Helmet',
      'disconnect_confirm':
          'Are you sure you want to disconnect from the helmet?',
      'battery': 'Battery',
    },
    'ar': {
      // App
      'app_name': 'SSH - خوذة السلامة الذكية',
      'app_title': 'SSH-APP',
      'dashboard': 'لوحة التحكم',
      'safe': 'آمن',
      'safety_status': 'حالة السلامة',

      // Auth
      'login': 'تسجيل الدخول',
      'register': 'التسجيل',
      'email': 'البريد الإلكتروني',
      'password': 'كلمة المرور',
      'confirm_password': 'تأكيد كلمة المرور',
      'name': 'الاسم',
      'phone': 'رقم الجوال',
      'id_number': 'رقم الهوية',
      'vehicle_type': 'نوع المركبة',
      'logout': 'تسجيل الخروج',
      'sign_out': 'تسجيل الخروج',
      'forgot_password': 'هل نسيت كلمة السر؟',
      'reset_password': 'إعادة تعيين كلمة السر',
      'reset_password_title': 'إعادة تعيين كلمة السر',
      'reset_password_description':
          'أدخل بريدك الإلكتروني وسنرسل لك تعليمات لإعادة تعيين كلمة السر',
      'send_reset_link': 'إرسال رابط إعادة التعيين',
      'reset_link_sent':
          'تم إرسال رابط إعادة تعيين كلمة السر إلى بريدك الإلكتروني',
      'enter_email': 'أدخل بريدك الإلكتروني',

      // Navigation
      'home': 'الرئيسية',
      'main': 'الرئيسية',
      'settings': 'الإعدادات',
      'my_account': 'حسابي',

      // Profile
      'profile': 'الملف الشخصي',
      'driver_info': 'معلومات السائق',
      'safety_record': 'سجل السلامة',
      'total_trips': 'عدد الرحلات',
      'safety_alerts': 'تنبيهات السلامة',
      'safe_trips': 'الرحلات الآمنة',
      'last_trip': 'آخر رحلة',
      'driver_rating': 'تقييم السائق',
      'status': 'الحالة',
      'active': 'نشط',
      'inactive': 'غير نشط',
      'no_trips': 'لا توجد رحلات',

      // Helmet
      'helmet': 'الخوذة',
      'helmet_status': 'حالة الخوذة',
      'connected': 'متصلة',
      'disconnected': 'غير متصلة',
      'battery_level': 'مستوى البطارية',
      'last_connection': 'آخر اتصال',
      'reconnect_helmet': 'إعادة اتصال الخوذة',
      'now': 'الآن',
      'not_available': 'غير متوفر',

      // Settings
      'user_settings': 'إعدادات المستخدم',
      'account': 'حسابي',
      'profile_settings': 'الحساب التعريفي',
      'change_password': 'تغيير كلمة السر',
      'notifications': 'الإشعارات',
      'enable_notifications': 'تفعيل الإشعارات',
      'accident_alerts': 'تنبيهات الحوادث',
      'speed_alerts': 'تنبيهات السرعة',
      'battery_alerts': 'تنبيهات البطارية',
      'connection': 'الاتصال',
      'bluetooth': 'Bluetooth',
      'gps': 'GPS',
      'privacy_security': 'الخصوصية والأمان',
      'location_sharing': 'مشاركة الموقع',
      'account_protection': 'حماية الحساب',
      'language': 'اللغة',
      'app': 'التطبيق',
      'about_app': 'عن التطبيق',
      'privacy_policy': 'سياسة الخصوصية',
      'updates': 'التحديثات',

      // Privacy
      'edit_data': 'تعديل البيانات',
      'enable_location_tracking': 'تفعيل تتبع الموقع',
      'password_protection': 'تقييم كلمة المرور',

      // Sensor Data
      'heart_rate': 'معدل ضربات القلب',
      'temperature': 'درجة الحرارة',
      'humidity': 'الرطوبة',
      'location': 'الموقع',
      'speed': 'السرعة',
      'shock_detected': 'تم رصد صدمة',
      'fall_detected': 'تم رصد سقوط',
      'blood_pressure': 'ضغط الدم',
      'heart_rate_measurement': 'قياس نبضات القلب',
      'temperature_measurement': 'قياس درجة الحرارة',
      'bluetooth_connection': 'اتصال البلوتوث',
      'emergency_call': 'اتصال الطوارئ',
      'driver': 'السائق',
      'sos_sent': 'تم إرسال إشارة الاستغاثة',

      // Alerts
      'alerts': 'التنبيهات',
      'recent_alerts': 'التنبيهات الأخيرة',
      'no_alerts': 'لا توجد تنبيهات',
      'alert_heart_rate': 'تنبيه معدل ضربات القلب',
      'alert_temperature': 'تنبيه درجة الحرارة',
      'alert_shock': 'تنبيه اصطدام',
      'alert_fall': 'تنبيه سقوط',
      'alert_battery': 'تنبيه البطارية',
      'alert_sos': 'استغاثة طوارئ',

      // Common
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'ok': 'موافق',
      'yes': 'نعم',
      'no': 'لا',
      'back': 'رجوع',
      'next': 'التالي',
      'done': 'تم',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'success': 'نجح',
      'unknown': 'غير معروف',
      'not_specified': 'غير محدد',

      // Admin
      'admin_welcome': 'مرحباً، مشرف النظام',
      'admin_settings': 'إعدادات الجهة المشرفة',
      'drivers': 'السائقين',
      'reports': 'البلاغات',
      'reports_tab': 'التقارير',
      'recent_reports': 'آخر البلاغات',
      'today_report': 'تقرير اليوم',
      'view_all': 'عرض الكل',
      'view_report': 'عرض التقرير',
      'details_management': 'التفاصيل والإدارة',
      'control_panel': 'لوحة التحكم',
      'notifications_tab': 'بلاغات',
      'no_reports': 'لا توجد تقارير',
      'no_notifications': 'لا توجد بلاغات',
      'organization_name': 'اسم الجهة',
      'smart_safety_organization': 'جهة السلامة الذكية',
      'account_type': 'نوع الحساب',
      'system_admin': 'مشرف النظام',
      'account_status': 'حالة الحساب',
      'emergency_alerts': 'تنبيهات الطوارئ (SOS)',
      'fall_alerts': 'تنبيهات السقوط',
      'vital_signs_alerts': 'تنبيهات المؤشرات الحيوية',
      'tracking_monitoring': 'التتبع والمراقبة',
      'enable_live_tracking': 'تفعيل التتبع المباشر',
      'route_history': 'سجل المسارات',
      'tracking_data_retention': 'مدة حفظ بيانات التتبع',
      'reports_analytics': 'التقارير والتحليلات',
      'performance_reports': 'تقارير الأداء',
      'export_reports': 'تصدير التقارير',
      'incident_log': 'سجل الحوادث',
      'account_management': 'إدارة الحساب',
      'manage_drivers': 'إدارة السائقين',
      'manage_smart_helmets': 'إدارة الخوذة الذكية',
      'permissions_access': 'الصلاحيات ومستويات الوصول',

      // Bluetooth
      'bluetooth_disabled': 'البلوتوث غير مفعل',
      'enable_bluetooth_message': 'يرجى تفعيل البلوتوث للاتصال بالخوذة الذكية',
      'enable_bluetooth': 'تفعيل البلوتوث',
      'scanning_devices': 'جاري البحث عن الأجهزة...',
      'scanning_hint': 'تأكد من تشغيل الخوذة وأنها قريبة من الهاتف',
      'tips': 'نصائح',
      'tip1': 'تشغيل الخوذة الذكية',
      'tip2': 'إبقاء الخوذة قريبة من الهاتف',
      'tip3': 'التأكد من تفعيل الموقع',
      'no_devices_found': 'لم يتم العثور على أجهزة',
      'no_devices_hint':
          'تأكد من:\n• تشغيل الخوذة الذكية\n• تفعيل البلوتوث على الهاتف\n• أن الخوذة قريبة من الهاتف',
      'scan_again': 'بحث مرة أخرى',
      'smart_helmet': 'الخوذة الذكية',
      'other_devices': 'أجهزة أخرى',
      'unknown_device': 'جهاز بدون اسم',
      'connect': 'اتصال',
      'connecting_to': 'جاري الاتصال بـ',
      'connection_success': 'تم الاتصال بنجاح',
      'connection_failed': 'فشل في الاتصال',
      'disconnect': 'قطع الاتصال',
      'disconnect_helmet': 'قطع اتصال الخوذة',
      'disconnect_confirm': 'هل أنت متأكد من قطع الاتصال بالخوذة؟',
      'battery': 'البطارية',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Getters for easy access
  String get appName => translate('app_name');
  String get appTitle => translate('app_title');

  // Auth
  String get login => translate('login');
  String get register => translate('register');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirm_password');
  String get name => translate('name');
  String get phone => translate('phone');
  String get idNumber => translate('id_number');
  String get vehicleType => translate('vehicle_type');
  String get logout => translate('logout');
  String get signOut => translate('sign_out');
  String get forgotPassword => translate('forgot_password');
  String get resetPassword => translate('reset_password');
  String get resetPasswordTitle => translate('reset_password_title');
  String get resetPasswordDescription =>
      translate('reset_password_description');
  String get sendResetLink => translate('send_reset_link');
  String get resetLinkSent => translate('reset_link_sent');
  String get enterEmail => translate('enter_email');

  // Navigation
  String get home => translate('home');
  String get main => translate('main');
  String get settings => translate('settings');
  String get myAccount => translate('my_account');

  // Profile
  String get profile => translate('profile');
  String get driverInfo => translate('driver_info');
  String get safetyRecord => translate('safety_record');
  String get totalTrips => translate('total_trips');
  String get safetyAlerts => translate('safety_alerts');
  String get safeTrips => translate('safe_trips');
  String get lastTrip => translate('last_trip');
  String get driverRating => translate('driver_rating');
  String get status => translate('status');
  String get active => translate('active');
  String get inactive => translate('inactive');
  String get noTrips => translate('no_trips');

  // Helmet
  String get helmet => translate('helmet');
  String get helmetStatus => translate('helmet_status');
  String get connected => translate('connected');
  String get disconnected => translate('disconnected');
  String get batteryLevel => translate('battery_level');
  String get lastConnection => translate('last_connection');
  String get reconnectHelmet => translate('reconnect_helmet');
  String get now => translate('now');
  String get notAvailable => translate('not_available');

  // Settings
  String get userSettings => translate('user_settings');
  String get account => translate('account');
  String get profileSettings => translate('profile_settings');
  String get changePassword => translate('change_password');
  String get notifications => translate('notifications');
  String get enableNotifications => translate('enable_notifications');
  String get accidentAlerts => translate('accident_alerts');
  String get speedAlerts => translate('speed_alerts');
  String get batteryAlerts => translate('battery_alerts');
  String get connection => translate('connection');
  String get bluetooth => translate('bluetooth');
  String get gps => translate('gps');
  String get privacySecurity => translate('privacy_security');
  String get locationSharing => translate('location_sharing');
  String get accountProtection => translate('account_protection');
  String get language => translate('language');
  String get app => translate('app');
  String get aboutApp => translate('about_app');
  String get privacyPolicy => translate('privacy_policy');
  String get updates => translate('updates');

  // Privacy
  String get editData => translate('edit_data');
  String get enableLocationTracking => translate('enable_location_tracking');
  String get passwordProtection => translate('password_protection');

  // Sensor Data
  String get heartRate => translate('heart_rate');
  String get temperature => translate('temperature');
  String get humidity => translate('humidity');
  String get location => translate('location');
  String get speed => translate('speed');
  String get shockDetected => translate('shock_detected');
  String get fallDetected => translate('fall_detected');
  String get bloodPressure => translate('blood_pressure');
  String get heartRateMeasurement => translate('heart_rate_measurement');
  String get temperatureMeasurement => translate('temperature_measurement');
  String get bluetoothConnection => translate('bluetooth_connection');
  String get emergencyCall => translate('emergency_call');
  String get driver => translate('driver');
  String get sosSent => translate('sos_sent');

  // Common
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get ok => translate('ok');
  String get yes => translate('yes');
  String get no => translate('no');
  String get back => translate('back');
  String get next => translate('next');
  String get done => translate('done');
  String get loading => translate('loading');
  String get error => translate('error');
  String get success => translate('success');
  String get unknown => translate('unknown');
  String get notSpecified => translate('not_specified');

  // Admin
  String get adminWelcome => translate('admin_welcome');
  String get adminSettings => translate('admin_settings');
  String get drivers => translate('drivers');
  String get reports => translate('reports');
  String get reportsTab => translate('reports_tab');
  String get alerts => translate('alerts');
  String get recentReports => translate('recent_reports');
  String get todayReport => translate('today_report');
  String get viewAll => translate('view_all');
  String get viewReport => translate('view_report');
  String get detailsManagement => translate('details_management');
  String get controlPanel => translate('control_panel');
  String get notificationsTab => translate('notifications_tab');
  String get noReports => translate('no_reports');
  String get noNotifications => translate('no_notifications');
  String get organizationName => translate('organization_name');
  String get smartSafetyOrganization => translate('smart_safety_organization');
  String get accountType => translate('account_type');
  String get systemAdmin => translate('system_admin');
  String get accountStatus => translate('account_status');
  String get emergencyAlerts => translate('emergency_alerts');
  String get fallAlerts => translate('fall_alerts');
  String get vitalSignsAlerts => translate('vital_signs_alerts');
  String get trackingMonitoring => translate('tracking_monitoring');
  String get enableLiveTracking => translate('enable_live_tracking');
  String get routeHistory => translate('route_history');
  String get trackingDataRetention => translate('tracking_data_retention');
  String get reportsAnalytics => translate('reports_analytics');
  String get performanceReports => translate('performance_reports');
  String get exportReports => translate('export_reports');
  String get incidentLog => translate('incident_log');
  String get accountManagement => translate('account_management');
  String get manageDrivers => translate('manage_drivers');
  String get manageSmartHelmets => translate('manage_smart_helmets');
  String get permissionsAccess => translate('permissions_access');
  String get dashboard => translate('dashboard');
  String get safe => translate('safe');
  String get safetyStatus => translate('safety_status');

  // Bluetooth
  String get bluetoothDisabled => translate('bluetooth_disabled');
  String get enableBluetoothMessage => translate('enable_bluetooth_message');
  String get enableBluetooth => translate('enable_bluetooth');
  String get scanningDevices => translate('scanning_devices');
  String get scanningHint => translate('scanning_hint');
  String get tips => translate('tips');
  String get tip1 => translate('tip1');
  String get tip2 => translate('tip2');
  String get tip3 => translate('tip3');
  String get noDevicesFound => translate('no_devices_found');
  String get noDevicesHint => translate('no_devices_hint');
  String get scanAgain => translate('scan_again');
  String get smartHelmet => translate('smart_helmet');
  String get otherDevices => translate('other_devices');
  String get unknownDevice => translate('unknown_device');
  String get connect => translate('connect');
  String connectingTo(String deviceName) =>
      '${translate('connecting_to')} $deviceName';
  String get connectionSuccess => translate('connection_success');
  String get connectionFailed => translate('connection_failed');
  String get disconnect => translate('disconnect');
  String get disconnectHelmet => translate('disconnect_helmet');
  String get disconnectConfirm => translate('disconnect_confirm');
  String get battery => translate('battery');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
