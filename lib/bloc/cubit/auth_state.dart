part of 'auth_cubit.dart';

final class AuthState extends Equatable {
  final bool isLoading;
  final String? errorMessage;
  final bool emailValid;
  final bool passwordValid;
  final bool confirmPassValid;
  final bool firstNameValid;
  final bool lastNameValid;
  final bool accountCreateMode;
  final TextEditingController? emailController;
  final TextEditingController? passwordController;
  final TextEditingController? confirmPassController;
  final TextEditingController? firstNameController;
  final TextEditingController? lastNameController;
  final CustomException exception;

  const AuthState({
    required this.isLoading,
    required this.accountCreateMode,
    this.emailValid = false,
    this.passwordValid = false,
    this.confirmPassValid = false,
    this.firstNameValid = false,
    this.lastNameValid = false,
    this.emailController,
    this.passwordController,
    this.confirmPassController,
    this.firstNameController,
    this.lastNameController,
    this.errorMessage = '',
    this.exception = CustomException.empty,
  });

  @override
  List<Object?> get props => [
        isLoading,
        emailValid,
        passwordValid,
        errorMessage,
        accountCreateMode,
        confirmPassValid,
        emailController,
        passwordController,
        confirmPassController,
        firstNameController,
        lastNameController,
        firstNameValid,
        lastNameValid,
        exception,
      ];

  AuthState copyWith({
    bool? isLoading,
    bool? emailValid,
    bool? passwordValid,
    bool? confirmPassValid,
    bool? accountCreateMode,
    TextEditingController? emailController,
    TextEditingController? passwordController,
    TextEditingController? confirmPassController,
    TextEditingController? firstNameController,
    TextEditingController? lastNameController,
    bool? firstNameValid,
    bool? lastNameValid,
    CustomException? exception,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      accountCreateMode: accountCreateMode ?? this.accountCreateMode,
      emailValid: emailValid ?? this.emailValid,
      confirmPassValid: confirmPassValid ?? this.confirmPassValid,
      passwordValid: passwordValid ?? this.passwordValid,
      emailController: emailController ?? this.emailController,
      passwordController: passwordController ?? this.passwordController,
      confirmPassController:
          confirmPassController ?? this.confirmPassController,
      firstNameController: firstNameController ?? this.firstNameController,
      lastNameController: lastNameController ?? this.lastNameController,
      firstNameValid: firstNameValid ?? this.firstNameValid,
      lastNameValid: lastNameValid ?? this.lastNameValid,
      exception: exception ?? this.exception,
    );
  }
}
