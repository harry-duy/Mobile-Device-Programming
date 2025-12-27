import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  // Getter để xem đang sáng hay tối
  bool get isDarkMode => _isDarkMode;

  // Lấy Theme hiện tại (Sáng/Tối)
  ThemeData get currentTheme {
    if (_isDarkMode) {
      // Cấu hình màu cho chế độ TỐI
      return ThemeData.dark().copyWith(
        primaryColor: Colors.orange,
        colorScheme: const ColorScheme.dark(
          primary: Colors.orange,
          secondary: Colors.orangeAccent,
          surface: Color(0xFF1E1E1E), // Màu nền thẻ card
        ),
        scaffoldBackgroundColor: const Color(0xFF121212), // Màu nền app
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          foregroundColor: Colors.white,
        ),
      );
    } else {
      // Cấu hình màu cho chế độ SÁNG
      return ThemeData.light().copyWith(
        primaryColor: Colors.orange,
        colorScheme: const ColorScheme.light(
          primary: Colors.orange,
          secondary: Colors.orangeAccent,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      );
    }
  }

  // Khởi tạo: Load chế độ đã lưu
  ThemeProvider() {
    _loadTheme();
  }

  void toggleTheme(bool isOn) async {
    _isDarkMode = isOn;
    notifyListeners(); // Cập nhật UI ngay lập tức

    // Lưu vào bộ nhớ máy
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
}