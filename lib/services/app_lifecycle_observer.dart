import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_state_service.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  final GoRouter router;
  AppLifecycleState _lastState = AppLifecycleState.resumed;

  AppLifecycleObserver({required this.router});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Deteksi saat app resume dari background
    if (_lastState == AppLifecycleState.paused &&
        state == AppLifecycleState.resumed) {
      _handleAppResume();
    }
    _lastState = state;
  }

  Future<void> _handleAppResume() async {
    // Dapatkan route terakhir
    final lastRoute = await AppStateService.getLastRoute();

    // Jika ada route terakhir yang disimpan, navigasi ke sana
    // (bukan ke splash screen)
    if (lastRoute != null && lastRoute != '/splash') {
      // Delay sebentar untuk memastikan context siap
      await Future.delayed(const Duration(milliseconds: 100));
      router.go(lastRoute);
    }
  }
}
