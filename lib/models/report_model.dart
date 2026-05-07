import 'package:cloud_firestore/cloud_firestore.dart';

/// Report model for user reports and incidents
class ReportModel {
  final String? id;
  final String userId;
  final String userName;
  final String userEmail;
  final String title;
  final String description;
  final String
      reportType; // 'accident', 'helmet_malfunction', 'emergency', 'other'
  final String status; // 'pending', 'in_progress', 'resolved'
  final double? latitude;
  final double? longitude;
  final DateTime timestamp;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final String? adminNotes;

  ReportModel({
    this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.title,
    required this.description,
    required this.reportType,
    this.status = 'pending',
    this.latitude,
    this.longitude,
    required this.timestamp,
    this.resolvedAt,
    this.resolvedBy,
    this.adminNotes,
  });

  /// Create from Firestore document
  factory ReportModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      reportType: data['reportType'] ?? 'other',
      status: data['status'] ?? 'pending',
      latitude: data['latitude']?.toDouble(),
      longitude: data['longitude']?.toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      resolvedAt: data['resolvedAt'] != null
          ? (data['resolvedAt'] as Timestamp).toDate()
          : null,
      resolvedBy: data['resolvedBy'],
      adminNotes: data['adminNotes'],
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'title': title,
      'description': description,
      'reportType': reportType,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': Timestamp.fromDate(timestamp),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'resolvedBy': resolvedBy,
      'adminNotes': adminNotes,
    };
  }

  /// Create a copy with updated fields
  ReportModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userEmail,
    String? title,
    String? description,
    String? reportType,
    String? status,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    DateTime? resolvedAt,
    String? resolvedBy,
    String? adminNotes,
  }) {
    return ReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userEmail: userEmail ?? this.userEmail,
      title: title ?? this.title,
      description: description ?? this.description,
      reportType: reportType ?? this.reportType,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      adminNotes: adminNotes ?? this.adminNotes,
    );
  }

  /// Get report type display name
  String getReportTypeDisplayName() {
    switch (reportType) {
      case 'accident':
        return 'حادث';
      case 'helmet_malfunction':
        return 'عطل في الخوذة';
      case 'emergency':
        return 'طوارئ';
      case 'other':
        return 'أخرى';
      default:
        return reportType;
    }
  }

  /// Get status display name
  String getStatusDisplayName() {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'in_progress':
        return 'قيد المعالجة';
      case 'resolved':
        return 'تم الحل';
      default:
        return status;
    }
  }

  /// Check if report is resolved
  bool get isResolved => status == 'resolved';

  /// Check if report is pending
  bool get isPending => status == 'pending';
}
