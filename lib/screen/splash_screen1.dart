import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const PortoKitaApp());
}

class PortoKitaApp extends StatelessWidget {
  const PortoKitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PortoKita',
      home: const SplashScreen(),
    );
  }
}

// --------------------------------------------------------------------------
// SPLASH SCREEN: Animasi Rotasi & Perubahan Warna
// --------------------------------------------------------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;

  late AnimationController _slideController;

  late AnimationController _upController;
  late Animation<double> _upAnimation;

  bool _isWhite = false;

  @override
  void initState() {
    super.initState();

    // Controller untuk rotasi diperhalus dengan durasi tetap
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Animasi pergerakan rotasi 0 -> 1 -> 0 dengan curve mulus
    _rotateAnimation =
        TweenSequence([
          TweenSequenceItem(
            tween: Tween<double>(begin: 0.0, end: 1.0),
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 0.0),
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _rotateController,
            curve: Curves.easeInOutSine,
          ),
        );

    _slideController = AnimationController(
      duration: const Duration(
        milliseconds: 1400,
      ), // Tambahkan durasi eksplisit agar tidak terlalu instan
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
    // Tunggu sebentar sebelum mulai
    await Future.delayed(const Duration(milliseconds: 500));

    // 1. Jalankan rotasi (otomatis balik dari 0 -> 1 -> 0 sesuai TweenSequence)
    if (mounted) {
      await _rotateController.forward();
    }

    // Tunggu sejenak setelah rotasi selesai
    await Future.delayed(const Duration(milliseconds: 200));

    // Ubah logo jadi putih sesaat sebelum / berbarengan saat mulai meluncur
    if (mounted) {
      setState(() => _isWhite = true);
    }

    // Figma Custom Spring: Stiffness 400, Damping 30, Mass 1
    final springDesc = const SpringDescription(
      mass: 1,
      stiffness: 100,
      damping: 10,
    );

    // 2. Meluncur ke sisi kiri dan muncul logotext menggunakan Spring Curve Figma
    if (mounted) {
      await _slideController.animateWith(SpringSimulation(springDesc, 0, 1, 0));
    }

    // Tunggu sebentar sesusah geser
    await Future.delayed(const Duration(milliseconds: 200));

    // 3. Geser ke Atas dan Tampilkan Form!
    if (mounted) {
      _upController.forward();
    }
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _slideController.dispose();
    _upController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _rotateController,
          _slideController,
          _upController,
        ]),
        builder: (context, child) {
          // Evaluasi putaran menggunakan TweenSequence yang halus (0 -> 1 -> 0)
          final rotateProgress = _rotateAnimation.value;
          final rotateAngle = rotateProgress * (135 * math.pi / 180);
          final scaleValue = 1.0 + (rotateProgress * 1.5);
          final logoSlideOffset = _slideController.value * -30.0;
          final fadeValue = _slideController.value.clamp(0.0, 1.0);
          // Sambil fade in, teks tampak meluncur sedikit ke kiri menuju posisi finalnya
          final textSlideOffset =
              60.0 + ((1.0 - _slideController.value) * 30.0);

          // Geser KESELURUHAN grup (Logo + Teks) secara animasi.
          // Dimulai dari 0 (tengah) dan berakhir di -50.0 (bergeser ke kiri)
          final groupSlideOffset = _slideController.value * -50.0;

          // Kalkulasi nilai pergeseran untuk Logo Naik dan Form Naik
          final screenHeight = MediaQuery.of(context).size.height;
          final formOffset = (1.0 - _upAnimation.value) * screenHeight;
          final logoUpOffset =
              -_upAnimation.value *
              (screenHeight *
                  0.35); // <- Nilai 0.35 mengatur setinggi apa logo kita saat Login

          return SizedBox.expand(
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // 1. Background Hitam Awal
                Positioned.fill(child: Container(color: Colors.black)),

                // 2. Background Gradient (Muncul di saat slide horizontal)
                Positioned.fill(
                  child: Opacity(
                    opacity: fadeValue,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFFE88B35), Color(0xFF1B2E2E)],
                          stops: [0.0, 0.4],
                        ),
                      ),
                    ),
                  ),
                ),

                // 3. Form Login Meluncur Ke Atas
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Transform.translate(
                    offset: Offset(0, formOffset),
                    child: const LoginFormContainer(),
                  ),
                ),

                // 4. Logo dan Teks Meluncur Ke Atas Secara Bersamaan
                Transform.translate(
                  offset: Offset(groupSlideOffset, logoUpOffset),
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Lapisan Bawah: Teks Portokita
                      Opacity(
                        opacity: fadeValue,
                        child: Transform.translate(
                          offset: Offset(
                            textSlideOffset,
                            -20.0,
                          ), // <- Geser dikit ke atas (nilai negatif untuk Y axis)
                          child: SvgPicture.asset(
                            'assets/img/logoText.svg',
                            width: 225,
                            // Filter warna jadi putih supaya lebih nyala di black background
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),

                      // Lapisan Atas: Logo
                      Transform.translate(
                        offset: Offset(logoSlideOffset, 0),
                        child: Transform.scale(
                          scale: scaleValue,
                          child: Transform.rotate(
                            angle: rotateAngle,
                            child: AnimatedSwitcher(
                              duration: const Duration(
                                milliseconds: 150,
                              ), // Ganti warna lebih cepat
                              layoutBuilder:
                                  (
                                    Widget? currentChild,
                                    List<Widget> previousChildren,
                                  ) {
                                    return Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        ...previousChildren,
                                        if (currentChild != null) currentChild,
                                      ],
                                    );
                                  },
                              child: _isWhite
                                  ? SvgPicture.asset(
                                      'assets/img/logoPutih.svg',
                                      key: const ValueKey('white'),
                                      width: 90,
                                    )
                                  : SvgPicture.asset(
                                      'assets/img/logo1.svg',
                                      key: const ValueKey('color'),
                                      width: 90,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --------------------------------------------------------------------------
// LOGIN SCREEN: Gradasi & Form Input
// --------------------------------------------------------------------------
class LoginFormContainer extends StatelessWidget {
  const LoginFormContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
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
          _buildTextField(hint: "masukkan email", icon: Icons.email_outlined),
          const SizedBox(height: 15),

          _buildLabel("Password"),
          _buildTextField(
            hint: "masukkan password",
            icon: Icons.lock_outline,
            isPass: true,
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: const Text(
                "Lupa Password?",
                style: TextStyle(color: Color(0xFF4DB6AC)),
              ),
            ),
          ),

          // Tombol Login
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE88B35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Masuk",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Text("atau", style: TextStyle(color: Colors.grey)),
            ),
          ),

          // Tombol Google
          SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons
                    .g_mobiledata, // Menggunakan icon bawaan flutter sementara karena google_icon.svg belum ada di folder
                size: 32,
                color: Colors.red,
              ),
              label: const Text(
                "Masuk dengan Google",
                style: TextStyle(color: Colors.black87),
              ),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                side: const BorderSide(color: Colors.black12),
              ),
            ),
          ),

          const SizedBox(height: 25),

          // Footer Daftar
          Center(
            child: RichText(
              text: TextSpan(
                text: "Belum punya akun? ",
                style: const TextStyle(color: Colors.black87),
                children: [
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text(
                        "Daftar",
                        style: TextStyle(
                          color: Color(0xFF4DB6AC),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
  }) {
    return TextField(
      obscureText: isPass,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF4DB6AC)),
        suffixIcon: isPass
            ? const Icon(Icons.visibility_off_outlined, color: Colors.grey)
            : null,
        filled: true,
        fillColor: const Color(0xFFE0F2F1), // Biru muda transparan sesuai video
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
