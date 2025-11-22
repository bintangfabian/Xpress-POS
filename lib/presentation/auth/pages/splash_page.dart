import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/core/assets/assets.gen.dart';
import 'package:xpress/core/constants/colors.dart';
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

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  final AuthLocalDataSource _authLocalDataSource = AuthLocalDataSource();
  final AuthRemoteDatasource _authRemoteDatasource = AuthRemoteDatasource();

  late AnimationController _splashController;
  late AnimationController _transitionController;
  late Animation<double> _circleAnimation;
  late Animation<Color?> _backgroundColorAnimation;

  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // Controller untuk splash screen awal (2-3 detik)
    _splashController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Controller untuk animasi transisi
    _transitionController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Animasi lingkaran yang mengembang dari huruf O
    _circleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Animasi perubahan warna background (primary -> white)
    _backgroundColorAnimation = ColorTween(
      begin: AppColors.primary,
      end: AppColors.white,
    ).animate(
      CurvedAnimation(
        parent: _transitionController,
        curve: Curves.easeInOut,
      ),
    );

    // Start splash screen
    _splashController.forward().then((_) {
      if (mounted) {
        // Setelah splash selesai, mulai animasi transisi
        _transitionController.forward().then((_) {
          if (mounted && !_hasNavigated) {
            // ✅ Tambahkan delay 5 detik setelah transisi selesai
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted && !_hasNavigated) {
                _bootstrap();
              }
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _splashController.dispose();
    _transitionController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    if (_hasNavigated) return;
    _hasNavigated = true;

    final onlineCheckerBloc = context.read<OnlineCheckerBloc>();
    if (!context.mounted) return;

    final isOnline = onlineCheckerBloc.isOnline;
    final hasCachedUser = await _authLocalDataSource.hasCachedUser();
    final isAuthenticated = await _authLocalDataSource.isAuthenticated();
    final token = await _authLocalDataSource.getToken();

    if (!context.mounted) return;

    if (isAuthenticated && token != null && token.isNotEmpty) {
      if (isOnline) {
        final result = await _authRemoteDatasource.fetchProfile(token);
        if (!context.mounted) return;
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
        if (!context.mounted) return;
        _navigateToHome();
        return;
      }
    }

    if (hasCachedUser) {
      await _authLocalDataSource.markOfflineLogin();
      if (!context.mounted) return;
      _navigateToHome();
      return;
    }

    final showWarning = !isOnline;
    _navigateToLogin(showOfflineWarning: showWarning);
  }

  void _navigateToHome() {
    if (!mounted) return;
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
    if (!mounted) return;
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

  // Hitung posisi center logo untuk animasi lingkaran
  // Menggunakan center dari logo (diperkirakan logo memiliki huruf O di tengah)
  Offset _getLogoCenter(Size size) {
    // Logo berada di center, dan animasi dimulai dari center logo
    return Offset(size.width / 2, size.height / 2);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _splashController,
        _transitionController,
      ]),
      builder: (context, child) {
        final backgroundColor = _splashController.isCompleted
            ? _backgroundColorAnimation.value ?? AppColors.primary
            : AppColors.primary;

        // Tentukan logo mana yang digunakan berdasarkan fase animasi
        final isAfterTransition = _splashController.isCompleted;
        final logoAsset = isAfterTransition
            ? Assets.logo.logo1OriBlueVer
            : Assets.logo.logo1MonochromeWhiteVer;

        return Scaffold(
          backgroundColor: backgroundColor,
          body: Stack(
            children: [
              // Logo Image
              Center(
                child: logoAsset.image(
                  width: 500,
                  height: 500,
                  fit: BoxFit.contain,
                ),
              ),

              // ✅ Animasi lingkaran yang mengembang dari center logo
              // Hanya tampilkan saat animasi sedang berjalan, bukan setelah selesai
              if (_transitionController.isAnimating)
                LayoutBuilder(
                  builder: (context, constraints) {
                    return CustomPaint(
                      painter: _CircleExpansionPainter(
                        animation: _circleAnimation.value,
                        center: _getLogoCenter(constraints.biggest),
                        startColor: AppColors.primary,
                        endColor: AppColors.white,
                      ),
                      size: constraints.biggest,
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }
}

// Custom Painter untuk efek lingkaran yang mengembang
class _CircleExpansionPainter extends CustomPainter {
  final double animation;
  final Offset center;
  final Color startColor;
  final Color endColor;

  _CircleExpansionPainter({
    required this.animation,
    required this.center,
    required this.startColor,
    required this.endColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (animation <= 0 || animation >= 1.0) return;

    // Hitung radius maksimum (diagonal layar untuk memastikan menutupi semua)
    final maxRadius = math.sqrt(
          math.pow(size.width, 2) + math.pow(size.height, 2),
        ) /
        2;

    // Radius saat ini berdasarkan animasi
    final currentRadius = maxRadius * animation;

    // Warna transisi
    final color = Color.lerp(startColor, endColor, animation) ?? startColor;

    // ✅ Perbaiki opacity gradient agar lebih smooth dan tidak meninggalkan bekas
    // Opacity akan berkurang drastis saat animasi mendekati akhir (80% ke atas)
    double opacityMultiplier = 1.0;
    if (animation > 0.8) {
      // Fade out cepat di akhir animasi
      opacityMultiplier =
          (1.0 - animation) / 0.2; // Dari 1.0 ke 0.0 dalam 20% terakhir
    }

    // Buat gradient dari center ke luar dengan opacity yang lebih halus
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withOpacity(0.9 * opacityMultiplier),
          color.withOpacity(0.5 * opacityMultiplier),
          color.withOpacity(0.15 * opacityMultiplier),
          color.withOpacity(0.0),
        ],
        stops: const [0.0, 0.2, 0.5, 1.0],
      ).createShader(
        Rect.fromCircle(center: center, radius: currentRadius),
      )
      ..style = PaintingStyle.fill;

    // Gambar lingkaran yang mengembang
    canvas.drawCircle(center, currentRadius, paint);
  }

  @override
  bool shouldRepaint(_CircleExpansionPainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.center != center;
  }
}
