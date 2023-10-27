import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_photo/models/user.dart';
import 'package:shared_photo/repositories/auth0_repository.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final Auth0Repository _auth0repository;

  AppBloc({
    required Auth0Repository auth0repository,
  })  : _auth0repository = auth0repository,
        super(const LoadingState()) {
    on<AppUserChanged>(
      (event, emit) {
        if (event.user != User.empty) {
          //print(event.user.token);
          emit(AuthenticatedState(event.user));
        } else {
          emit(const UnauthenticatedState());
        }
      },
    );

    on<AppLogoutRequested>(
      (event, emit) {
        unawaited(_auth0repository.logout());
      },
    );
    _auth0repository.userStream();

    _auth0repository.user.listen((user) => add(AppUserChanged(user)));
  }

  @override
  Future<void> close() {
    //_userSubscription.cancel();
    return super.close();
  }
}
