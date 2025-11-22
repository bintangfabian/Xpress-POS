import 'dart:async';
import 'package:flutter/material.dart';
import 'package:xpress/core/constants/colors.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/presentation/auth/pages/login_page.dart';

/// Service untuk mengelola session timeout setelah 2 jam inactive
class SessionTimeoutService {
  static final SessionTimeoutService _instance =
      SessionTimeoutService._internal();
  factory SessionTimeoutService() => _instance;
  SessionTimeoutService._internal();

  Timer? _inactivityTimer;
  Timer? _checkTimer;
  DateTime? _lastActivityTime;
  final Duration _timeoutDuration = const Duration(hours: 2);
  bool _isActive = false;
  BuildContext? _context;
  VoidCallback? _onTimeout;

  /// Set context for navigation
  void setContext(BuildContext? context) {
    _context = context;
  }

  /// Set callback for timeout
  void setOnTimeout(VoidCallback? callback) {
    _onTimeout = callback;
  }

  /// Start monitoring user activity
  void startMonitoring() {
    if (_isActive) return;
    _isActive = true;
    _updateActivity();
    _startCheckTimer();
  }

  /// Stop monitoring
  void stopMonitoring() {
    _isActive = false;
    _inactivityTimer?.cancel();
    _checkTimer?.cancel();
    _inactivityTimer = null;
    _checkTimer = null;
    _lastActivityTime = null;
  }

  /// Update last activity time
  void updateActivity() {
    if (!_isActive) return;
    _updateActivity();
  }

  void _updateActivity() {
    _lastActivityTime = DateTime.now();
  }

  void _startCheckTimer() {
    _checkTimer?.cancel();
    // Check every minute if user is still inactive
    _checkTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (!_isActive) {
        timer.cancel();
        return;
      }

      if (_lastActivityTime != null) {
        final timeSinceLastActivity =
            DateTime.now().difference(_lastActivityTime!);
        if (timeSinceLastActivity >= _timeoutDuration) {
          timer.cancel();
          _handleTimeout();
        }
      }
    });
  }

  Future<void> _handleTimeout() async {
    if (!_isActive) return;

    _isActive = false;
    _inactivityTimer?.cancel();
    _checkTimer?.cancel();

    // Clear auth data
    final authLocal = AuthLocalDataSource();
    await authLocal.removeAuthData();

    // Call callback or navigate
    if (_onTimeout != null) {
      _onTimeout!();
    } else if (_context != null && _context!.mounted) {
      Navigator.of(_context!).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const LoginPage(),
        ),
        (route) => false,
      );

      // Show message
      ScaffoldMessenger.of(_context!).showSnackBar(
        const SnackBar(
          content: Text(
              'Sesi Anda telah berakhir karena tidak ada aktivitas selama 2 jam'),
          backgroundColor: AppColors.warning,
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  /// Get remaining time until timeout
  Duration? getRemainingTime() {
    if (_lastActivityTime == null) return null;
    final elapsed = DateTime.now().difference(_lastActivityTime!);
    final remaining = _timeoutDuration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

/// Widget untuk mendeteksi user interaction dan update activity
class ActivityDetector extends StatefulWidget {
  final Widget child;

  const ActivityDetector({
    super.key,
    required this.child,
  });

  @override
  State<ActivityDetector> createState() => _ActivityDetectorState();
}

class _ActivityDetectorState extends State<ActivityDetector> {
  final SessionTimeoutService _sessionService = SessionTimeoutService();

  @override
  void initState() {
    super.initState();
    _sessionService.startMonitoring();
  }

  @override
  void dispose() {
    _sessionService.stopMonitoring();
    super.dispose();
  }

  void _handleUserInteraction() {
    _sessionService.updateActivity();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _handleUserInteraction(),
      onPointerMove: (_) => _handleUserInteraction(),
      onPointerUp: (_) => _handleUserInteraction(),
      child: GestureDetector(
        onTap: () => _handleUserInteraction(),
        onPanUpdate: (_) => _handleUserInteraction(),
        child: KeyboardListener(
          focusNode: FocusNode(),
          onKeyEvent: (_) {
            _handleUserInteraction();
          },
          child: widget.child,
        ),
      ),
    );
  }
}
