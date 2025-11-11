import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AuthService() {
    // ✅ Forzar idioma de correos en español
    _auth.setLanguageCode('es');
  }

  // ✅ Registro con verificación de correo y enlace clickeable
  Future<UserModel?> register(String name, String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Configurar el enlace de verificación
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://rentacar-820e7.firebaseapp.com/',
        handleCodeInApp: false,
        androidPackageName: 'com.example.rentacar_flutter',
        androidInstallApp: true,
        androidMinimumVersion: '21',
      );

      // Enviar correo de verificación con enlace clickeable
      await cred.user!.sendEmailVerification(actionCodeSettings);

      UserModel user = UserModel(
        uid: cred.user!.uid,
        name: name,
        email: email,
        photoUrl: null,
      );

      await _db.collection('users').doc(user.uid).set(user.toMap());
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        throw Exception('El correo ya está registrado.');
      } else if (e.code == 'invalid-email') {
        throw Exception('El correo no es válido.');
      } else if (e.code == 'weak-password') {
        throw Exception('La contraseña debe tener al menos 6 caracteres.');
      } else {
        throw Exception(e.message ?? 'Error desconocido.');
      }
    } catch (e) {
      throw Exception('❌ Error en registro: $e');
    }
  }

  // ✅ Login corregido (permite entrar y luego se valida la verificación)
  Future<UserModel?> login(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = cred.user;

      // 🔎 Ya no bloqueamos aquí. Permitimos login y luego verificamos en pantalla.
      final doc = await _db.collection('users').doc(user!.uid).get();
      if (!doc.exists) return null;

      return UserModel.fromMap(doc.data()!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No existe una cuenta con este correo.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Contraseña incorrecta.');
      } else if (e.code == 'invalid-email') {
        throw Exception('Correo no válido.');
      } else {
        throw Exception(e.message ?? 'Error en inicio de sesión.');
      }
    } catch (e) {
      throw Exception('❌ Error en login: $e');
    }
  }

  // ✅ Cerrar sesión
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ✅ Recuperar contraseña
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print("📧 Correo de recuperación enviado a $email");
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Error al enviar correo de recuperación');
    } catch (e) {
      throw Exception('Error inesperado: $e');
    }
  }
}