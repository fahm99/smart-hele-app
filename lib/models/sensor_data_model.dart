import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing sensor data from the smart helmet
class SensorDataModel {
  final String? id;
  final String userId;
  final String? deviceId;

  // Heart Rate (MAX30102)
  final int heartRate;
  final int? spo2;

  // Temperature & Humidity (DHT22)
  final double temperature;
  final double humidity;

  // GPS (NEO-6M)
  final double latitude;
  final double longitude;
  final double? altitude;
  final double? speed;

  // Motion (MPU6050)
  final double accX;
  final double accY;
  final double accZ;
  final double? gyroX;
  final double? gyroY;
  final double? gyroZ;

  // Shock (SW420)
  final bool shockDetected;
  final int shockValue;

  // Battery
  final int batteryLevel;

  // Fall detection
  final bool fallDetected;

  // Timestamp
  final DateTime timestamp;

  SensorDataModel({
    this.id,
    required this.userId,
    this.deviceId,
    required this.heartRate,
    this.spo2,
    required this.temperature,
    required this.humidity,
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
    required this.accX,
    required this.accY,
    required this.accZ,
    this.gyroX,
    this.gyroY,
    this.gyroZ,
    required this.shockDetected,
    required this.shockValue,
    required this.batteryLevel,
    this.fallDetected = false,
    required this.timestamp,
  });

  /// Create from JSON (from ESP32 via Bluetooth)
  factory SensorDataModel.fromJson(Map<String, dynamic> json, String userId) {
    return SensorDataModel(
      userId: userId,
      deviceId: json['device_id'] as String?,
      // Heart Rate - يدعم كلا التنسيقين
      heartRate: json['heart'] ?? json['heart_rate'] ?? 0,
      spo2: json['spo2'],
      // Temperature & Humidity - يدعم كلا التنسيقين
      temperature: (json['temp'] ?? json['temperature'] ?? 0.0).toDouble(),
      humidity: (json['hum'] ?? json['humidity'] ?? 0.0).toDouble(),
      // GPS
      latitude: (json['lat'] ?? 0.0).toDouble(),
      longitude: (json['lng'] ?? 0.0).toDouble(),
      altitude: json['alt'] ?? json['altitude']?.toDouble(),
      speed: json['speed']?.toDouble(),
      // Accelerometer - يدعم كلا التنسيقين
      accX: (json['ax'] ?? json['acc_x'] ?? 0.0).toDouble(),
      accY: (json['ay'] ?? json['acc_y'] ?? 0.0).toDouble(),
      accZ: (json['az'] ?? json['acc_z'] ?? 0.0).toDouble(),
      // Gyroscope - يدعم كلا التنسيقين
      gyroX: json['gx'] ?? json['gyro_x']?.toDouble(),
      gyroY: json['gy'] ?? json['gyro_y']?.toDouble(),
      gyroZ: json['gz'] ?? json['gyro_z']?.toDouble(),
      // Shock - يدعم عدة تنسيقات
      shockDetected: json['shock'] == true ||
          json['shock'] == 1 ||
          json['shock_detected'] == true,
      shockValue: json['shock_val'] ?? json['shock_value'] ?? 0,
      // Battery
      batteryLevel: json['battery'] ?? 0,
      // Fall - يدعم كلا التنسيقين
      fallDetected: json['fall'] == true || json['fall_detected'] == true,
      timestamp: DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'device_id': deviceId,
      'heart_rate': heartRate,
      'spo2': spo2,
      'temperature': temperature,
      'humidity': humidity,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'speed': speed,
      'acc_x': accX,
      'acc_y': accY,
      'acc_z': accZ,
      'gyro_x': gyroX,
      'gyro_y': gyroY,
      'gyro_z': gyroZ,
      'shock_detected': shockDetected,
      'shock_value': shockValue,
      'battery_level': batteryLevel,
      'fall_detected': fallDetected,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Create from Firestore document
  factory SensorDataModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SensorDataModel(
      id: doc.id,
      userId: data['user_id'] ?? '',
      deviceId: data['device_id'],
      heartRate: data['heart_rate'] ?? 0,
      spo2: data['spo2'],
      temperature: (data['temperature'] ?? 0.0).toDouble(),
      humidity: (data['humidity'] ?? 0.0).toDouble(),
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      altitude: data['altitude']?.toDouble(),
      speed: data['speed']?.toDouble(),
      accX: (data['acc_x'] ?? 0.0).toDouble(),
      accY: (data['acc_y'] ?? 0.0).toDouble(),
      accZ: (data['acc_z'] ?? 0.0).toDouble(),
      gyroX: data['gyro_x']?.toDouble(),
      gyroY: data['gyro_y']?.toDouble(),
      gyroZ: data['gyro_z']?.toDouble(),
      shockDetected: data['shock_detected'] ?? false,
      shockValue: data['shock_value'] ?? 0,
      batteryLevel: data['battery_level'] ?? 0,
      fallDetected: data['fall_detected'] ?? false,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'device_id': deviceId,
      'heart_rate': heartRate,
      'spo2': spo2,
      'temperature': temperature,
      'humidity': humidity,
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'speed': speed,
      'acc_x': accX,
      'acc_y': accY,
      'acc_z': accZ,
      'gyro_x': gyroX,
      'gyro_y': gyroY,
      'gyro_z': gyroZ,
      'shock_detected': shockDetected,
      'shock_value': shockValue,
      'battery_level': batteryLevel,
      'fall_detected': fallDetected,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// Get acceleration magnitude
  double get accelerationMagnitude {
    return (accX * accX + accY * accY + accZ * accZ).sqrt;
  }

  /// Check if heart rate is in normal range
  bool get isHeartRateNormal => heartRate >= 60 && heartRate <= 100;

  /// Check if temperature is in normal range
  bool get isTemperatureNormal => temperature >= 10 && temperature <= 40;

  /// Check if battery is low
  bool get isBatteryLow => batteryLevel <= 20;

  /// Check if any alert condition is met
  bool get hasAlert {
    return !isHeartRateNormal ||
        !isTemperatureNormal ||
        isBatteryLow ||
        shockDetected ||
        fallDetected;
  }
}

extension on double {
  double get sqrt => this <= 0 ? 0 : _sqrt(this);
  double _sqrt(double x) {
    double z = x;
    double root = 0.0;
    while (z * z <= x) {
      root = z;
      z += 0.001;
    }
    return root;
  }
}
