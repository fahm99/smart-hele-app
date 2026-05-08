import 'dart:math' as math;
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
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    int _toInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String)
        return int.tryParse(v) ?? (double.tryParse(v)?.toInt() ?? 0);
      return 0;
    }

    bool _toBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is num) return v != 0;
      if (v is String) {
        final lower = v.toLowerCase();
        return lower == 'true' || lower == '1';
      }
      return false;
    }

    try {
      return SensorDataModel(
        userId: userId,
        deviceId: json['device_id'] as String?,
        heartRate: _toInt(json['heart'] ?? json['heart_rate']),
        spo2: _toInt(json['spo2']),
        temperature: _toDouble(json['temp'] ?? json['temperature']),
        humidity: _toDouble(json['hum'] ?? json['humidity']),
        latitude: _toDouble(json['lat'] ?? json['latitude'] ?? json['lng']),
        longitude: _toDouble(json['lng'] ?? json['longitude'] ?? json['lat']),
        altitude: json['alt'] != null
            ? _toDouble(json['alt'])
            : (json['altitude'] != null ? _toDouble(json['altitude']) : null),
        speed: json['speed'] != null ? _toDouble(json['speed']) : null,
        accX: _toDouble(json['ax'] ?? json['acc_x']),
        accY: _toDouble(json['ay'] ?? json['acc_y']),
        accZ: _toDouble(json['az'] ?? json['acc_z']),
        gyroX: json['gx'] != null
            ? _toDouble(json['gx'])
            : (json['gyro_x'] != null ? _toDouble(json['gyro_x']) : null),
        gyroY: json['gy'] != null
            ? _toDouble(json['gy'])
            : (json['gyro_y'] != null ? _toDouble(json['gyro_y']) : null),
        gyroZ: json['gz'] != null
            ? _toDouble(json['gz'])
            : (json['gyro_z'] != null ? _toDouble(json['gyro_z']) : null),
        shockDetected: _toBool(json['shock'] ?? json['shock_detected']),
        shockValue: _toInt(json['shock_val'] ?? json['shock_value']),
        batteryLevel: _toInt(json['battery'] ?? json['battery_level']),
        fallDetected: _toBool(json['fall'] ?? json['fall_detected']),
        timestamp: DateTime.now(),
      );
    } catch (e) {
      // Fallback minimal model in case of parse errors
      return SensorDataModel(
        userId: userId,
        heartRate: 0,
        temperature: 0.0,
        humidity: 0.0,
        latitude: 0.0,
        longitude: 0.0,
        accX: 0.0,
        accY: 0.0,
        accZ: 0.0,
        shockDetected: false,
        shockValue: 0,
        batteryLevel: 0,
        timestamp: DateTime.now(),
      );
    }
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
    return math.sqrt(accX * accX + accY * accY + accZ * accZ);
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

// No custom sqrt extension needed; use dart:math sqrt above.
