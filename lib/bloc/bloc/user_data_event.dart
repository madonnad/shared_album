part of 'user_data_bloc.dart';

abstract class UserDataEvent extends Equatable {
  const UserDataEvent();

  @override
  List<Object> get props => [];
}

final class FeedDataRequested extends UserDataEvent {
  String uid;
  FeedDataRequested({required this.uid});
}

final class RemoveUserData extends UserDataEvent {}
