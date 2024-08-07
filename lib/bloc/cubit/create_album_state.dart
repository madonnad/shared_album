part of 'create_album_cubit.dart';

enum FriendState {
  empty,
  searching,
}

final class CreateAlbumState extends Equatable {
  final TextEditingController albumName;
  final TextEditingController? friendSearch;
  final String? albumCoverImagePath;
  final String? albumUID;
  final AlbumVisibility visibility;
  // Unlock Date Variables
  final DateTime? unlockDateTime;
  final TimeOfDay? unlockTimeOfDay;
  // Lock Date Variables
  final DateTime? lockDateTime;
  final TimeOfDay? lockTimeOfDay;
  // Reveal Date Variables
  final DateTime? revealDateTime;
  final TimeOfDay? revealTimeOfDay;
  // Friends List
  final Map<String, Friend> friendsMap;
  final List<Friend> invitedFriends;
  final List<Friend> searchResult;
  final FriendState friendState;
  final String modalTextString;
  final bool loading;
  final CustomException exception;

  const CreateAlbumState({
    required this.albumName,
    required this.friendSearch,
    this.albumCoverImagePath,
    this.albumUID,
    // Unlock Date Variables
    this.unlockDateTime,
    this.unlockTimeOfDay,
    // Lock Date Variables
    this.lockDateTime,
    this.lockTimeOfDay,
    // Reveal Date Variables
    this.revealDateTime,
    this.revealTimeOfDay,
    //Friends
    required this.friendsMap,
    this.invitedFriends = const [],
    this.searchResult = const [],
    this.friendState = FriendState.empty,
    this.modalTextString = '',
    this.loading = false,
    this.visibility = AlbumVisibility.public,
    this.exception = CustomException.empty,
  });

  CreateAlbumState copyWith({
    TextEditingController? albumName,
    TextEditingController? friendSearch,
    String? albumCoverImagePath,
    String? albumUID,
    List<Friend>? invitedFriends,
    DateTime? unlockDateTime,
    TimeOfDay? unlockTimeOfDay,
    DateTime? lockDateTime,
    TimeOfDay? lockTimeOfDay,
    String? lockTimeString,
    DateTime? revealDateTime,
    TimeOfDay? revealTimeOfDay,
    Map<String, Friend>? friendsMap,
    List<Friend>? searchResult,
    FriendState? friendState,
    String? modalTextString,
    bool? loading,
    AlbumVisibility? visibility,
    CustomException? exception,
  }) {
    return CreateAlbumState(
      albumName: albumName ?? this.albumName,
      friendSearch: friendSearch ?? this.friendSearch,
      albumCoverImagePath: albumCoverImagePath ?? this.albumCoverImagePath,
      albumUID: albumUID ?? this.albumUID,
      invitedFriends: invitedFriends ?? this.invitedFriends,
      unlockDateTime: unlockDateTime ?? this.unlockDateTime,
      unlockTimeOfDay: unlockTimeOfDay ?? this.unlockTimeOfDay,
      lockDateTime: lockDateTime ?? this.lockDateTime,
      lockTimeOfDay: lockTimeOfDay ?? this.lockTimeOfDay,
      revealDateTime: revealDateTime ?? this.revealDateTime,
      revealTimeOfDay: revealTimeOfDay ?? this.revealTimeOfDay,
      friendsMap: friendsMap ?? this.friendsMap,
      searchResult: searchResult ?? this.searchResult,
      friendState: friendState ?? this.friendState,
      modalTextString: modalTextString ?? this.modalTextString,
      loading: loading ?? this.loading,
      visibility: visibility ?? this.visibility,
      exception: exception ?? this.exception,
    );
  }

  //? Nulling copyWiths

  CreateAlbumState copyWithNullLockDate() {
    return CreateAlbumState(
      albumName: albumName,
      friendSearch: friendSearch,
      albumCoverImagePath: albumCoverImagePath,
      albumUID: albumUID,
      invitedFriends: invitedFriends,
      unlockDateTime: unlockDateTime,
      unlockTimeOfDay: unlockTimeOfDay,
      lockDateTime: null,
      lockTimeOfDay: null,
      revealDateTime: revealDateTime,
      revealTimeOfDay: revealTimeOfDay,
      friendsMap: friendsMap,
      searchResult: searchResult,
      friendState: friendState,
      modalTextString: modalTextString,
      loading: loading,
      visibility: visibility,
      exception: exception,
    );
  }

  CreateAlbumState copyWithNullRevealDate() {
    return CreateAlbumState(
      albumName: albumName,
      friendSearch: friendSearch,
      albumCoverImagePath: albumCoverImagePath,
      albumUID: albumUID,
      invitedFriends: invitedFriends,
      unlockDateTime: unlockDateTime,
      unlockTimeOfDay: unlockTimeOfDay,
      lockDateTime: lockDateTime,
      lockTimeOfDay: lockTimeOfDay,
      revealDateTime: null,
      revealTimeOfDay: null,
      friendsMap: friendsMap,
      searchResult: searchResult,
      friendState: friendState,
      modalTextString: modalTextString,
      loading: loading,
      visibility: visibility,
      exception: exception,
    );
  }

  @override
  List<Object?> get props => [
        albumName,
        friendSearch,
        albumCoverImagePath,
        albumUID,
        invitedFriends,
        unlockDateTime,
        unlockTimeOfDay,
        lockDateTime,
        lockTimeOfDay,
        revealDateTime,
        revealTimeOfDay,
        revealTimeString,
        friendsMap,
        searchResult,
        friendState,
        modalTextString,
        loading,
        visibility,
        exception,
      ];

  bool get canContinue {
    return (albumCoverImagePath != null &&
        unlockDateTime != null &&
        unlockTimeOfDay != null &&
        lockDateTime != null &&
        lockTimeOfDay != null &&
        revealDateTime != null &&
        revealTimeOfDay != null &&
        albumName.text.isNotEmpty);
  }

  bool get canCreate {
    return (albumCoverImagePath != null &&
        unlockDateTime != null &&
        unlockTimeOfDay != null &&
        lockDateTime != null &&
        lockTimeOfDay != null &&
        revealDateTime != null &&
        revealTimeOfDay != null &&
        albumName.text.isNotEmpty);
  }

  //? Friend Getters

  List<String> get invitedUIDList {
    List<String> uidList = invitedFriends.map((e) => e.uid).toList();
    return uidList;
  }

  List<Friend> get friendsList {
    return friendsMap.values.toList();
  }

  //? Date Getters and Formatter

  DateTime get finalLockDateTime {
    DateTime dateTime = DateTime(1900);
    if (lockDateTime != null && lockTimeOfDay != null) {
      dateTime = DateTime(
        lockDateTime!.year,
        lockDateTime!.month,
        lockDateTime!.day,
        lockTimeOfDay!.hour,
        lockTimeOfDay!.minute,
        0,
      );
    }
    return dateTime;
  }

  DateTime get finalUnlockDateTime {
    DateTime dateTime = DateTime(1900);
    if (unlockDateTime != null && unlockTimeOfDay != null) {
      dateTime = DateTime(
        unlockDateTime!.year,
        unlockDateTime!.month,
        unlockDateTime!.day,
        unlockTimeOfDay!.hour,
        unlockTimeOfDay!.minute,
        0,
      );
    }
    return dateTime;
  }

  DateTime get finalRevealDateTime {
    DateTime dateTime = DateTime(1900);
    if (revealDateTime != null && revealTimeOfDay != null) {
      dateTime = DateTime(
        revealDateTime!.year,
        revealDateTime!.month,
        revealDateTime!.day,
        revealTimeOfDay!.hour,
        revealTimeOfDay!.minute,
        0,
      );
    }
    return dateTime;
  }

  String? get unlockDateString {
    String? date;
    if (unlockDateTime != null) {
      date = dateFormatter(unlockDateTime!);
      return date;
    }
    return date = null;
  }

  String? get lockDateString {
    String? date;
    if (lockDateTime != null) {
      date = dateFormatter(lockDateTime!);
      return date;
    }
    return date = null;
  }

  String? get revealDateString {
    String? date;
    if (revealDateTime != null) {
      date = dateFormatter(revealDateTime!);
      return date;
    }
    return date = null;
  }

  String dateFormatter(DateTime dateTime) {
    String dateString;
    if (dateTime.year != DateTime.now().year) {
      dateString = DateFormat("MMM d, ''yy").format(dateTime);
      return dateString;
    }
    return dateString = DateFormat("MMM d").format(dateTime);
  }

  //? Time Getters and Formatter

  String? get unlockTimeString {
    String? time;
    if (unlockTimeOfDay != null) {
      time = timeFormatter(unlockTimeOfDay!);
      return time;
    }
    return time = null;
  }

  String? get lockTimeString {
    String? time;
    if (lockTimeOfDay != null) {
      time = timeFormatter(lockTimeOfDay!);
      return time;
    }
    return time = null;
  }

  String? get revealTimeString {
    String? time;
    if (revealTimeOfDay != null) {
      time = timeFormatter(revealTimeOfDay!);
      return time;
    }
    return time = null;
  }

  String timeFormatter(TimeOfDay time) {
    String hour = time.hour.toString();
    String minute = time.minute.toString();
    String amPm = 'am';
    String timeString;

    if (time.hour % 12 != time.hour) {
      amPm = 'pm';
      hour = (time.hour - 12).toString();
    }

    if (time.hour == 0) {
      amPm = 'am';
      hour = 12.toString();
    }

    if (time.minute < 10) {
      minute = '0${time.minute.toString()}';
    }

    timeString = '$hour:$minute $amPm';
    return timeString;
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>> inviteJson =
        invitedFriends.map((e) => e.toJson()).toList();
    String visibilityString;

    switch (visibility) {
      case AlbumVisibility.public:
        visibilityString = "public";
      case AlbumVisibility.private:
        visibilityString = "private";
      case AlbumVisibility.friends:
        visibilityString = "friends";
    }

    return {
      "album_name": albumName.text,
      "invite_list": inviteJson,
      "unlocked_at": finalUnlockDateTime.toUtc().toIso8601String(),
      "locked_at": finalLockDateTime.toUtc().toIso8601String(),
      "revealed_at": finalRevealDateTime.toUtc().toIso8601String(),
      "visibility": visibilityString,
    };
  }
}
