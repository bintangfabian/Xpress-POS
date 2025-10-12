import 'package:flutter/material.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/presentation/auth/pages/login_page.dart';
import 'package:xpress/presentation/home/pages/dashboard_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final ds = AuthLocalDataSource();
    final remember = await ds.getRememberMe();
    if (!mounted) return;
    if (remember) {
      final hasAuth = await ds.isAuthDataExists();
      if (!mounted) return;
      if (hasAuth) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
        return;
      }
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
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

