/// App-wide constants for SSH Smart Safety Helmet Application
class AppConstants {
  AppConstants._();

  // App Information
  static const String appName = 'SSH - Smart Safety Helmet';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String devicesCollection = 'devices';
  static const String sensorDataCollection = 'sensor_data';
  static const String alertsCollection = 'alerts';
  static const String locationsCollection = 'locations';
  static const String reportsCollection = 'reports';

  // Bluetooth Constants
  static const String esp32ServiceUuid = '4fafc201-1fb5-459e-8fcc-c5c9c331914b';
  static const String esp32CharacteristicUuid =
      'beb5483e-36e1-4688-b7f5-ea07361b26a8';
  static const String esp32DeviceName = 'SSH-Helmet';
  static const Duration bluetoothScanDuration = Duration(seconds: 10);
  static const Duration bluetoothReconnectDelay = Duration(seconds: 5);

  // Sensor Thresholds
  static const int minHeartRate = 60;
  static const int maxHeartRate = 100;
  static const double maxTemperature = 40.0;
  static const double minTemperature = 10.0;
  static const int lowBatteryThreshold = 20;
  static const double shockThreshold = 2.0;

  // GPS Constants
  static const double defaultLatitude = 24.7136;
  static const double defaultLongitude = 46.6753;
  static const double defaultZoom = 15.0;

  // Map configuration
  // Set your Google Maps API key here for map support in the app.
  // Leave empty to disable GoogleMap (safe fallback will be used).
  static const String googleMapsApiKey = '';

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 4.0;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Cache Keys
  static const String languageKey = 'app_language';
  static const String userKey = 'user_data';
  static const String deviceKey = 'device_data';

  // User Types
  static const String userTypeDriver = 'driver';
  static const String userTypeAdmin = 'admin';

  // Alert Types
  static const String alertTypeFall = 'fall';
  static const String alertTypeHeartRate = 'heart_rate';
  static const String alertTypeTemperature = 'temperature';
  static const String alertTypeShock = 'shock';
  static const String alertTypeBattery = 'battery';
  static const String alertTypeSOS = 'sos';
}
