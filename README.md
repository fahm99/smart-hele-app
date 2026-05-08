# SSH - Smart Safety Helmet

![Flutter](https://img.shields.io/badge/Flutter-3.0.0+-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0.0+-0175C2?style=for-the-badge&logo=dart)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase)
![Google Maps](https://img.shields.io/badge/Google_Maps-4285F4?style=for-the-badge&logo=googlemaps)

[![GitHub license](https://img.shields.io/github/license/DrAlSartory/ssh_app)
[![GitHub stars](https://img.shields.io/github/stars/DrAlSartory/ssh_app?style=social)
[![GitHub forks](https://img.shields.io/github/forks/DrAlSartory/ssh_app?style=social)

---

## Smart Safety Helmet Application

A comprehensive Flutter-based mobile application designed to connect with smart safety helmets, providing real-time monitoring of worker vital signs, GPS tracking, fall detection, and emergency alerts.

---

## Features

| Feature | Description |
|---------|-------------|
| Real-time Monitoring | Live tracking of heart rate, temperature, humidity, and battery level |
| GPS Tracking | Accurate location tracking using NEO-6M GPS module |
| Fall Detection | MPU6050 accelerometer-based fall detection system |
| Shock Detection | SW420 vibration sensor for impact monitoring |
| Bluetooth LE | Seamless wireless connection to ESP32 helmet |
| Push Notifications | Firebase Cloud Messaging for instant alerts |
| Multi-language | English and Arabic language support |
| User Management | Secure authentication with Firebase Auth |
| Admin Dashboard | Comprehensive admin control panel |
| SOS Emergency | One-tap emergency alert system |

---

## Technologies

### Core Framework
- Flutter 3.0.0+
- Dart 3.0.0+

### Backend & Cloud
- Firebase Auth - User authentication
- Cloud Firestore - Real-time database
- Firebase Messaging - Push notifications

### Hardware Integration
- ESP32 - Main microcontroller
- NEO-6M - GPS module
- MAX30102 - Heart rate sensor
- DHT22 - Temperature & humidity
- MPU6050 - Accelerometer/Gyroscope
- SW420 - Shock/vibration sensor

### Maps & Location
- Google Maps Flutter

### Key Dependencies
```
flutter_blue_plus: ^1.32.4      # Bluetooth LE
google_maps_flutter: ^2.10.1  # Maps
firebase_auth: ^5.1.3          # Auth
cloud_firestore: ^5.2.1        # Database
firebase_messaging: ^15.1.3     # Notifications
go_router: ^15.1.2            # Navigation
provider: ^6.1.5             # State Management
permission_handler: ^11.3.1   # Permissions
```

---

## Supported Platforms

| Platform | Status | Minimum Version |
|----------|--------|----------------|
| Android | Supported | API 21+ (Android 5.0) |
| iOS | Coming Soon | iOS 12.0+ |
| Web | Coming Soon | Modern Browsers |

---

## Architecture

```
+-----------------------------------------------------------+
|                    PRESENTATION LAYER                     |
|  +-----------+  +-----------+  +-----------+                |
|  |  Screens  |  |  Widgets  |  |  Themes   |                |
|  +-----------+  +-----------+  +-----------+                |
+-----------------------------------------------------------+
|                      PROVIDER LAYER                         |
|  +-----------+  +-----------+  +-----------+                |
|  |AuthProvider|BluetoothPro|SensorDataPro|                |
|  +-----------+  +-----------+  +-----------+                |
+-----------------------------------------------------------+
|                      SERVICE LAYER                        |
|  +-----------+  +-----------+  +-----------+                |
|  | Bluetooth |  | Firebase |  |Notification|             |
|  +-----------+  +-----------+  +-----------+                |
+-----------------------------------------------------------+
|                       DATA LAYER                          |
|  +-----------+  +-----------+                              |
|  |  Models   |  | Constants |                              |
|  +-----------+  +-----------+                              |
+-----------------------------------------------------------+
```

---

## Getting Started

### Prerequisites

- Flutter SDK 3.0.0+
- Dart SDK 3.0.0+
- Android SDK 21+
- Node.js (for Firebase CLI)

### Installation

1. Clone the repository

```bash
git clone https://github.com/DrAlSartory/ssh_app.git
cd ssh_app
```

2. Install dependencies

```bash
flutter pub get
```

3. Configure Firebase

```bash
# Download google-services.json from Firebase Console
# Place it in: android/app/google-services.json
```

4. Run the app

```bash
flutter run
```

### Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release
```

---

## Project Structure

```
lib/
+--- core/
|    +--- constants/          # App constants
|    +--- localization/       # Multi-language support
|    +--- theme/             # App themes & colors
+--- models/                 # Data models
|    +--- alert_model.dart
|    +--- device_model.dart
|    +--- report_model.dart
|    +--- sensor_data_model.dart
|    +--- user_model.dart
+--- providers/              # State management
|    +--- auth_provider.dart
|    +--- bluetooth_provider.dart
|    +--- sensor_data_provider.dart
+--- routes/                 # Navigation routes
+--- screens/                # UI screens
|    +--- admin/             # Admin screens
|    +--- auth/              # Authentication
|    +--- bluetooth/         # Bluetooth devices
|    +--- home/              # Main dashboard
|    +--- onboarding/        # First-time setup
|    +--- profile/           # User profile
|    +--- settings/          # App settings
+--- services/               # Business logic
|    +--- bluetooth_service.dart
|    +--- firebase_service.dart
|    +--- notification_service.dart
+--- widgets/                # Reusable widgets
+--- main.dart               # App entry point
```

---

## Bluetooth Protocol

### ESP32 Service UUID

```
Service UUID:        4fafc201-1fb5-459e-8fcc-c5c9c331914b
Characteristic UUID: beb5483e-36e1-4688-b7f5-ea07361b26a8
```

### Data Format (JSON)

```json
{
  "heart_rate": 72,
  "temperature": 36.5,
  "humidity": 45.2,
  "lat": 24.713552,
  "lng": 46.675295,
  "acc_x": 0.02,
  "acc_y": 0.98,
  "acc_z": 0.15,
  "shock": false,
  "fall": false,
  "battery": 85
}
```

---

## Firebase Services

### Collections

- `users` - User accounts
- `devices` - Paired helmets
- `sensor_data` - Historical sensor readings
- `alerts` - Safety alerts
- `reports` - Emergency reports

---

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

### Don't forget to star the repository if you find it useful!

**Made with love for worker safety**