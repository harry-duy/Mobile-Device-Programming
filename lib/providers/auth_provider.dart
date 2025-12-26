import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

enum AuthStatus { uninitialized, authenticated, authenticating, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  UserProfile? _userProfile;
  AuthStatus _status = AuthStatus.uninitialized;
  String? _errorMessage;

  // Getters
  User? get user => _user;
  UserProfile? get userProfile => _userProfile;
  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAdmin => _userProfile?.role == UserRole.admin;

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) async {
      if (user == null) {
        _status = AuthStatus.unauthenticated;
        _user = null;
        _userProfile = null;
      } else {
        _user = user;
        _userProfile = await _authService.getUserProfile(user.uid);
        _status = AuthStatus.authenticated;
      }
      notifyListeners();
    });
  }

  // Hàm Đăng Ký
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    UserRole role = UserRole.customer, // <--- 1. Thêm tham số này
  }) async {
    try {
      _status = AuthStatus.authenticating;
      notifyListeners();

      await _authService.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role, // <--- 2. Truyền role xuống Service
      );

      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Hàm Đăng Nhập
  Future<bool> signIn({required String email, required String password}) async {
    try {
      _status = AuthStatus.authenticating;
      notifyListeners();
      await _authService.signIn(email: email, password: password);
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _authService.resetPassword(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }
}