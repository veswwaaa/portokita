import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'app_state_service.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  final GoRouter router;
  AppLifecycleState _lastState = AppLifecycleState.resumed;

  AppLifecycleObserver({required this.router});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lastState = state;
  }
}
