part of 'app_bloc.dart';

// Sealing ensures that there is a defined set of subclasses
// and exhaustively handled
sealed class AppEvent {
  const AppEvent();
}

final class AppLogoutRequested extends AppEvent {
  const AppLogoutRequested();
}

final class AppUserChanged extends AppEvent {
  final User user;
  final CustomException exception;

  const AppUserChanged(this.user, this.exception);
}

final class ChangeNewAccountEvent extends AppEvent {
  const ChangeNewAccountEvent();
}

final class NewAccountCreated extends AppEvent {
  final User user;

  NewAccountCreated(this.user);
}
