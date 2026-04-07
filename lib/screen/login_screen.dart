import 'package:flutter/material.dart';
import 'package:portokita/services/auth_service.dart';
import 'package:go_router/go_router.dart';

class LoginFormContainer extends StatefulWidget {
  const LoginFormContainer({super.key});

  @override
  State<LoginFormContainer> createState() => _LoginFormContainerState();
}

class _LoginFormContainerState extends State<LoginFormContainer> {
  bool _rememberMe = false;
  bool _showPassword = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _isloading = false;
  AuthService auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Masuk",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Selamat datang kembali! Silakan masuk ke akun Anda.",
            style: TextStyle(color: Colors.black54, fontSize: 14),
          ),
          const SizedBox(height: 30),
          // Form Fields
          _buildLabel("Email"),
          _buildTextField(
            hint: "masukkan email",
            icon: Icons.email_outlined,
            textController: emailController,
          ),           
          const SizedBox(height: 15),

          _buildLabel("Password"),
          _buildTextField(
            hint: "masukkan password",
            icon: Icons.lock_outline,
            textController: passwordController,
            isPass: !_showPassword,
            onPasswordVisibilityToggle: () {
              setState(() {
                _showPassword = !_showPassword;                
              });
            },
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF4DB6AC),
                  ),
                  const Text(
                    "Remember Me ",
                    style: TextStyle(color: Colors.black87, fontSize: 12),
                  ),
                ],
              ),

              TextButton(
                onPressed: () {},
                child: const Text(
                  "Lupa Password?",
                  style: TextStyle(color: Color(0xFF4DB6AC)),
                ),
              ),
            ],
          ),

          // Tombol Login
          Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEE7F3C), Color(0xFFF49B33)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: ElevatedButton(
              onPressed: () async {
                setState(() => _isloading = true);
                final user = await auth.login(
                  email: emailController.text.trim(),
                  password: passwordController.text,
                );
                if (!mounted) return;
                setState(() => _isloading = false);

                if (user != null) {
                  context.go('/home');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Login Berhasil'),
                      backgroundColor: Colors.greenAccent,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Email atau password salah. coba lagi"),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                elevation: 0,
              ),
              child: _isloading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 255, 255, 255),
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      "Masuk",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 25),

          // Footer Daftar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Belum punya akun?",
                style: TextStyle(color: Colors.black),
              ),
              TextButton(
                onPressed: () {
                  context.push('/register');
                },
                child: const Text(
                  "Daftar",
                  style: TextStyle(color: Color(0xFF4DB6AC)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Widget untuk Label Form
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  // Helper Widget untuk Input Field
  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPass = false,
    VoidCallback? onPasswordVisibilityToggle,
    required TextEditingController textController,
  }) {
    return TextField(
      controller: textController,
      obscureText: isPass,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF4DB6AC)),
        suffixIcon: isPass || onPasswordVisibilityToggle != null
            ? GestureDetector(
                onTap: onPasswordVisibilityToggle,
                child: Icon(
                  _showPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: Colors.grey,
                ),
              )
            : null,
        filled: true,
        fillColor: const Color(0xFFE0F2F1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
