import 'package:shared_photo/models/user.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class AuthenticationRepository {
  // When supabase is initalized, it creates a singleton instance so you may
  // access that instance anywhere in your app.
  final supabase = supa.Supabase.instance.client;

  AuthenticationRepository();

  Stream<User> get user {
    // We are essentially mapping this event to a user and we use the below logic to do so
    // The if statement returns essentially return to the return
    return supabase.auth.onAuthStateChange.asyncMap((data) async {
      final supa.Session? session = data.session;

      if (session != null) {
        supa.User supaUser = session.user;

        //Retrieve DB info from uid
        Map<String, dynamic> retrievedData =
            await retrieveDatabaseInfo(id: supaUser.id);

        //return the user from the map function
        return mapDataToUser(supaUser: supaUser, retrievedData: retrievedData);
      } else {
        return User.empty;
      }
    });
  }

  User get currentUser {
    final supa.Session? session = supabase.auth.currentSession;

    if (session != null) {
      supa.User supaUser = session.user;

      //return the user from the map function
      return User(id: supaUser.id);
    } else {
      return User.empty;
    }
  }

  Future<Map<String, dynamic>> retrieveDatabaseInfo(
      {required String id}) async {
    final listData = await supabase.from('users').select().eq("user_id", id);

    final data = listData[0];

    return data;
  }

  User mapDataToUser({
    required supa.User supaUser,
    required Map<String, dynamic> retrievedData,
  }) {
    return User(
      id: supaUser.id,
      email: supaUser.email,
      username: supaUser.userMetadata!['username'],
      firstName: retrievedData['first_name'],
      lastName: retrievedData['last_name'],
      avatarUrl: retrievedData['avatar'],
    );
  }

  Future<void> emailSignUp({
    required String email,
    required String password,
    required String username,
  }) async {
    await supabase.auth
        .signUp(email: email, password: password, data: {'username': username});
  }

  Future<void> emailLogin(
      {required String email, required String password}) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}
