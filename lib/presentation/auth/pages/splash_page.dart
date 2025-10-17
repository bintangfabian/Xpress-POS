import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/data/datasources/auth_remote_datasource.dart';
import 'package:xpress/presentation/auth/pages/login_page.dart';
import 'package:xpress/presentation/home/bloc/online_checker/online_checker_bloc.dart';
import 'package:xpress/presentation/home/pages/dashboard_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();
  final AuthRemoteDatasource _authRemoteDatasource = AuthRemoteDatasource();

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final isOnline = context.read<OnlineCheckerBloc>().isOnline;
    final hasCachedUser = await _authLocalDataSource.hasCachedUser();
    final isAuthenticated = await _authLocalDataSource.isAuthenticated();
    final token = await _authLocalDataSource.getToken();

    if (!mounted) return;

    if (isAuthenticated && token != null && token.isNotEmpty) {
      if (isOnline) {
        final result = await _authRemoteDatasource.fetchProfile(token);
        if (!mounted) return;
        await result.fold(
          (error) async {
            await _authLocalDataSource.removeAuthData();
            _navigateToLogin(
              showOfflineWarning: false,
              message: error,
            );
          },
          (user) async {
            await _authLocalDataSource.updateCachedUser(user);
            await _authLocalDataSource.setLoginMode('online');
            _navigateToHome();
          },
        );
        return;
      } else if (hasCachedUser) {
        await _authLocalDataSource.markOfflineLogin();
        if (!mounted) return;
        _navigateToHome();
        return;
      }
    }

    if (hasCachedUser) {
      await _authLocalDataSource.markOfflineLogin();
      if (!mounted) return;
      _navigateToHome();
      return;
    }

    final showWarning = !isOnline;
    _navigateToLogin(showOfflineWarning: showWarning);
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const DashboardPage(),
      ),
    );
  }

  void _navigateToLogin({
    required bool showOfflineWarning,
    String? message,
  }) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(
          showOfflineWarning: showOfflineWarning,
          initialMessage: message,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
