import 'package:equatable/equatable.dart';
import 'package:shared_photo/utils/api_variables.dart';

enum FriendStatus { friends, pending, notFriends }

class BaseFriend extends Equatable {
  final String uid;
  final String firstName;
  final String lastName;

  const BaseFriend({
    required this.uid,
    required this.firstName,
    required this.lastName,
  });

  factory BaseFriend.fromJson(Map<String, dynamic> json) {
    return BaseFriend(
      uid: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "user_id": uid,
      "first_name": firstName,
      "last_name": lastName,
    };
  }

  String get imageReq {
    return "$goRepoDomain/image?id=$uid";
  }

  @override
  List<Object?> get props => [uid];
}

class Friend extends BaseFriend {
  final DateTime friendSince;

  const Friend({
    required super.firstName,
    required super.lastName,
    required super.uid,
    required this.friendSince,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      uid: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      friendSince: DateTime.parse(json['friends_since']),
    );
  }
}

class AnonymousFriend extends BaseFriend {
  final FriendStatus friendStatus;
  final int numberOfFriends;
  final int numberOfAlbums;
  final List<String> albumIDs;

  const AnonymousFriend({
    required super.firstName,
    required super.lastName,
    required super.uid,
    required this.friendStatus,
    required this.numberOfFriends,
    required this.numberOfAlbums,
    required this.albumIDs,
  });

  static const empty = AnonymousFriend(
    firstName: "firstName",
    lastName: "lastName",
    uid: "",
    friendStatus: FriendStatus.notFriends,
    numberOfFriends: 0,
    numberOfAlbums: 0,
    albumIDs: [],
  );

  factory AnonymousFriend.fromJson(Map<String, dynamic> json) {
    FriendStatus friendStatus = FriendStatus.notFriends;
    List<String> albumIDs = [];

    switch (json['friend_status']) {
      case 'friends':
        friendStatus = FriendStatus.friends;
      case 'pending':
        friendStatus = FriendStatus.pending;
    }

    if (json['album_id'] != null) {
      albumIDs = List<String>.from(json['album_id']);
    }

    return AnonymousFriend(
      uid: json['user_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      friendStatus: friendStatus,
      numberOfFriends: json['friend_count'],
      numberOfAlbums: albumIDs.length,
      albumIDs: albumIDs,
    );
  }
}
