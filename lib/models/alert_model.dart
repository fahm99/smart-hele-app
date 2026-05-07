import 'package:cloud_firestore/cloud_firestore.dart';

/// Model representing safety alerts
class AlertModel {
  final String? id;
  final String userId;
  final String userName;
  final String alertType;
  final String title;
  final String description;
  final double? latitude;
  final double? longitude;
  final bool isResolved;
  final DateTime timestamp;
  final DateTime? resolvedAt;
  final String? resolvedBy;

  AlertModel({
    this.id,
    required this.userId,
    required this.userName,
    required this.alertType,
    required this.title,
    required this.description,
    this.latitude,
    this.longitude,
    this.isResolved = false,
    required this.timestamp,
    this.resolvedAt,
    this.resolvedBy,
  });

  /// Create from Firestore document
  factory AlertModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AlertModel(
      id: doc.id,
      userId: data['user_id'] ?? '',
      userName: data['user_name'] ?? '',
      alertType: data['alert_type'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      isResolved: data['is_resolved'] ?? false,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      resolvedAt: data['resolved_at'] != null
          ? (data['resolved_at'] as Timestamp).toDate()
          : null,
      resolvedBy: data['resolved_by'],
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'user_id': userId,
      'user_name': userName,
      'alert_type': alertType,
      'title': title,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'is_resolved': isResolved,
      'timestamp': Timestamp.fromDate(timestamp),
      'resolved_at': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'resolved_by': resolvedBy,
    };
  }

  /// Get icon based on alert type
  String get icon {
    switch (alertType) {
      case 'fall':
        return '⚠️';
      case 'heart_rate':
        return '❤️';
      case 'temperature':
        return '🌡️';
      case 'shock':
        return '💥';
      case 'battery':
        return '🔋';
      case 'sos':
        return '🆘';
      default:
        return '⚡';
    }
  }

  /// Get color based on alert type
  int get colorValue {
    switch (alertType) {
      case 'fall':
      case 'sos':
        return 0xFFf44336; // Red
      case 'heart_rate':
        return 0xFFff9800; // Orange
      case 'temperature':
        return 0xFF2196F3; // Blue
      case 'shock':
        return 0xFF9c27b0; // Purple
      case 'battery':
        return 0xFFffeb3b; // Yellow
      default:
        return 0xFF757575; // Grey
    }
  }

  /// Create a copy with updated fields
  AlertModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? alertType,
    String? title,
    String? description,
    double? latitude,
    double? longitude,
    bool? isResolved,
    DateTime? timestamp,
    DateTime? resolvedAt,
    String? resolvedBy,
  }) {
    return AlertModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      alertType: alertType ?? this.alertType,
      title: title ?? this.title,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isResolved: isResolved ?? this.isResolved,
      timestamp: timestamp ?? this.timestamp,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
    );
  }
}
