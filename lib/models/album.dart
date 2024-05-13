import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_photo/models/notification.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shared_photo/models/guest.dart';
import 'package:shared_photo/models/photo.dart';

enum Visibility { private, public, friends }

enum AlbumPhases { invite, unlock, lock, reveal }

class Album {
  String albumId;
  String albumName;
  String albumOwner;
  String ownerFirst;
  String ownerLast;
  String albumCoverId;
  Map<String, Photo> imageMap;
  Map<String, Guest> guestMap;
  DateTime creationDateTime;
  DateTime lockDateTime;
  DateTime unlockDateTime;
  DateTime revealDateTime;
  String? albumCoverUrl;
  Visibility visibility;
  AlbumPhases phase;

  Album({
    required this.albumId,
    required this.albumName,
    required this.albumOwner,
    required this.ownerFirst,
    required this.ownerLast,
    required this.creationDateTime,
    required this.lockDateTime,
    required this.unlockDateTime,
    required this.revealDateTime,
    required this.visibility,
    required this.phase,
    this.albumCoverId = '',
    this.imageMap = const {},
    this.guestMap = const {},
    this.albumCoverUrl,
  });

  @override
  String toString() {
    return 'Album(albumId: $albumId, albumName: $albumName, albumOwner: $albumOwner,visibility: $visibility, images: $images, creationDateTime: $creationDateTime, lockDateTime: $lockDateTime)';
  }

  static final empty = Album(
    albumId: "",
    albumName: "",
    albumOwner: "",
    ownerFirst: "",
    ownerLast: "",
    creationDateTime: DateTime.utc(1900),
    lockDateTime: DateTime.utc(1900),
    unlockDateTime: DateTime.utc(1900),
    revealDateTime: DateTime.utc(1900),
    visibility: Visibility.public,
    phase: AlbumPhases.invite,
  );

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'album_cover_id': albumCoverId,
      'album_name': albumName,
      'album_owner': albumOwner,
      'unlocked_at': unlockDateTime,
      'locked_at': lockDateTime,
      'revealed_at': revealDateTime,
    };
  }

  factory Album.from(Album album) {
    return Album(
      albumId: album.albumId,
      albumName: album.albumName,
      albumOwner: album.albumOwner,
      ownerFirst: album.ownerFirst,
      ownerLast: album.ownerLast,
      albumCoverId: album.albumCoverId,
      imageMap: album.imageMap,
      guestMap: album.guestMap,
      creationDateTime: album.creationDateTime,
      lockDateTime: album.lockDateTime,
      unlockDateTime: album.unlockDateTime,
      revealDateTime: album.revealDateTime,
      albumCoverUrl: album.albumCoverUrl,
      visibility: album.visibility,
      phase: album.phase,
    );
  }

  factory Album.fromMap(Map<String, dynamic> map) {
    Map<String, Photo> images = {};
    Map<String, Guest> guests = {};
    Visibility visibility;
    AlbumPhases phase;
    dynamic jsonImages = map['images'];
    dynamic jsonGuests = map['invite_list'];

    if (jsonImages != null) {
      for (var item in jsonImages) {
        Photo image = Photo.fromMap(item);

        images.putIfAbsent(image.imageId, () => image);
      }
    }

    if (jsonGuests != null) {
      for (var item in jsonGuests) {
        Guest guest = Guest.fromMap(item);

        guests[guest.uid] = guest;
      }
    }

    switch (map['phase']) {
      case 'invite':
        phase = AlbumPhases.invite;
      case 'unlock':
        phase = AlbumPhases.unlock;
      case 'lock':
        phase = AlbumPhases.lock;
      case 'reveal':
        phase = AlbumPhases.reveal;
      default:
        phase = AlbumPhases.invite;
    }

    switch (map['visibility']) {
      case 'private':
        visibility = Visibility.private;
      case 'friends':
        visibility = Visibility.friends;
      case 'public':
        visibility = Visibility.public;
      default:
        visibility = Visibility.private;
    }

    return Album(
      albumId: map['album_id'] as String,
      albumCoverId: map['album_cover_id'] as String,
      albumName: map['album_name'] as String,
      albumOwner: map['album_owner'] as String,
      ownerFirst: map['owner_first'],
      ownerLast: map['owner_last'],
      creationDateTime: DateTime.parse(map['created_at']),
      guestMap: guests,
      imageMap: images,
      lockDateTime: DateTime.parse(map['locked_at']),
      unlockDateTime: DateTime.parse(map['unlocked_at']),
      revealDateTime: DateTime.parse(map['revealed_at']),
      visibility: visibility,
      phase: phase,
    );
  }

  String get coverReq {
    String requestUrl = "${dotenv.env['URL']}/image?id=$albumCoverId";

    return requestUrl;
  }

  String get ownerImageURl {
    String requestUrl = "${dotenv.env['URL']}/image?id=$albumOwner";

    return requestUrl;
  }

  String get fullName {
    String fullName = "$ownerFirst $ownerLast";

    return fullName;
  }

  List<Guest> get guests => guestMap.values.toList();

  String get timeSince {
    return timeago.format(revealDateTime);
  }

  List<Photo> get images {
    return imageMap.values.toList();
  }

  List<Photo> get rankedImages {
    List<Photo> rankedImages = List.from(images);
    rankedImages.sort((a, b) => b.upvotes.compareTo(a.upvotes));

    return rankedImages;
  }

  List<Photo> get topThreeImages {
    List<Photo> images = List.from(rankedImages);
    if (rankedImages.length > 3) {
      return images.getRange(0, 3).toList();
    } else if (rankedImages.isNotEmpty) {
      return rankedImages.getRange(0, images.length - 1).toList();
    } else {
      return [];
    }
  }

  List<Photo> get remainingRankedImages {
    List<Photo> images = List.from(rankedImages);
    if (rankedImages.length > 3) {
      images.removeRange(0, 3);
      return images;
    } else {
      return [];
    }
  }

  List<List<Photo>> get imagesGroupedByGuest {
    Map<String, List<Photo>> mapImages = {};
    List<List<Photo>> listImages = [];

    for (var item in images) {
      if (!mapImages.containsKey(item.owner)) {
        mapImages[item.owner] = [];
      }
      if (mapImages[item.owner] != null) {
        mapImages[item.owner]!.add(item);
      }
    }

    mapImages.forEach((key, value) {
      value.sort((a, b) => b.upvotes.compareTo(a.upvotes));
    });

    mapImages.forEach((key, value) {
      listImages.add(value);
    });

    return listImages;
  }

  Map<String, int> get imageCountByGuestMap {
    Map<String, int> countMap = {};
    for (Photo item in images) {
      if (countMap.containsKey(item.owner)) {
        countMap[item.owner] = countMap[item.owner]! + 1;
      } else {
        countMap[item.owner] = 1;
      }
    }
    return countMap;
  }

  Map<String, List<List<Photo>>> get imagesGroupByGuestMap {
    Map<String, Map<String, List<Photo>>> mapImages = {};
    Map<String, List<List<Photo>>> dateSortedMap = {};

    for (var item in images) {
      if (mapImages[item.owner] == null) {
        mapImages[item.owner] = {
          item.dateString: [item]
        };
      } else {
        if (mapImages[item.owner]?[item.dateString] != null) {
          mapImages[item.owner]![item.dateString]!.add(item);
        } else {
          mapImages[item.owner]?[item.dateString] = [item];
        }
      }
    }

    mapImages.forEach((userID, dateMap) {
      dateMap.forEach((dateString, imageList) {
        imageList.sort((a, b) => a.uploadDateTime.compareTo(b.uploadDateTime));
      });
      dateSortedMap[userID] = List.from(dateMap.values);
    });

    return dateSortedMap;
  }

  List<List<Photo>> get imagesGroupedSortedByDate {
    Map<String, List<Photo>> mapImages = {};
    List<List<Photo>> listImages = [];

    for (var item in images) {
      if (!mapImages.containsKey(item.dateString)) {
        mapImages[item.dateString] = [];
      }
      if (mapImages[item.dateString] != null) {
        mapImages[item.dateString]!.add(item);
      }
    }

    mapImages.forEach((key, value) {
      value.sort((a, b) => a.uploadDateTime.compareTo(b.uploadDateTime));
    });

    mapImages.forEach((key, value) {
      listImages.add(value);
    });

    return listImages;
  }

  List<Guest> get sortedGuestsByInvite {
    List<Guest> unsortedGuests = List.from(guestMap.values);
    List<Guest> acceptedGuests = unsortedGuests
        .where((element) => element.status == RequestStatus.accepted)
        .toList();
    List<Guest> pendingGuests = unsortedGuests
        .where((element) => element.status == RequestStatus.pending)
        .toList();
    List<Guest> deniedGuests = unsortedGuests
        .where((element) => element.status == RequestStatus.denied)
        .toList();

    List<Guest> sortedGuests = [];
    sortedGuests.addAll(acceptedGuests);
    sortedGuests.addAll(pendingGuests);
    sortedGuests.addAll(deniedGuests);
    return sortedGuests;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Album &&
          runtimeType == other.runtimeType &&
          albumId == other.albumId &&
          mapEquals(guestMap, other.guestMap) &&
          mapEquals(imageMap, other.imageMap);

  @override
  int get hashCode => albumId.hashCode ^ guestMap.hashCode ^ imageMap.hashCode;
}
