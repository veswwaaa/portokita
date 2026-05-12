import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppLifecycleObserver extends WidgetsBindingObserver {
  final GoRouter router;
  AppLifecycleState _lastState = AppLifecycleState.resumed;

  AppLifecycleObserver({required this.router});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print(_lastState);
    _lastState = state;
  }
}
