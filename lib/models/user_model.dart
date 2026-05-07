import 'package:cloud_firestore/cloud_firestore.dart';

/// User model representing both drivers and admins
class UserModel {
  final String id;
  final String email;
  final String name;
  final String userType; // 'driver' or 'admin'
  final String? phone;
  final String? idNumber;
  final String? vehicleType;
  final String? avatarUrl;
  final bool isActive;
  final double rating;
  final int totalTrips;
  final int safetyAlerts;
  final int safeTrips;
  final DateTime? lastTripDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.userType,
    this.phone,
    this.idNumber,
    this.vehicleType,
    this.avatarUrl,
    this.isActive = true,
    this.rating = 0.0,
    this.totalTrips = 0,
    this.safetyAlerts = 0,
    this.safeTrips = 0,
    this.lastTripDate,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      userType: data['userType'] ?? 'driver',
      phone: data['phone'],
      idNumber: data['idNumber'],
      vehicleType: data['vehicleType'],
      avatarUrl: data['avatarUrl'],
      isActive: data['isActive'] ?? true,
      rating: (data['rating'] ?? 0.0).toDouble(),
      totalTrips: data['totalTrips'] ?? 0,
      safetyAlerts: data['safetyAlerts'] ?? 0,
      safeTrips: data['safeTrips'] ?? 0,
      lastTripDate: data['lastTripDate'] != null
          ? (data['lastTripDate'] as Timestamp).toDate()
          : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'userType': userType,
      'phone': phone,
      'idNumber': idNumber,
      'vehicleType': vehicleType,
      'avatarUrl': avatarUrl,
      'isActive': isActive,
      'rating': rating,
      'totalTrips': totalTrips,
      'safetyAlerts': safetyAlerts,
      'safeTrips': safeTrips,
      'lastTripDate': lastTripDate != null ? Timestamp.fromDate(lastTripDate!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? userType,
    String? phone,
    String? idNumber,
    String? vehicleType,
    String? avatarUrl,
    bool? isActive,
    double? rating,
    int? totalTrips,
    int? safetyAlerts,
    int? safeTrips,
    DateTime? lastTripDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      userType: userType ?? this.userType,
      phone: phone ?? this.phone,
      idNumber: idNumber ?? this.idNumber,
      vehicleType: vehicleType ?? this.vehicleType,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isActive: isActive ?? this.isActive,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      safetyAlerts: safetyAlerts ?? this.safetyAlerts,
      safeTrips: safeTrips ?? this.safeTrips,
      lastTripDate: lastTripDate ?? this.lastTripDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if user is admin
  bool get isAdmin => userType == 'admin';
  
  /// Check if user is driver
  bool get isDriver => userType == 'driver';
}
