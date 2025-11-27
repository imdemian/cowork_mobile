import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io'; // Para Platform.isAndroid

class GoogleSignInService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Inicializa con serverClientId SOLO en Android
  static Future<GoogleSignIn> get _googleSignIn async {
    final serverClientId = Platform.isAndroid
        ? '164991754779-tld56fe5p93fifned9v9kusbkkedudpi.apps.googleusercontent.com' // Tu Web Client ID
        : null;

    return GoogleSignIn.instance
        .initialize(serverClientId: serverClientId)
        .then((_) => GoogleSignIn.instance);
  }

  // Login con Google (usa authenticate() para v7+)
  static Future<User?> signInWithGoogle() async {
    try {
      final googleSignIn = await _googleSignIn;
      final GoogleSignInAccount? googleUser = await googleSignIn.authenticate();

      if (googleUser == null) return null; // Usuario canceló

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('No se pudo obtener el token de Google');
      }

      // Credencial para Firebase (solo idToken en v7+)
      final credential = GoogleAuthProvider.credential(idToken: idToken);

      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );
      final User? user = result.user;

      if (user != null) {
        await _saveUserToFirestore(user);
      }

      return user;
    } catch (e) {
      print('Error en Google Sign-In: $e');
      rethrow;
    }
  }

  // Guardar usuario en Firestore si no existe
  static Future<void> _saveUserToFirestore(User user) async {
    final ref = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await ref.get();

    if (!doc.exists) {
      await ref.set({
        'uid': user.uid,
        'name': user.displayName ?? '',
        'email': user.email ?? '',
        'photoURL': user.photoURL ?? '',
        'isAdmin': user.email == 'admin@ejemplo.com', // Tu admin por email
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Logout
  static Future<void> signOut() async {
    final googleSignIn = await _googleSignIn;
    await googleSignIn.signOut();
    await _auth.signOut();
  }

  // Datos del usuario actual
  static Future<Map<String, dynamic>?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    return doc.data();
  }
}
