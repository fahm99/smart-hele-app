import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../models/alert_model.dart';
import '../models/device_model.dart';
import '../models/report_model.dart';
import '../models/sensor_data_model.dart';
import '../models/user_model.dart';

/// Service for handling Firebase operations
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== User Operations ====================

  /// Create a new user
  Future<void> createUser(UserModel user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.id)
        .set(user.toFirestore());
  }

  /// Get user by ID
  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .get();

    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  /// Update user
  Future<void> updateUser(UserModel user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.id)
        .update(user.toFirestore());
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .delete();
  }

  /// Get all drivers
  Future<List<UserModel>> getAllDrivers() async {
    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .where('userType', isEqualTo: AppConstants.userTypeDriver)
        .get();

    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  /// Get all admins
  Future<List<UserModel>> getAllAdmins() async {
    final snapshot = await _firestore
        .collection(AppConstants.usersCollection)
        .where('userType', isEqualTo: AppConstants.userTypeAdmin)
        .get();

    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  /// Get all users
  Future<List<UserModel>> getAllUsers() async {
    final snapshot =
        await _firestore.collection(AppConstants.usersCollection).get();

    return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
  }

  // ==================== Sensor Data Operations ====================

  /// Save sensor data
  Future<void> saveSensorData(SensorDataModel data) async {
    await _firestore
        .collection(AppConstants.sensorDataCollection)
        .add(data.toFirestore());
  }

  /// Get sensor data for a user
  Future<List<SensorDataModel>> getSensorData(String userId,
      {int limit = 100}) async {
    final snapshot = await _firestore
        .collection(AppConstants.sensorDataCollection)
        .where('user_id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => SensorDataModel.fromFirestore(doc))
        .toList();
  }

  /// Get latest sensor data for a user
  Future<SensorDataModel?> getLatestSensorData(String userId) async {
    final snapshot = await _firestore
        .collection(AppConstants.sensorDataCollection)
        .where('user_id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return SensorDataModel.fromFirestore(snapshot.docs.first);
    }
    return null;
  }

  // ==================== Alert Operations ====================

  /// Create a new alert
  Future<void> createAlert(AlertModel alert) async {
    await _firestore
        .collection(AppConstants.alertsCollection)
        .add(alert.toFirestore());
  }

  /// Get alerts for a user
  Future<List<AlertModel>> getAlerts(String userId, {int limit = 50}) async {
    final snapshot = await _firestore
        .collection(AppConstants.alertsCollection)
        .where('user_id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => AlertModel.fromFirestore(doc)).toList();
  }

  /// Get all alerts (for admin)
  Future<List<AlertModel>> getAllAlerts({int limit = 100}) async {
    final snapshot = await _firestore
        .collection(AppConstants.alertsCollection)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => AlertModel.fromFirestore(doc)).toList();
  }

  /// Get unresolved alerts
  Future<List<AlertModel>> getUnresolvedAlerts(String? userId) async {
    Query query = _firestore
        .collection(AppConstants.alertsCollection)
        .where('is_resolved', isEqualTo: false)
        .orderBy('timestamp', descending: true);

    if (userId != null) {
      query = query.where('user_id', isEqualTo: userId);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => AlertModel.fromFirestore(doc)).toList();
  }

  /// Resolve an alert
  Future<void> resolveAlert(String alertId, String resolvedBy) async {
    await _firestore
        .collection(AppConstants.alertsCollection)
        .doc(alertId)
        .update({
      'is_resolved': true,
      'resolved_at': Timestamp.fromDate(DateTime.now()),
      'resolved_by': resolvedBy,
    });
  }

  // ==================== Device Operations ====================

  /// Register a device
  Future<void> registerDevice(DeviceModel device) async {
    await _firestore
        .collection(AppConstants.devicesCollection)
        .doc(device.id)
        .set(device.toFirestore());
  }

  /// Get device by ID
  Future<DeviceModel?> getDevice(String deviceId) async {
    final doc = await _firestore
        .collection(AppConstants.devicesCollection)
        .doc(deviceId)
        .get();

    if (doc.exists) {
      return DeviceModel.fromFirestore(doc);
    }
    return null;
  }

  /// Update device
  Future<void> updateDevice(DeviceModel device) async {
    await _firestore
        .collection(AppConstants.devicesCollection)
        .doc(device.id)
        .update(device.toFirestore());
  }

  /// Get devices for a user
  Future<List<DeviceModel>> getUserDevices(String userId) async {
    final snapshot = await _firestore
        .collection(AppConstants.devicesCollection)
        .where('user_id', isEqualTo: userId)
        .get();

    return snapshot.docs.map((doc) => DeviceModel.fromFirestore(doc)).toList();
  }

  // ==================== Dashboard Statistics ====================

  /// Get dashboard statistics
  Future<Map<String, int>> getDashboardStats() async {
    try {
      // Get total drivers
      final driversSnapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('userType', isEqualTo: AppConstants.userTypeDriver)
          .count()
          .get();

      // Get total alerts
      final alertsSnapshot = await _firestore
          .collection(AppConstants.alertsCollection)
          .count()
          .get();

      // Get unresolved alerts
      final unresolvedSnapshot = await _firestore
          .collection(AppConstants.alertsCollection)
          .where('is_resolved', isEqualTo: false)
          .count()
          .get();

      return {
        'drivers': driversSnapshot.count ?? 0,
        'alerts': unresolvedSnapshot.count ?? 0,
        'reports': alertsSnapshot.count ?? 0,
      };
    } catch (e) {
      debugPrint('Error getting dashboard stats: $e');
      return {
        'drivers': 0,
        'alerts': 0,
        'reports': 0,
      };
    }
  }

  /// Get today's report
  Future<Map<String, dynamic>> getTodayReport() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      // Get today's alerts
      final alertsSnapshot = await _firestore
          .collection(AppConstants.alertsCollection)
          .where('timestamp',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      return {
        'alerts': alertsSnapshot.docs.length,
        'timestamp': startOfDay,
      };
    } catch (e) {
      debugPrint('Error getting today report: $e');
      return {
        'alerts': 0,
        'timestamp': startOfDay,
      };
    }
  }

  // ==================== Stream Operations ====================

  /// Stream of alerts for a user
  Stream<List<AlertModel>> streamAlerts(String userId) {
    return _firestore
        .collection(AppConstants.alertsCollection)
        .where('user_id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AlertModel.fromFirestore(doc)).toList());
  }

  /// Stream of all alerts (for admin)
  Stream<List<AlertModel>> streamAllAlerts() {
    return _firestore
        .collection(AppConstants.alertsCollection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AlertModel.fromFirestore(doc)).toList());
  }

  /// Stream of sensor data for a user
  Stream<List<SensorDataModel>> streamSensorData(String userId,
      {int limit = 100}) {
    return _firestore
        .collection(AppConstants.sensorDataCollection)
        .where('user_id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SensorDataModel.fromFirestore(doc))
            .toList());
  }

  // ==================== Index Creation ====================

  /// Create necessary indexes (call this during app initialization)
  Future<void> createIndexes() async {
    // Indexes are created in Firebase Console or via Firebase CLI
    // This is a placeholder for any index-related setup
    debugPrint('Firebase indexes should be created in Firebase Console');
  }

  // ==================== Report Operations ====================

  /// Create a new report
  Future<String> createReport(ReportModel report) async {
    final docRef = await _firestore
        .collection(AppConstants.reportsCollection)
        .add(report.toFirestore());
    return docRef.id;
  }

  /// Get report by ID
  Future<ReportModel?> getReport(String reportId) async {
    final doc = await _firestore
        .collection(AppConstants.reportsCollection)
        .doc(reportId)
        .get();

    if (doc.exists) {
      return ReportModel.fromFirestore(doc);
    }
    return null;
  }

  /// Get all reports
  Future<List<ReportModel>> getAllReports({int limit = 100}) async {
    final snapshot = await _firestore
        .collection(AppConstants.reportsCollection)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList();
  }

  /// Get reports by user
  Future<List<ReportModel>> getReportsByUser(String userId,
      {int limit = 50}) async {
    final snapshot = await _firestore
        .collection(AppConstants.reportsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList();
  }

  /// Get pending reports
  Future<List<ReportModel>> getPendingReports({int limit = 50}) async {
    final snapshot = await _firestore
        .collection(AppConstants.reportsCollection)
        .where('status', isEqualTo: 'pending')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList();
  }

  /// Get reports by type
  Future<List<ReportModel>> getReportsByType(String reportType,
      {int limit = 50}) async {
    final snapshot = await _firestore
        .collection(AppConstants.reportsCollection)
        .where('reportType', isEqualTo: reportType)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => ReportModel.fromFirestore(doc)).toList();
  }

  /// Update report status
  Future<void> updateReportStatus(
    String reportId,
    String status, {
    String? resolvedBy,
    String? adminNotes,
  }) async {
    final updateData = <String, dynamic>{
      'status': status,
    };

    if (status == 'resolved') {
      updateData['resolvedAt'] = Timestamp.now();
      if (resolvedBy != null) {
        updateData['resolvedBy'] = resolvedBy;
      }
    }

    if (adminNotes != null) {
      updateData['adminNotes'] = adminNotes;
    }

    await _firestore
        .collection(AppConstants.reportsCollection)
        .doc(reportId)
        .update(updateData);
  }

  /// Delete report
  Future<void> deleteReport(String reportId) async {
    await _firestore
        .collection(AppConstants.reportsCollection)
        .doc(reportId)
        .delete();
  }

  /// Get reports count
  Future<int> getReportsCount() async {
    final snapshot = await _firestore
        .collection(AppConstants.reportsCollection)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  /// Get pending reports count
  Future<int> getPendingReportsCount() async {
    final snapshot = await _firestore
        .collection(AppConstants.reportsCollection)
        .where('status', isEqualTo: 'pending')
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}
