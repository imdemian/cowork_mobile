import 'package:cloud_firestore/cloud_firestore.dart';

class ReservationModel {
  final String id;
  final String spaceId;
  final String spaceName;
  final String userId;
  final String userEmail;
  final String date;
  final String slot;
  final String status;
  final String? accessCode;
  final Timestamp createdAt;
  final Timestamp? expiresAt;

  ReservationModel({
    required this.id,
    required this.spaceId,
    required this.spaceName,
    required this.userId,
    required this.userEmail,
    required this.date,
    required this.slot,
    required this.status,
    required this.accessCode,
    required this.createdAt,
    this.expiresAt,
  });

  // 🔥 NECESARIO PARA DigitalKeyPage
  ReservationModel copyWith({
    String? accessCode,
    String? status,
    Timestamp? expiresAt,
  }) {
    return ReservationModel(
      id: id,
      spaceId: spaceId,
      spaceName: spaceName,
      userId: userId,
      userEmail: userEmail,
      date: date,
      slot: slot,
      status: status ?? this.status,
      accessCode: accessCode ?? this.accessCode,
      createdAt: createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  // 🔥 NECESARIO PARA DigitalKeyPage (cuando no hay reserva)
  factory ReservationModel.empty() {
    return ReservationModel(
      id: '',
      spaceId: '',
      spaceName: '',
      userId: '',
      userEmail: '',
      date: '',
      slot: '',
      status: '',
      accessCode: null,
      createdAt: Timestamp.now(),
      expiresAt: null,
    );
  }

  // 🔥 Convertir desde Firestore
  factory ReservationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ReservationModel(
      id: doc.id,
      spaceId: data['spaceId'] ?? '',
      spaceName: data['spaceName'] ?? '',
      userId: data['userId'] ?? '',
      userEmail: data['userEmail'] ?? '',
      date: data['date'] ?? '',
      slot: data['slot'] ?? '',
      status: data['status'] ?? 'pending',
      accessCode: data['accessCode'],
      createdAt: data['createdAt'] ?? Timestamp.now(),
      expiresAt: data['expiresAt'],
    );
  }

  // 🔥 Convertir a Firestore
  Map<String, dynamic> toMap() {
    return {
      'spaceId': spaceId,
      'spaceName': spaceName,
      'userId': userId,
      'userEmail': userEmail,
      'date': date,
      'slot': slot,
      'status': status,
      'accessCode': accessCode,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
    };
  }
}
