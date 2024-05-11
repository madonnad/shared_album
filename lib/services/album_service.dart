import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_photo/bloc/cubit/create_album_cubit.dart';
import 'package:shared_photo/models/album.dart';
import 'package:shared_photo/models/guest.dart';
import 'package:http/http.dart' as http;

class AlbumService {
  static Future<Album?> postNewAlbum(
      String token, CreateAlbumState state) async {
    // print(state.toJson());
    Map<String, dynamic> albumInformation = state.toJson();
    String encodedBody = json.encode(albumInformation);

    //var url = Uri.https(dotenv.env['DOMAIN'] ?? '', '/user/album');
    String urlString = "${dotenv.env['URL']}/user/album";
    Uri url = Uri.parse(urlString);

    final Map<String, String> headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token'
    };

    try {
      final response =
          await http.post(url, headers: headers, body: encodedBody);

      if (response.statusCode == 200) {
        Map<String, dynamic> body = json.decode(response.body);
        return Album.fromMap(body);
      }
      print('Request failed with status: ${response.statusCode}');
      print('Response body: #${response.body}');
      return null;
    } catch (e) {
      print(e);
      return null;
    }
  }

  static Future<List<Album>> getAuthUsersAlbums(String token) async {
    final List<Album> albums = [];
    //var url = Uri.https(dotenv.env['DOMAIN'] ?? '', '/user/album');
    String urlString = "${dotenv.env['URL']}/user/album";
    Uri url = Uri.parse(urlString);

    final Map<String, String> headers = {'Authorization': 'Bearer $token'};

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final responseBody = response.body;

      final jsonData = json.decode(responseBody);
      if (jsonData == null) {
        return albums;
      }

      for (var item in jsonData) {
        Album album = Album.fromMap(item);
        albums.add(album);
      }
      //print(albums);
      return albums;
    }
    throw HttpException(
        "Failed to get users albums with status: ${response.statusCode}");
  }

  static Future<List<Album>> getRevealedAlbumsByAlbumID(
      String token, List<String> albumIds) async {
    final List<Album> albums = [];

    //var url = Uri.https(dotenv.env['DOMAIN'] ?? '', '/album/revealed');
    String urlString = "${dotenv.env['URL']}/album/revealed'";
    Uri url = Uri.parse(urlString);

    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    String encodedBody = json.encode(albumIds);

    try {
      final response =
          await http.post(url, headers: headers, body: encodedBody);

      if (response.statusCode == 200) {
        final responseBody = response.body;
        final jsonData = json.decode(responseBody);
        for (var item in jsonData) {
          Album album = Album.fromMap(item);
          albums.add(album);
        }
        return albums;
      }
      return albums;
    } catch (e) {
      print(e);
      return albums;
    }
  }

  static Future<List<Album>> getFeedAlbums(String token) async {
    final List<Album> albums = [];
    //var url = Uri.https(dotenv.env['DOMAIN'] ?? '', '/feed');
    String urlString = "${dotenv.env['URL']}/feed";
    Uri url = Uri.parse(urlString);
 
    final Map<String, String> headers = {'Authorization': 'Bearer $token'};

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      final responseBody = response.body;

      final jsonData = json.decode(responseBody);

      for (var item in jsonData) {
        Album album = Album.fromMap(item);
        albums.add(album);
      }
      return albums;
    }

    if (response.statusCode == 204) {
      return albums;
    }
    print('Request failed with status: ${response.statusCode}');
    print('Response body: #${response.body}');
    return albums;
  }

  static Future<Album> getAlbumByID(String token, String albumID) async {
    Album album = Album.empty;
    // var url =
    //     Uri.https(dotenv.env['DOMAIN'] ?? '', '/album', {'album_id': albumID});
    String urlString = "${dotenv.env['URL']}/album?album_id=$albumID";
    Uri url = Uri.parse(urlString);


    final Map<String, String> headers = {'Authorization': 'Bearer $token'};

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final responseBody = response.body;

      final jsonData = json.decode(responseBody);
      if (jsonData == null) {
        return album;
      }

      album = Album.fromMap(jsonData);

      return album;
    }
    throw HttpException(
        "Failed to get album by ID with status: ${response.statusCode}");
  }

  static Future<List<Guest>> updateGuestList(
      String token, String albumID) async {
    List<Guest> guests = [];

    // var url = Uri.https(
    //     dotenv.env['DOMAIN'] ?? '', '/album/guests', {"album_id": albumID});
    String urlString = "${dotenv.env['URL']}/album/guests?album_id=$albumID";
    Uri url = Uri.parse(urlString);
    

    final Map<String, String> headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseBody = response.body;
        final jsonData = json.decode(responseBody);

        for (var item in jsonData) {
          guests.add(Guest.fromMap(item));
        }
      }
      return guests;
    } catch (e) {
      print(e);
      return guests;
    }
  }
}
