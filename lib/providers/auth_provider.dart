import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoggedIn = false;
  String? _email;

  bool get isLoggedIn => _isLoggedIn;
  String? get email => _email;

  Future<void> login({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoggedIn = true;
    _email = email.trim();
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _email = null;
    notifyListeners();
  }
}
