import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_photo/bloc/cubit/login_cubit.dart';
import 'package:shared_photo/components/auth_comp/login_button.dart';
import 'package:shared_photo/components/auth_comp/password_input.dart';
import 'email_input.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  const LoginForm(
      {required this.emailController,
      required this.passwordController,
      super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.errorMessage != '') {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Authentication error'),
              ),
            );
        }
      },
      builder: (context, state) {
        return Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                EmailInput(emailController: emailController),
                PasswordInput(passwordController: passwordController),
                LoginButton(
                  email: emailController,
                  password: passwordController,
                ),
                const JoinTextSpan()
              ],
            ),
          ),
        );
      },
    );
  }
}

class JoinTextSpan extends StatelessWidget {
  const JoinTextSpan({super.key});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: <TextSpan>[
          const TextSpan(
            text: 'No account? ',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: 'Join now',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () => context.read<LoginCubit>().swapModes(),
          ),
        ],
      ),
    );
  }
}
