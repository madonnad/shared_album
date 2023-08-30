import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_photo/bloc/bloc/profile_bloc.dart';

class FriendRequestNotificationComp extends StatelessWidget {
  final int index;
  const FriendRequestNotificationComp({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    double devWidth = MediaQuery.of(context).size.width;
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        String? notificationMediaURL =
            state.myNotifications[index].notificationMediaURL;
        bool isPresent =
            (notificationMediaURL != '' && notificationMediaURL != null);
        return Card(
          elevation: 4,
          shadowColor: const Color.fromRGBO(0, 0, 41, .25),
          clipBehavior: Clip.hardEdge,
          child: Container(
            width: devWidth * .85,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.deepPurple, Colors.cyan],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 20.0, right: 20, top: 12, bottom: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.center,
                          child: CircleAvatar(
                            radius: 35,
                            backgroundImage: isPresent
                                ? NetworkImage(notificationMediaURL)
                                : null,
                            backgroundColor: Colors.white70,
                            child: state.isLoading == true
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : null,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15.0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'friend request',
                                      style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w200),
                                    ),
                                    Text(
                                      state.myNotifications[index]
                                          .formattedDateTime,
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    state.myNotifications[index].notifierName,
                                    style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
                                ),
                                Row(
                                  children: [
                                    FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.deepPurple,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                          horizontal: 20,
                                        ),
                                        minimumSize: Size.zero,
                                      ),
                                      onLongPress: () {},
                                      onPressed: () => print('accept'),
                                      child: Text(
                                        'accept',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(left: 8),
                                    ),
                                    FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: const Color.fromRGBO(
                                            141, 141, 141, 1),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 6,
                                          horizontal: 20,
                                        ),
                                        minimumSize: Size.zero,
                                      ),
                                      onLongPress: () {},
                                      onPressed: () => print('deny'),
                                      child: Text(
                                        'deny',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: const Color.fromRGBO(
                                              211, 211, 211, 1),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}