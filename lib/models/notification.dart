import 'package:equatable/equatable.dart';
import 'package:shared_photo/utils/api_variables.dart';
import 'package:timeago/timeago.dart' as timeago;

enum GenericNotificationType { likedPhoto, upvotePhoto, imageComment }

enum NotificationType { generic, friendRequest, albumInvite }

enum RequestStatus {
  pending(1),
  accepted(2),
  denied(3);

  const RequestStatus(this.val);
  final int val;
}

abstract class Notification extends Equatable {
  final String notificationID;
  final DateTime receivedDateTime;
  final String notificationMediaID;
  final bool notificationSeen;

  const Notification({
    required this.notificationID,
    required this.receivedDateTime,
    required this.notificationMediaID,
    required this.notificationSeen,
  });

  String get imageReq {
    String requestUrl = "$goRepoDomain/image?id=$notificationMediaID";

    return requestUrl;
  }

  String get timeAgoString {
    return timeago.format(receivedDateTime);
  }
}

class AlbumInviteNotification extends Notification {
  final String albumID;
  final String albumName;
  final String albumOwner;
  final String ownerFirst;
  final String ownerLast;
  final RequestStatus status;
  const AlbumInviteNotification({
    required super.notificationID,
    required super.receivedDateTime,
    required super.notificationMediaID,
    required super.notificationSeen,
    required this.albumID,
    required this.albumName,
    required this.albumOwner,
    required this.ownerFirst,
    required this.ownerLast,
    required this.status,
  });

  factory AlbumInviteNotification.fromMap(Map<String, dynamic> map) {
    RequestStatus status = RequestStatus.pending;

    // switch (map['status']) {
    //   case 'accepted':
    //     status = RequestStatus.accepted;
    //   case 'denied':
    //     status = RequestStatus.decline;
    // }
    return AlbumInviteNotification(
      notificationID: map['album_id'],
      receivedDateTime: DateTime.parse(map['received_at']),
      notificationMediaID: map['album_cover_id'],
      notificationSeen: map['request_seen'],
      albumID: map['album_id'],
      albumName: map['album_name'],
      albumOwner: map['album_owner'],
      ownerFirst: map['owner_first'],
      ownerLast: map['owner_last'],
      status: status,
    );
  }

  @override
  List<Object?> get props => [status, notificationSeen];
}

class AlbumInviteResponseNotification extends Notification {
  final String albumID;
  final String albumName;
  final String receiverID;
  final String receiverFirst;
  final String receiverLast;
  final RequestStatus status;

  const AlbumInviteResponseNotification({
    required super.notificationID, // Request ID
    required super.receivedDateTime, // Received At
    required super.notificationMediaID, // AlbumCoverID
    required super.notificationSeen, // Request Seen
    required this.albumID, // Album ID
    required this.albumName, // Album Name
    required this.receiverID, // Receiver ID
    required this.receiverFirst, // Receiver First Name
    required this.receiverLast, // Receiver Last Name
    required this.status, // Request Status
  });

  factory AlbumInviteResponseNotification.fromMap(Map<String, dynamic> map) {
    RequestStatus status = RequestStatus.pending;

    if (map['status'] == 'accepted') {
      status = RequestStatus.accepted;
    }
    if (map['status'] == 'denied') {
      status = RequestStatus.denied;
    }

    return AlbumInviteResponseNotification(
      notificationID: map['request_id'],
      receivedDateTime: DateTime.parse(map['received_at']),
      notificationMediaID: map['album_cover_id'],
      notificationSeen: map['request_seen'],
      albumID: map['album_id'],
      albumName: map['album_name'],
      receiverID: map['receiver_id'],
      receiverFirst: map['receiver_first'],
      receiverLast: map['receiver_last'],
      status: status,
    );
  }

  @override
  List<Object?> get props => [status, notificationSeen];
}

class FriendRequestNotification extends Notification {
  final String senderID;
  final String receiverID;
  final String firstName;
  final String lastName;
  final RequestStatus status;
  const FriendRequestNotification({
    required super.notificationID,
    required super.receivedDateTime,
    required super.notificationMediaID,
    required super.notificationSeen,
    required this.senderID,
    required this.receiverID,
    required this.firstName,
    required this.lastName,
    required this.status,
  });

  String get fullName => '$firstName $lastName';

  String get senderReq => "$goRepoDomain/image?id=$senderID";
  String get receiverReq => "$goRepoDomain/image?id=$receiverID";

  factory FriendRequestNotification.fromMap(Map<String, dynamic> map) {
    RequestStatus status = RequestStatus.pending;

    if (map['status'] == 'accepted') {
      status = RequestStatus.accepted;
    }

    return FriendRequestNotification(
      notificationID: map['request_id'],
      receivedDateTime: DateTime.parse(map['received_at']),
      notificationSeen: map['request_seen'] as bool,
      senderID: map['sender_id'],
      receiverID: map['receiver_id'],
      firstName: map['first_name'],
      lastName: map['last_name'],
      notificationMediaID: map['sender_id'],
      status: status,
    );
  }

  FriendRequestNotification copyWith({
    RequestStatus? status,
    bool? notificationSeen,
  }) {
    return FriendRequestNotification(
      notificationID: notificationID,
      receivedDateTime: receivedDateTime,
      notificationMediaID: notificationMediaID,
      notificationSeen: notificationSeen ?? this.notificationSeen,
      senderID: senderID,
      receiverID: receiverID,
      firstName: firstName,
      lastName: lastName,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [status, notificationSeen];
}
