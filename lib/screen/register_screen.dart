import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:portokita/services/auth_service.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterFormContainer extends StatefulWidget {
  const RegisterFormContainer({super.key});

  @override
  State<RegisterFormContainer> createState() => _RegisterFormContainerState();
}

class _RegisterFormContainerState extends State<RegisterFormContainer>
    with TickerProviderStateMixin {
  bool _showPassword = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  bool _isloading = false;
  String? _selectJurusan;
  final AuthService auth = AuthService();

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
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Daftar',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Mulai perjalanan profile baru mu',
                style: TextStyle(color: Colors.black54, fontSize: 14),
              ),
              const SizedBox(height: 30),
              _buildLabel('Username'),
              _buildTextField(
                hint: 'masukkan username',
                icon: Icons.supervised_user_circle_outlined,
                textController: usernameController,
              ),
              const SizedBox(height: 15),
              _buildLabel('Email'),
              _buildTextField(
                hint: 'masukkan email',
                icon: Icons.email_outlined,
                textController: emailController,
              ),
              const SizedBox(height: 15),
              _buildLabel('Pilih Jurusanmu'),
              _buildDropdownField(),

              const SizedBox(height: 15),
              _buildLabel('Password'),
              _buildTextField(
                hint: 'masukkan password',
                icon: Icons.lock_outline,
                textController: passwordController,
                isPass: !_showPassword,
                onPasswordVisibilityToggle: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
              ),

              SizedBox(height: 15),

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
                    try {
                      final user = await auth
                          .register(
                            email: emailController.text.trim(),
                            password: passwordController.text,
                            username: usernameController.text.trim(),
                            kategori: _selectJurusan,
                          )
                          .timeout(const Duration(seconds: 20));

                      if (!mounted) return;
                      setState(() => _isloading = false);

                      if (user['success'] == true) {
                        context.go('/splash');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Register Berhasil'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(user['message'] ?? 'Register Gagal'),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    } on TimeoutException {
                      if (!mounted) return;
                      setState(() => _isloading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Koneksi lambat. Silakan coba lagi atau cek internet kamu.",
                          ),
                          backgroundColor: Colors.orangeAccent,
                        ),
                      );
                    } catch (e) {
                      if (!mounted) return;
                      setState(() => _isloading = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Terjadi kesalahan: $e"),
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
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Daftar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Sudah punya akun?',
                    style: TextStyle(color: Colors.black),
                  ),
                  TextButton(
                    onPressed: () {
                      context.go('/splash?skip=true');
                    },
                    child: const Text(
                      'Masuk',
                      style: TextStyle(color: Color(0xFF4DB6AC)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      value: _selectJurusan,
      hint: const Text(
        "pilih jurusan kamu",
        style: TextStyle(color: Colors.grey, fontSize: 14),
      ),
      decoration: InputDecoration(
        prefixIcon: const Icon(
          Icons.person_2_outlined,
          color: Color(0xFF4DB6AC),
        ),
        filled: true,
        fillColor: const Color(0xFFE0F2F1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide: BorderSide.none,
        ),
      ),
      items:
          [
            "Rekayasa Perangkat Lunak",
            "Teknik Jaringan Komputer",
            "Teknik Jaringan Akses Telekomunikasi",
            "Design Komunikasi Visual",
            "Animasi",
          ].map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectJurusan = newValue;
        });
      },
    );
  }
}
