import 'dart:async';
import 'dart:io';

import 'package:shared_photo/models/album.dart';
import 'package:shared_photo/models/image.dart';
import 'package:shared_photo/models/notification.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class DataRepository {
  final supabase = supa.Supabase.instance.client;

  Future<List<Album>> fetchMyAlbums() async {
    supa.Session? session = supabase.auth.currentSession;
    final List<Album> albums = [];

    if (session != null) {
      String uid = session.user.id;

      dynamic response = await supabase
          .from('albums')
          .select('*, albumuser!inner(album_id)')
          .eq('albumuser.user_id', uid)
          .order('created_at', ascending: false);

      for (var item in response) {
        Album album = Album.fromMap(item);
        albums.add(album);
      }
    }
    return albums;
  }

  Stream<(bool, String)> receivedAlbumRequest() {
    final controller = StreamController<(bool, String)>();
    String uid = supabase.auth.currentSession != null
        ? supabase.auth.currentUser!.id
        : '';

    supabase.channel('public:album_requests').on(
      supa.RealtimeListenTypes.postgresChanges,
      supa.ChannelFilter(
          event: 'INSERT',
          schema: 'public',
          table: 'album_requests',
          filter: 'invited_id=eq.$uid'),
      (payload, [ref]) {
        String albumId = payload['new']['album_id'];

        controller.add((true, albumId));
      },
    ).subscribe();
    return controller.stream;
  }

  Future<Notification> getReceivedNotification(
      NotificationType type, String identifier) async {
    switch (type) {
      case NotificationType.albumInvite:
        dynamic response = await supabase
            .from('album_requests_query')
            .select()
            .eq('album_id', identifier);

        AlbumInviteNotification albumInviteNotification =
            AlbumInviteNotification.fromMap(response[0]);

        return albumInviteNotification;
      case NotificationType.friendRequest:
        throw Exception('Not handled yet');
      case NotificationType.generic:
        throw Exception('Not handled yet');
    }
  }

  Future<List<Notification>> fetchMyNotifications() async {
    supa.Session? session = supabase.auth.currentSession;
    List<Notification> notificationList = [];
    if (session != null) {
      try {
        dynamic response = await supabase.from('album_requests_query').select();
        for (var item in response) {
          AlbumInviteNotification albumInviteNotification =
              AlbumInviteNotification.fromMap(item);
          notificationList.add(albumInviteNotification);
        }
        response = await supabase.from('friend_requests_query').select();
        for (var item in response) {
          FriendRequestNotification friendRequestNotification =
              FriendRequestNotification.fromMap(item);
          notificationList.add(friendRequestNotification);
        }
        response = await supabase.from('notification_query').select();
        for (var item in response) {
          GenericNotification genericNotification =
              GenericNotification.fromMap(item);
          notificationList.add(genericNotification);
        }
      } catch (e) {
        print(e);
      }
    }
    return notificationList;
  }

  // Todo - Implement a feedAlbumFetch that does not fetch just the user's albums
  Future<List<Album>> feedAlbumFetch(
      {required int from, required int to}) async {
    supa.Session? session = supabase.auth.currentSession;
    final List<Album> albums = [];

    if (session != null) {
      String uid = session.user.id;

      // will fetch as many albums as possible
      dynamic response = await supabase
          .from('albums')
          .select('*, albumuser!inner(album_id)')
          .eq('albumuser.user_id', uid)
          .order('created_at', ascending: false)
          .range(from, to);

      // Calls the listOfImageFetch to gather the image information
      for (var item in response) {
        Album album = Album.fromMap(item);
        album.images =
            await listOfImageFetch(albumId: album.albumId, numToFetch: 3);
        if (album.albumCoverId.isNotEmpty) {
          album.albumCoverUrl = await fetchSignedUrl(album.albumCoverId);
        }
        albums.add(album);
      }
    }
    return albums;
  }

  Future<List<Image>> listOfImageFetch(
      {required String albumId, required int numToFetch}) async {
    supa.Session? session = supabase.auth.currentSession;
    final List<Image> images = [];

    if (session != null) {
      try {
        List<dynamic> response = await supabase
            .from('images')
            .select('*, imagealbum!inner(album_id)')
            .eq('imagealbum.album_id', albumId)
            .order('upvotes', ascending: false);

        if (response.isEmpty) {
          return images;
        }

        for (var item in response) {
          Image image = Image.fromMap(item);
          image.imageUrl = await supabase.storage
              .from('images')
              .createSignedUrl(image.imageId, (60 * 100));
          images.add(image);
        }
      } catch (e) {
        print(e);
      }
    }

    return images;
  }

  Future<String> fetchSignedUrl(String imageId) async {
    String imageUrl = '';

    if (imageId == '') {
      return imageUrl;
    }

    try {
      imageUrl = await supabase.storage
          .from('images')
          .createSignedUrl(imageId, (60 * 100));
      return imageUrl;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String> createNewImageRecord({
    required String uid,
    int upvotes = 0,
    String caption = '',
  }) async {
    String imageUID = '';
    try {
      dynamic response = await supabase.from('images').insert({
        'image_owner': uid,
        'caption': caption,
        'upvotes': upvotes,
      }).select();
      imageUID = response[0]['image_id'];
    } catch (e) {
      print(e);
    }

    return imageUID;
  }

  Future<bool> insertImageToBucket(
      {required String imageUID, required File filePath}) async {
    String path = '';
    try {
      path = await supabase.storage.from('images').upload(imageUID, filePath);
      return true;
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<String> createAlbumRecord(Album album) async {
    String albumId = '';
    try {
      Map<String, dynamic> mapped = album.toMap();
      dynamic response = await supabase
          .from('albums')
          .insert([album.toMap()]).select('album_id');
      return albumId = response[0]['album_id'];
    } catch (e) {
      print(e);
    }
    return albumId;
  }

  Future<void> addUsersToAlbum({
    required String creatorUid,
    required List<String> friendUids,
    required String albumUid,
  }) async {
    try {
      List<String> uidList = [creatorUid, ...friendUids];
      dynamic uidMap = uidList
          .map(
            (e) => {
              'album_id': albumUid,
              'user_id': e,
            },
          )
          .toList();
      await supabase.from('albumuser').insert(uidMap);
    } catch (e) {
      print(e);
    }
  }
}
