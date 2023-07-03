import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_photo/bloc/cubit/login_cubit.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController? email =
        context.read<LoginCubit>().state.emailController;
    final TextEditingController? password =
        context.read<LoginCubit>().state.passwordController;
    return BlocBuilder<LoginCubit, AuthState>(
      buildWhen: (previous, current) =>
          (previous.emailMatch != current.emailMatch ||
              previous.passwordMatch != current.passwordMatch),
      builder: (context, state) {
        return state.isLoading == true
            ? const CircularProgressIndicator(
                backgroundColor: Color.fromARGB(35, 0, 0, 0),
              )
            : ElevatedButton(
                onPressed: (state.emailMatch == true &&
                        state.passwordMatch == true &&
                        email != null &&
                        password != null)
                    ? () => context.read<LoginCubit>().loginWithCredentials(
                        email: email.text, password: password.text)
                    : null,
                child: const Text('Login'),
              );
      },
    );
  }
}
