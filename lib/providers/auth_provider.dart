import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;

  // ✅ Getter: obtener usuario actual
  UserModel? get user => _user;

  // ✅ Setter con notificación de cambio
  set user(UserModel? newUser) {
    _user = newUser;
    notifyListeners();
  }

  // ✅ Saber si hay sesión activa
  bool get isAuthenticated => _user != null;

  // 🧩 REGISTRO
  Future<bool> register(String name, String email, String password) async {
    try {
      _user = await _authService.register(name, email, password);
      notifyListeners();
      return _user != null;
    } catch (e) {
      rethrow; // dejamos que el LoginScreen o RegisterScreen manejen el error
    }
  }

  // 🧩 LOGIN
  Future<bool> login(String email, String password) async {
    try {
      _user = await _authService.login(email, password);
      notifyListeners();
      return _user != null;
    } catch (e) {
      rethrow;
    }
  }

  // 🧩 LOGOUT
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  // 🧩 Refrescar usuario (por si cambia info en Firestore)
  Future<void> refreshUser() async {
    if (_user == null) return;
    try {
      final updatedUser = await _authService.login(_user!.email, "");
      if (updatedUser != null) {
        _user = updatedUser;
        notifyListeners();
      }
    } catch (_) {
      // En caso de error, simplemente no actualiza
    }
  }
}
