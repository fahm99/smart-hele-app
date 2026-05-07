import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing a smart helmet device
class DeviceModel {
  final String id;
  final String name;
  final String? userId;
  final String macAddress;
  final bool isConnected;
  final int batteryLevel;
  final DateTime? lastConnected;
  final DateTime createdAt;
  final Map<String, dynamic>? sensors;

  DeviceModel({
    required this.id,
    required this.name,
    this.userId,
    required this.macAddress,
    this.isConnected = false,
    this.batteryLevel = 100,
    this.lastConnected,
    required this.createdAt,
    this.sensors,
  });

  /// Create from Firestore document
  factory DeviceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeviceModel(
      id: doc.id,
      name: data['name'] ?? 'SSH-Helmet',
      userId: data['user_id'],
      macAddress: data['mac_address'] ?? '',
      isConnected: data['is_connected'] ?? false,
      batteryLevel: data['battery_level'] ?? 100,
      lastConnected: data['last_connected'] != null
          ? (data['last_connected'] as Timestamp).toDate()
          : null,
      createdAt: (data['created_at'] as Timestamp).toDate(),
      sensors: data['sensors'],
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'user_id': userId,
      'mac_address': macAddress,
      'is_connected': isConnected,
      'battery_level': batteryLevel,
      'last_connected': lastConnected != null ? Timestamp.fromDate(lastConnected!) : null,
      'created_at': Timestamp.fromDate(createdAt),
      'sensors': sensors,
    };
  }

  /// Create a copy with updated fields
  DeviceModel copyWith({
    String? id,
    String? name,
    String? userId,
    String? macAddress,
    bool? isConnected,
    int? batteryLevel,
    DateTime? lastConnected,
    DateTime? createdAt,
    Map<String, dynamic>? sensors,
  }) {
    return DeviceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      userId: userId ?? this.userId,
      macAddress: macAddress ?? this.macAddress,
      isConnected: isConnected ?? this.isConnected,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      lastConnected: lastConnected ?? this.lastConnected,
      createdAt: createdAt ?? this.createdAt,
      sensors: sensors ?? this.sensors,
    );
  }

  /// Check if battery is low
  bool get isBatteryLow => batteryLevel <= 20;

  /// Get connection status text
  String get connectionStatus => isConnected ? 'متصل' : 'غير متصل';

  /// Get formatted last connected time
  String get lastConnectedText {
    if (lastConnected == null) return 'لم يتصل بعد';
    final diff = DateTime.now().difference(lastConnected!);
    if (diff.inMinutes < 1) return 'منذ لحظات';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} ساعة';
    return 'منذ ${diff.inDays} يوم';
  }
}
