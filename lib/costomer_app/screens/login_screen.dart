import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Thư viện lưu trữ
import '../../providers/auth_provider.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controller để lấy dữ liệu nhập vào
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Biến trạng thái hiển thị mật khẩu
  bool _obscureText = true;

  // Biến cho chức năng "Ghi nhớ đăng nhập"
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedEmail(); // Tự động load email khi mở màn hình
  }

  // Hàm đọc Email đã lưu trong máy
  void _loadSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('saved_email');

    if (savedEmail != null && savedEmail.isNotEmpty) {
      setState(() {
        _emailController.text = savedEmail;
        _rememberMe = true; // Tự động tích vào ô nhớ mật khẩu
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Xử lý logic Đăng nhập
  Future<void> _handleLogin() async {
    // 1. Kiểm tra form hợp lệ
    if (!_formKey.currentState!.validate()) return;

    // 2. Xử lý lưu/xóa email vào bộ nhớ máy
    final prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setString('saved_email', _emailController.text.trim());
    } else {
      await prefs.remove('saved_email');
    }

    // 3. Gọi AuthProvider để đăng nhập
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final success = await authProvider.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    // 4. Kiểm tra kết quả
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Đăng nhập thất bại'),
          backgroundColor: Colors.red,
        ),
      );
    }
    // Nếu thành công (success == true), AuthWrapper ở main.dart sẽ tự chuyển trang.
  }

  @override
  Widget build(BuildContext context) {
    // Lấy trạng thái loading từ Provider
    final isLoading = context.watch<AuthProvider>().status == AuthStatus.authenticating;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- LOGO & TITLE ---
                  const Icon(
                    Icons.fastfood_rounded,
                    size: 80,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Đăng Nhập',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Chào mừng bạn quay trở lại!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  // --- EMAIL INPUT ---
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.orange, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập email';
                      }
                      if (!value.contains('@')) {
                        return 'Email không hợp lệ';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // --- PASSWORD INPUT ---
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      labelText: 'Mật khẩu',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.orange, width: 2),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng nhập mật khẩu';
                      }
                      if (value.length < 6) {
                        return 'Mật khẩu phải có ít nhất 6 ký tự';
                      }
                      return null;
                    },
                  ),

                  // --- REMEMBER ME & FORGOT PASS ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Checkbox Ghi nhớ
                      Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            activeColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _rememberMe = value!;
                              });
                            },
                          ),
                          const Text("Ghi nhớ tôi"),
                        ],
                      ),

                      // Nút Quên mật khẩu (Nice to have)
                      TextButton(
                        onPressed: () {
                          // TODO: Thêm tính năng quên mật khẩu sau
                        },
                        child: const Text(
                          'Quên mật khẩu?',
                          style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- LOGIN BUTTON ---
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: isLoading
                          ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Text(
                        'ĐĂNG NHẬP',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- SIGN UP LINK ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Chưa có tài khoản?"),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Đăng ký ngay',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}