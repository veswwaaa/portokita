// import 'package:flutter/material.dart';
// import 'package:lottie/lottie.dart';
// // import 'package:go_router/go_router.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 3), // Durasi animasi
//     );

//     // Setelah animasi selesai, navigasi ke home
//     _controller.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         // context.go('/home');
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Animasi Lottie
//             Lottie.asset(
//               'assets/lottie/lottie_logo.json',
//               controller: _controller,
//               width: 800,
//               height: 800,
//               fit: BoxFit.contain,
//               onLoaded: (composition) {
//                 // Set durasi sesuai durasi animasi Lottie
//                 _controller.duration = composition.duration;
//                 _controller.forward();
//               },
//             ),
//             const SizedBox(height: 20),
//             // Teks di bawah animasi (opsional)
//             const Text(
//               'Portokita',
//               style: TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
