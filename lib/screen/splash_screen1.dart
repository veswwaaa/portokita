import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:portokita/screen/register_screen.dart';
import '../screen/login_screen.dart';

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
  bool isLogin = true;

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
          final rotateProgress = _rotateAnimation.value;
          final rotateAngle = rotateProgress * (135 * math.pi / 180);
          final scaleValue = 1.0 + (rotateProgress * 1.5);
          final logoSlideOffset = _slideController.value * -45.0;
          final fadeValue = _slideController.value.clamp(0.0, 1.0);

          final textSlideOffset =
              59.0 + ((1.0 - _slideController.value) * 30.0);

          final groupSlideOffset = _slideController.value * -56.0;

          final screenHeight = MediaQuery.of(context).size.height;
          final formOffset = (1.0 - _upAnimation.value) * screenHeight;
          final logoUpOffset = -_upAnimation.value * (screenHeight * 0.35);

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

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Transform.translate(
                    offset: Offset(0, formOffset),
                    child: const LoginFormContainer(),
                  ),
                ),

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
                          offset: Offset(textSlideOffset, -20.0),
                          child: SvgPicture.asset(
                            'assets/img/logoText.svg',
                            width: 270,

                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),

                      Transform.translate(
                        offset: Offset(logoSlideOffset, 0),
                        child: Transform.scale(
                          scale: scaleValue,
                          child: Transform.rotate(
                            angle: rotateAngle,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 150),
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
                                      width: 115,
                                    )
                                  : SvgPicture.asset(
                                      'assets/img/logo1.svg',
                                      key: const ValueKey('color'),
                                      width: 115,
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


