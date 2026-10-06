import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  AppUser? _currentUser;
  String? _lastError;

  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  String? get lastError => _lastError;

  Future<bool> login(String name, String password) async {
    _lastError = null;
    _currentUser = await _supabaseService.login(name, password);
    if (_currentUser == null) {
      _lastError = 'Login falhou. Verifique nome e senha.';
    }
    notifyListeners();
    return isAuthenticated;
  }

  Future<bool> register(String name, String password) async {
    _lastError = null;
    final result = await _supabaseService.register(name, password);
    if (result.success) {
      return await login(name, password);
    }
    _lastError = result.error;
    notifyListeners();
    return false;
  }

  void logout() {
    _currentUser = null;
    _lastError = null;
    notifyListeners();
  }
}
