import 'package:flutter/material.dart';
import 'package:i/service/userservice.dart';

class UserProvider with ChangeNotifier {
  Map<String, dynamic>? _user;
  final UserService _userService = UserService();

  Map<String, dynamic>? get user => _user;

  // Fazer login
  Future<void> login(String email, String password) async {
    try {
      _user = await _userService.login(email, password);
      notifyListeners();
    } catch (e) {
      print('Erro no login: $e');
    }
  }

  // Fazer logout
  Future<void> logout() async {
    await _userService.logout();
    _user = null;
    notifyListeners();
  }

  // Recuperar usuário logado
  Future<void> getLoggedUser() async {
    _user = await _userService.getLoggedUser();
    notifyListeners();
  }
}
