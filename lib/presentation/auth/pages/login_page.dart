import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';
import 'package:xpress/presentation/home/bloc/online_checker/online_checker_bloc.dart';

import '../../../core/assets/assets.gen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/custom_text_field.dart';
import '../../../core/components/spaces.dart';
import '../../../core/constants/colors.dart';
import '../../home/pages/dashboard_page.dart';
import '../bloc/login/login_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    this.showOfflineWarning = false,
    this.initialMessage,
  });

  final bool showOfflineWarning;
  final String? initialMessage;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;
  bool _offlineUnavailable = false;
  bool _showOfflineBanner = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _showOfflineBanner = widget.showOfflineWarning;
    _message = widget.initialMessage;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _evaluateOfflineAvailability();
    });
  }

  Future<void> _evaluateOfflineAvailability() async {
    final isOnline = context.read<OnlineCheckerBloc>().isOnline;
    if (isOnline) return;
    final hasCachedUser = await AuthLocalDataSource().hasCachedUser();
    if (!mounted) return;
    if (!hasCachedUser) {
      setState(() {
        _offlineUnavailable = true;
      });
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<OnlineCheckerBloc>().isOnline;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(Assets.images.bgLogin.path),
            fit: BoxFit.cover,
            opacity: 0.25,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 440,
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.1 * 255).round()),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_message != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BannerMessage(
                        message: _message!,
                        backgroundColor: AppColors.warningLight,
                        textColor: AppColors.warning,
                      ),
                    ),
                  if (_showOfflineBanner || _offlineUnavailable)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _BannerMessage(
                        message: _offlineUnavailable
                            ? 'Silakan login saat online terlebih dahulu.'
                            : 'Mode offline aktif. Beberapa fitur terbatas.',
                        backgroundColor: AppColors.warningLight,
                        textColor: AppColors.warning,
                      ),
                    ),
                  const Text(
                    'Selamat Datang Kembali',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Text(
                    'Silahkan masuk dengan akun anda',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SpaceHeight(20.0),
                  CustomTextField(
                    controller: emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SpaceHeight(12.0),
                  CustomTextField(
                    controller: passwordController,
                    label: 'Password',
                    obscureText: !isPasswordVisible,
                    textInputAction: TextInputAction.done,
                    suffixIcon: InkWell(
                      onTap: () => setState(() {
                        isPasswordVisible = !isPasswordVisible;
                      }),
                      child: Icon(
                        isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.grey,
                        size: 20,
                      ),
                    ),
                  ),
                  const SpaceHeight(12.0),
                  const SpaceHeight(24.0),
                  BlocListener<LoginBloc, LoginState>(
                    listener: (context, state) {
                      state.maybeWhen(
                        orElse: () {},
                        success: (authResponseModel) async {
                          final ds = AuthLocalDataSource();
                          await ds.saveAuthData(authResponseModel);
                          await ds.setLoginMode('online');
                          final storeUuid = authResponseModel.user?.storeId;
                          if (storeUuid != null && storeUuid.isNotEmpty) {
                            await ds.saveStoreUuid(storeUuid);
                          }
                          if (!context.mounted) return;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DashboardPage(),
                            ),
                          );
                        },
                        error: (message) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(message),
                              backgroundColor: AppColors.danger,
                            ),
                          );
                        },
                      );
                    },
                    child: BlocBuilder<LoginBloc, LoginState>(
                      builder: (context, state) {
                        return state.maybeWhen(
                          orElse: () {
                            return Button.filled(
                              onPressed: () async {
                                if (!isOnline) {
                                  final ds = AuthLocalDataSource();
                                  final hasCached = await ds.hasCachedUser();
                                  if (hasCached) {
                                    await ds.markOfflineLogin();
                                    if (!context.mounted) return;
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const DashboardPage(),
                                      ),
                                    );
                                  } else {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Silakan login saat online terlebih dahulu.',
                                        ),
                                        backgroundColor: AppColors.danger,
                                      ),
                                    );
                                  }
                                  return;
                                }

                                context.read<LoginBloc>().add(
                                      LoginEvent.login(
                                        email: emailController.text,
                                        password: passwordController.text,
                                      ),
                                    );
                              },
                              label: isOnline
                                  ? 'Masuk'
                                  : (_offlineUnavailable
                                      ? 'Masuk'
                                      : 'Masuk (Offline)'),
                            );
                          },
                          loading: () {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerMessage extends StatelessWidget {
  const _BannerMessage({
    required this.message,
    required this.backgroundColor,
    required this.textColor,
  });

  final String message;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
