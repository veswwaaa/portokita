import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portokita/services/auth_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LupaPasswordScreen extends StatefulWidget {
  const LupaPasswordScreen({super.key});

  @override
  State<LupaPasswordScreen> createState() => _LupaPasswordScreenState();
}

class _LupaPasswordScreenState extends State<LupaPasswordScreen>
    with TickerProviderStateMixin {
  bool _showPassword = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  bool _isLoading = false;
  String? _selectJurusan;
  final AuthService _auth = AuthService();

  late AnimationController _slideController;

  late AnimationController _upController;
  late Animation<double> _upAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _upController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _upAnimation = CurvedAnimation(
      parent: _upController,
      curve: Curves.easeOutQuart,
    );

    _runAnimations();
  }

  Future<void> _runAnimations() async {
    if (mounted) {
      _slideController.duration = const Duration(milliseconds: 500);
      _slideController.forward();
    }

    await Future.delayed(const Duration(milliseconds: 200));

    if (mounted) {
      _upController.forward();
    }
  }

  @override
  void dispose() {
    _upController.dispose();
    _slideController.dispose();
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedBuilder(
        animation: Listenable.merge([_slideController, _upController]),
        builder: (context, child) {
          final fadeValue = _slideController.value.clamp(0.0, 1.0);

          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
          final screenHeight = MediaQuery.of(context).size.height;

          final formOffset = (1.0 - _upAnimation.value) * screenHeight;
          final logoUpOffset = formOffset - (screenHeight * 0.35);
          return SizedBox.expand(
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(child: Container(color: Colors.black)),

                Positioned.fill(
                  child: Opacity(
                    opacity: fadeValue,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFEE7F3C), Color(0xFF1B2E2E)],
                          stops: [0.0, 0.9],
                        ),
                      ),
                    ),
                  ),
                ),

                Transform.translate(
                  offset: Offset(0, logoUpOffset),
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Transform.translate(
                        offset: const Offset(5.0, -20.0),
                        child: SvgPicture.asset(
                          'assets/img/logoText.svg',
                          width: 270,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      Transform.translate(
                        offset: const Offset(-105.0, 0.0),
                        child: SvgPicture.asset(
                          'assets/img/logoPutih.svg',
                          width: 115,
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(
                  top: screenHeight * 0.28,
                  bottom: keyboardHeight,
                  left: 0,
                  right: 0,
                  child: Transform.translate(
                    offset: Offset(0, formOffset),
                    child: _buildFormContainer(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormContainer() {
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
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Reset Password",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Kami akan mengirimkan link reset ke email Anda.",
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 30),
            
            _buildLabel("Email"),
            _buildTextField(
              hint: "masukkan email",
              icon: Icons.email_outlined,
              textController: emailController,
            ),
            
            const SizedBox(height: 30),

            // Tombol Reset
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
                onPressed: _isLoading ? null : _handleResetPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Text(
                        "Kirim Link Reset",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 25),

            // Kembali ke Login
            Center(
              child: TextButton(
                onPressed: () {
                  context.go('/splash?skip=true');
                },
                child: const Text(
                  "Kembali ke Login",
                  style: TextStyle(color: Color(0xFF4DB6AC), fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //fungsi reset password
  Future<void> _handleResetPassword() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Silakan masukkan email Anda")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _auth.sendPasswordResetEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Link reset password telah dikirim ke email Anda"),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengirim email reset"),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
