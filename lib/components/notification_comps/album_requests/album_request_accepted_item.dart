import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_photo/bloc/bloc/app_bloc.dart';
import 'package:shared_photo/bloc/cubit/notification_cubit.dart';
import 'package:shared_photo/components/notification_comps/notification_button.dart';
import 'package:gap/gap.dart';

class AlbumRequestAcceptedItem extends StatelessWidget {
  final String profileImage;
  final String albumCover;
  final String firstName;
  final String albumName;
  final String requestID;
  final String timeUntil;
  const AlbumRequestAcceptedItem({
    super.key,
    required this.profileImage,
    required this.albumCover,
    required this.firstName,
    required this.albumName,
    required this.requestID,
    required this.timeUntil,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      height: 100,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(19, 19, 19, 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color.fromRGBO(44, 44, 44, 1),
                foregroundImage: NetworkImage(
                  profileImage,
                  headers: context.read<AppBloc>().state.user.headers,
                ),
                onForegroundImageError: (_, __) {},
              ),
              const SizedBox(height: 25),
            ],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "$firstName is inviting you to",
                    style: GoogleFonts.josefinSans(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    albumName,
                    style: GoogleFonts.josefinSans(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Row(
                  children: [
                    NotificationButton(
                      buttonText: "Accepted",
                      backgroundColor: const Color.fromRGBO(19, 19, 19, 1),
                      borderColor: const Color.fromRGBO(181, 131, 141, 1),
                      onTap: () => context
                          .read<NotificationCubit>()
                          .acceptAlbumInvite(requestID: requestID),
                    ),
                    const Gap(10),
                    Text(
                      "Unlocks in $timeUntil",
                      style: GoogleFonts.josefinSans(
                        color: const Color.fromRGBO(181, 131, 141, 1),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: AspectRatio(
              aspectRatio: 60 / 65,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(44, 44, 44, 1),
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: NetworkImage(
                      albumCover,
                      headers: context.read<AppBloc>().state.user.headers,
                    ),
                    fit: BoxFit.cover,
                    onError: (_, __) {},
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}