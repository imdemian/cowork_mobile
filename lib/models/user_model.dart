import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String role; // 'admin' o 'cliente'
  final bool emailVerified;
  final DateTime createdAt;
  final bool termsAccepted;
  final bool isAdmin;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    required this.role,
    required this.emailVerified,
    required this.createdAt,
    required this.termsAccepted,
    this.isAdmin = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      role: data['role'] ?? 'cliente',
      emailVerified: data['emailVerified'] ?? false,
      isAdmin: data['isAdmin'] as bool? ?? false,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      termsAccepted: data['termsAccepted'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'emailVerified': emailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'termsAccepted': termsAccepted,
    };
  }
}
