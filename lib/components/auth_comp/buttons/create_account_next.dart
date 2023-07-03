import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_photo/bloc/cubit/login_cubit.dart';

class CreateAccountNext extends StatelessWidget {
  const CreateAccountNext({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, AuthState>(
      buildWhen: (previous, current) =>
          (previous.emailMatch != current.emailMatch ||
              previous.passwordMatch != current.passwordMatch ||
              previous.confirmPassMatch != current.confirmPassMatch),
      builder: (context, state) {
        return state.isLoading == true
            ? const CircularProgressIndicator(
                backgroundColor: Color.fromARGB(35, 0, 0, 0),
              )
            : ElevatedButton(
                onPressed: (state.emailMatch == true &&
                        state.passwordMatch == true &&
                        state.confirmPassMatch == true)
                    ? () =>
                        Navigator.of(context).pushNamed('/create-account-auth')
                    : null,
                child: const Text('Next'),
              );
      },
    );
  }
}
