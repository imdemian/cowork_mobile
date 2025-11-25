import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Obtener usuario actual con su rol
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        print('❌ No hay usuario autenticado');
        return null;
      }

      print('🔍 Buscando usuario en Firestore: ${user.uid}');
      final doc = await _firestore.collection('users').doc(user.uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print('✅ Usuario encontrado: ${data['email']}, role: ${data['role']}');
        return UserModel.fromMap(data, user.uid);
      }

      print('⚠️ Usuario no encontrado en Firestore');
      return null;
    } catch (e) {
      print('❌ Error obteniendo usuario: $e');
      return null;
    }
  }

  Future<UserModel?> getUserById(String uid) async {
    try {
      print('🔍 Buscando usuario por ID: $uid');
      final doc = await _firestore.collection('users').doc(uid).get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        print('✅ Usuario encontrado en Firestore:');
        print('   - Email: ${data['email']}');
        print('   - Role: ${data['role']}');
        print('   - DisplayName: ${data['displayName']}');

        return UserModel.fromMap(data, uid);
      }

      print('⚠️ Usuario $uid no existe en Firestore');
      return null;
    } catch (e) {
      print('❌ Error obteniendo usuario por ID: $e');
      return null;
    }
  }

  // Crear usuario en Firestore
  Future<void> createUser({
    required String uid,
    required String email,
    String? displayName,
    String? photoURL,
    required String role, // 'admin' o 'cliente'
  }) async {
    try {
      print('📝 Creando usuario en Firestore:');
      print('   - UID: $uid');
      print('   - Email: $email');
      print('   - Role: $role');

      final data = {
        'email': email,
        'displayName': displayName,
        'photoURL': photoURL,
        'role': role, // Importante: debe ser 'admin' o 'cliente'
        'createdAt': FieldValue.serverTimestamp(),
        'emailVerified': _auth.currentUser?.emailVerified ?? false,
      };

      await _firestore.collection('users').doc(uid).set(data);
      print('✅ Usuario creado exitosamente');
    } catch (e) {
      print('❌ Error creando usuario: $e');
      rethrow;
    }
  }

  // Obtener todos los clientes (solo para admin)
  Future<List<UserModel>> getAllClients() async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'cliente')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) =>
                UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id),
          )
          .toList();
    } catch (e) {
      print('❌ Error obteniendo clientes: $e');
      return [];
    }
  }

  // Actualizar rol de usuario
  Future<void> setUserRole(String uid, String role) async {
    try {
      print('🔄 Actualizando rol de $uid a $role');
      await _firestore.collection('users').doc(uid).update({'role': role});
      print('✅ Rol actualizado');
    } catch (e) {
      print('❌ Error actualizando rol: $e');
      rethrow;
    }
  }

  // Crear usuario en Firestore (versión alternativa)
  Future<void> createUserInFirestore(User user, bool isAdmin) async {
    try {
      print('📝 Creando usuario en Firestore (método alternativo):');
      print('   - UID: ${user.uid}');
      print('   - Email: ${user.email}');
      print('   - Is Admin: $isAdmin');

      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'role': isAdmin ? 'admin' : 'cliente',
        'emailVerified': user.emailVerified,
        'createdAt': Timestamp.now(),
        'termsAccepted': true,
      });

      print('✅ Usuario creado exitosamente');
    } catch (e) {
      print('❌ Error creando usuario en Firestore: $e');
      rethrow;
    }
  }

  // Verificar si un usuario es admin
  Future<bool> isUserAdmin(String uid) async {
    try {
      final user = await getUserById(uid);
      return user?.isAdmin ?? false;
    } catch (e) {
      print('❌ Error verificando si es admin: $e');
      return false;
    }
  }
}
