import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_photo/models/friend.dart';
import 'package:http/http.dart' as http;

class UserService {
  static Future<(int, String?)> createUserEntry(
      String token, String firstName, String lastName, String email) async {
    final Map<String, String> requestBodyJson = {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
    };
    String encodedBody = json.encode(requestBodyJson);

    final Map<String, String> headers = {'Authorization': 'Bearer $token'};

    String urlString = "${dotenv.env['URL']}/user";
    Uri url = Uri.parse(urlString);

    try {
      final response =
          await http.post(url, headers: headers, body: encodedBody);

      if (response.statusCode == 200) {
        return (response.statusCode, null);
      } else {
        return (response.statusCode, response.body);
      }
    } catch (e) {
      return (401, e.toString());
    }
  }

  static Future<(String?, String?, String?)> updateUsersName(
      String token, String firstName, String lastName) async {
    String urlString =
        "${dotenv.env['URL']}/user?first=$firstName&last=$lastName";
    Uri url = Uri.parse(urlString);

    final Map<String, String> headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await http.patch(url, headers: headers);

      if (response.statusCode == 200) {
        return (firstName, lastName, null);
      } else {
        String code = response.statusCode.toString();
        String body = response.body;
        return (null, null, '$code: $body');
      }
    } catch (e) {
      return (null, null, e.toString());
    }
  }

  static Future<List<Friend>> getFriendsList(String token) async {
    final List<Friend> friends = [];

    String urlString = "${dotenv.env['URL']}/user/friend";
    Uri url = Uri.parse(urlString);

    final Map<String, String> headers = {'Authorization': 'Bearer $token'};
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final responseBody = response.body;

      final jsonData = json.decode(responseBody);
      if (jsonData == null) {
        return friends;
      }

      for (var item in jsonData) {
        friends.add(Friend.fromJson(item));
      }
      //print(friends);
      return friends;
    }
    String code = response.statusCode.toString();
    String body = response.body;
    developer.log("$code: $body");
    return friends;
  }

  static Future<AnonymousFriend> getSearchedUser(
      String token, String uid) async {
    // var url = Uri.https(dotenv.env['DOMAIN'] ?? '', '/user/id', {'id': uid});
    String urlString = "${dotenv.env['URL']}/user/id?id=$uid";
    Uri url = Uri.parse(urlString);

    final Map<String, String> headers = {'Authorization': 'Bearer $token'};

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final responseBody = response.body;

        final jsonData = json.decode(responseBody);

        return AnonymousFriend.fromJson(jsonData);
      }
      String code = response.statusCode.toString();
      String body = response.body;
      developer.log("$code: $body");
      return AnonymousFriend.empty;
    } catch (e) {
      return AnonymousFriend.empty;
    }
  }
}
