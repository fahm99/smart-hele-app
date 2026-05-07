import 'dart:async';

import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../models/alert_model.dart';
import '../models/sensor_data_model.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../services/bluetooth_service.dart';

/// Provider for managing sensor data and alerts
class SensorDataProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final NotificationService _notificationService = NotificationService();
  final BluetoothService _bluetoothService = BluetoothService();

  // Current sensor data
  SensorDataModel? _currentData;
  
  // Historical data
  List<SensorDataModel> _historicalData = [];
  
  // Alerts
  List<AlertModel> _alerts = [];
  List<AlertModel> _unresolvedAlerts = [];
  
  // Statistics
  int _totalAlerts = 0;
  int _totalReports = 0;
  
  // Loading states
  bool _isLoading = false;
  bool _isLoadingHistory = false;
  String? _error;

  // Fall Detection State
  bool _isFallPending = false;
  int _fallCountdown = 5;
  Timer? _fallTimer;

  // Track last alert time to avoid spamming
  DateTime? _lastNotificationTime;

  // Stream subscription
  StreamSubscription<SensorDataModel>? _dataSubscription;
  Timer? _dataSaveTimer;

  // Getters
  SensorDataModel? get currentData => _currentData;
  List<SensorDataModel> get historicalData => _historicalData;
  List<AlertModel> get alerts => _alerts;
  List<AlertModel> get unresolvedAlerts => _unresolvedAlerts;
  List<AlertModel> get recentAlerts => _alerts.take(5).toList();
  int get totalAlerts => _totalAlerts;
  int get totalReports => _totalReports;
  bool get isLoading => _isLoading;
  bool get isLoadingHistory => _isLoadingHistory;
  String? get error => _error;
  bool get isFallPending => _isFallPending;
  int get fallCountdown => _fallCountdown;

  /// Initialize with data stream from Bluetooth
  void initializeStream(Stream<SensorDataModel> dataStream, String userId) {
    _dataSubscription?.cancel();
    _dataSubscription = dataStream.listen((data) {
      _currentData = data;
      _checkForAlerts(data, userId);
      notifyListeners();
    });

    // Save data to Firestore every 30 seconds
    _dataSaveTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_currentData != null) {
        _saveSensorData(_currentData!);
      }
    });
  }

  /// Check for alert conditions
  void _checkForAlerts(SensorDataModel data, String userId) async {
    final alerts = <AlertModel>[];
    bool shouldTriggerHelmet = false;

    // Check heart rate
    if (!data.isHeartRateNormal) {
      alerts.add(AlertModel(
        userId: userId,
        userName: 'Driver',
        alertType: AppConstants.alertTypeHeartRate,
        title: 'Heart Rate Alert',
        description: 'Abnormal heart rate: ${data.heartRate} bpm',
        latitude: data.latitude,
        longitude: data.longitude,
        timestamp: DateTime.now(),
      ));
      shouldTriggerHelmet = true;
    }

    // Check temperature
    if (!data.isTemperatureNormal) {
      alerts.add(AlertModel(
        userId: userId,
        userName: 'Driver',
        alertType: AppConstants.alertTypeTemperature,
        title: 'Temperature Alert',
        description: 'Abnormal temperature: ${data.temperature}°C',
        latitude: data.latitude,
        longitude: data.longitude,
        timestamp: DateTime.now(),
      ));
      shouldTriggerHelmet = true;
    }

    // Check shock
    if (data.shockDetected) {
      alerts.add(AlertModel(
        userId: userId,
        userName: 'Driver',
        alertType: AppConstants.alertTypeShock,
        title: 'Shock Alert',
        description: 'Strong impact detected!',
        latitude: data.latitude,
        longitude: data.longitude,
        timestamp: DateTime.now(),
      ));
      shouldTriggerHelmet = true;
    }

    // Check fall
    if (data.fallDetected && !_isFallPending) {
      _startFallCountdown(userId);
    }

    // Check battery
    if (data.isBatteryLow) {
      alerts.add(AlertModel(
        userId: userId,
        userName: 'Driver',
        alertType: AppConstants.alertTypeBattery,
        title: 'Battery Alert',
        description: 'Helmet battery low: ${data.batteryLevel}%',
        timestamp: DateTime.now(),
      ));
    }

    if (alerts.isNotEmpty) {
      // Save alerts to Firestore
      for (final alert in alerts) {
        await _firebaseService.createAlert(alert);
      }

      // Show local notification (rate limited to once every 10 seconds)
      final now = DateTime.now();
      if (_lastNotificationTime == null || 
          now.difference(_lastNotificationTime!) > const Duration(seconds: 10)) {
        
        await _notificationService.showSimpleNotification(
          title: alerts.first.title,
          body: alerts.first.description,
        );
        _lastNotificationTime = now;
      }

      // Trigger helmet feedback
      if (shouldTriggerHelmet && _bluetoothService.isConnected) {
        await _bluetoothService.triggerHelmetAlert(durationMs: 2000);
      }

      _alerts.insertAll(0, alerts);
      _unresolvedAlerts.addAll(alerts);
      notifyListeners();
    }
  }

  /// Start 5-second fall confirmation countdown
  void _startFallCountdown(String userId) {
    _isFallPending = true;
    _fallCountdown = 5;
    notifyListeners();

    // Trigger long buzzer on helmet for 5 seconds
    if (_bluetoothService.isConnected) {
      _bluetoothService.triggerHelmetAlert(durationMs: 5000);
    }

    _fallTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_fallCountdown > 1) {
        _fallCountdown--;
        notifyListeners();
      } else {
        _fallTimer?.cancel();
        _isFallPending = false;
        confirmFallAlert(userId);
      }
    });
  }

  /// Cancel a pending fall alert (user responded they are OK)
  void cancelFallAlert() {
    _fallTimer?.cancel();
    _isFallPending = false;
    _fallCountdown = 5;
    
    // Stop helmet buzzer (by sending a short duration or dedicated stop command)
    if (_bluetoothService.isConnected) {
      _bluetoothService.triggerHelmetAlert(durationMs: 100); 
    }
    
    notifyListeners();
  }

  /// Confirm a fall alert (timer expired or user manually triggered)
  void confirmFallAlert(String userId) async {
    final alert = AlertModel(
      userId: userId,
      userName: 'Driver',
      alertType: AppConstants.alertTypeFall,
      title: 'CRITICAL: Fall Confirmed',
      description: 'Worker fall confirmed! No response after 5 seconds.',
      latitude: _currentData?.latitude,
      longitude: _currentData?.longitude,
      timestamp: DateTime.now(),
    );

    // Save to Firestore
    await _firebaseService.createAlert(alert);
    
    // Notify admin/local
    await _notificationService.showSimpleNotification(
      title: alert.title,
      body: alert.description,
    );

    // Trigger SOS protocol
    await triggerSOS(userId, 'Driver', 
        lat: _currentData?.latitude, 
        lng: _currentData?.longitude);

    _alerts.insert(0, alert);
    _unresolvedAlerts.add(alert);
    notifyListeners();
  }

  /// Save sensor data to Firestore
  Future<void> _saveSensorData(SensorDataModel data) async {
    try {
      await _firebaseService.saveSensorData(data);
    } catch (e) {
      debugPrint('Error saving sensor data: $e');
    }
  }

  /// Load historical sensor data
  Future<void> loadHistoricalData(String userId, {int limit = 100}) async {
    _isLoadingHistory = true;
    notifyListeners();

    try {
      _historicalData = await _firebaseService.getSensorData(userId, limit: limit);
    } catch (e) {
      _error = e.toString();
    }

    _isLoadingHistory = false;
    notifyListeners();
  }

  /// Load alerts for a user
  Future<void> loadAlerts(String userId, {bool unresolvedOnly = false}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (unresolvedOnly) {
        _unresolvedAlerts = await _firebaseService.getUnresolvedAlerts(userId);
      } else {
        _alerts = await _firebaseService.getAlerts(userId);
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Load all alerts (for admin)
  Future<void> loadAllAlerts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _alerts = await _firebaseService.getAllAlerts();
      _unresolvedAlerts = _alerts.where((a) => !a.isResolved).toList();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Resolve an alert
  Future<bool> resolveAlert(String alertId, String resolvedBy) async {
    try {
      await _firebaseService.resolveAlert(alertId, resolvedBy);
      
      // Update local lists
      final alertIndex = _alerts.indexWhere((a) => a.id == alertId);
      if (alertIndex != -1) {
        _alerts[alertIndex] = _alerts[alertIndex].copyWith(
          isResolved: true,
          resolvedAt: DateTime.now(),
          resolvedBy: resolvedBy,
        );
      }
      
      _unresolvedAlerts.removeWhere((a) => a.id == alertId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  /// Load dashboard statistics (for admin)
  Future<void> loadDashboardStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final stats = await _firebaseService.getDashboardStats();
      _totalAlerts = stats['alerts'] ?? 0;
      _totalReports = stats['reports'] ?? 0;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Trigger SOS alert
  Future<void> triggerSOS(String userId, String userName, 
      {double? lat, double? lng}) async {
    final alert = AlertModel(
      userId: userId,
      userName: userName,
      alertType: AppConstants.alertTypeSOS,
      title: 'استغاثة طوارئ',
      description: 'تم الضغط على زر الاستغاثة',
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now(),
    );

    try {
      await _firebaseService.createAlert(alert);
      
      // Trigger notification
      await _notificationService.showSimpleNotification(
        title: alert.title,
        body: alert.description,
      );

      // Trigger helmet alert
      if (_bluetoothService.isConnected) {
        await _bluetoothService.triggerHelmetAlert(durationMs: 5000); // 5s for SOS
      }

      _alerts.insert(0, alert);
      _unresolvedAlerts.add(alert);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  /// Clear current data
  void clearData() {
    _currentData = null;
    _dataSubscription?.cancel();
    _dataSaveTimer?.cancel();
    notifyListeners();
  }

  /// Test fall detection (manual trigger)
  void testFallDetection(String userId) {
    if (!_isFallPending) {
      _startFallCountdown(userId);
    }
  }

  @override
  void dispose() {
    _dataSubscription?.cancel();
    _dataSaveTimer?.cancel();
    _fallTimer?.cancel();
    super.dispose();
  }
}
