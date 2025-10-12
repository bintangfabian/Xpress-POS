import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:xpress/data/datasources/auth_local_datasource.dart';

import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/assets/assets.gen.dart';
import '../../../core/components/buttons.dart';
import '../../../core/components/custom_text_field.dart';
import '../../../core/components/spaces.dart';
import '../../../core/constants/colors.dart';
import '../../home/pages/dashboard_page.dart';
import '../bloc/login/login_bloc.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;
  // Remember me temporarily disabled
  bool _rememberMe = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(Assets.images.bgLogin.path),
              fit: BoxFit.cover,
              opacity: 0.25),
        ),
        child: Center(
          child: SingleChildScrollView(
            // padding:
            //     const EdgeInsets.symmetric(horizontal: 420.0, vertical: 20.0),
            child: Container(
              width: 440,
              height: 463,
              decoration: BoxDecoration(
                color: AppColors.white,
                // .withOpacity(0.9),
                borderRadius: const BorderRadius.all(Radius.circular(10.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
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
                  // Remember me and forgot password row disabled temporarily

                  const SpaceHeight(24.0),
                  BlocListener<LoginBloc, LoginState>(
                    listener: (context, state) {
                      state.maybeWhen(
                        orElse: () {},
                        success: (authResponseModel) async {
                          final ds = AuthLocalDataSource();
                          await ds.saveAuthData(authResponseModel);
                          // Save store UUID from user if available
                          final storeUuid = authResponseModel.user?.storeId;
                          if (storeUuid != null && storeUuid.isNotEmpty) {
                            await ds.saveStoreUuid(storeUuid);
                          }
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
                              onPressed: () {
                                context.read<LoginBloc>().add(
                                      LoginEvent.login(
                                        email: emailController.text,
                                        password: passwordController.text,
                                      ),
                                    );
                              },
                              label: 'Masuk',
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
                  // const SpaceHeight(12.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
