// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';
import 'package:shared_photo/models/friend.dart';

class User extends Equatable {
  final String id;
  final String? email;
  final String? username;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final List<Friend>? friendsList;
  final String token;

  // Constructors
  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.token,
    this.email,
    this.username,
    this.avatarUrl,
    this.friendsList = const [],
  });

  static const empty = User(id: '', firstName: '', lastName: '', token: '');

  // Getters
  // Getter to check if the current user is empty
  bool get isEmpty => this == User.empty;
  // Getter to check if the current user is not empty
  bool get isNotEmpty => this != User.empty;

  Map<String, String> get headers => {"Authorization": "Bearer $token"};

  factory User.fromRepoData(
      {required String id,
      required String email,
      required Map<String, dynamic> retrievedData}) {
    String firstName = retrievedData['first_name'];
    String lastName = retrievedData['last_name'];
    String avatarUrl = retrievedData['avatar'];
    List friendsResponse = retrievedData['friends'];
    List<Friend> friendsList = [];

    // Extract the friends from the friends list response
    for (var friend in friendsResponse) {
      Friend newFriend = Friend(
        uid: friend['user_id'],
        firstName: friend['first_name'],
        lastName: friend['last_name'],
      );
      friendsList.add(newFriend);
    }

    // Return the User item with the logic worked out
    return User(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      avatarUrl: avatarUrl,
      friendsList: friendsList,
      token: '',
    );
  }

  //Equatable overrides
  @override
  List<Object?> get props =>
      [email, id, firstName, lastName, avatarUrl, friendsList, token];
}
