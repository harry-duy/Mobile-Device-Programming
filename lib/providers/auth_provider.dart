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

  // ĐĂNG KÝ (Đã fix lỗi thiếu role)
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    UserRole role = UserRole.customer, // <--- THÊM DÒNG NÀY
  }) async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      // 1. Gọi Service để tạo tài khoản
      final credential = await _authService.signUp(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role, // <--- Truyền role xuống Service
      );

      // 2. CẬP NHẬT UI NGAY LẬP TỨC
      if (credential != null && credential.user != null) {
        _user = credential.user;

        // Tạo hồ sơ giả để hiện tên ngay
        _userProfile = UserProfile(
          uid: credential.user!.uid,
          email: email,
          name: name,
          phone: phone,
          address: '',
          role: role, // <--- Lưu role vào hồ sơ tạm
          createdAt: DateTime.now(),
        );
      }

      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;

    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.unauthenticated;
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

  // Hàm gọi update từ UI
  Future<bool> updateUserInfo(String name, String phone, String address) async {
    try {
      if (_user == null) return false;

      await _authService.updateProfile(
          uid: _user!.uid,
          name: name,
          phone: phone,
          address: address
      );

      // Load lại profile mới nhất để UI cập nhật ngay lập tức
      _userProfile = await _authService.getUserProfile(_user!.uid);
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }
}