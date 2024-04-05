import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_photo/bloc/bloc/app_bloc.dart';
import 'package:shared_photo/bloc/cubit/album_frame_cubit.dart';
import 'package:shared_photo/models/guest.dart';

class InvitePage extends StatelessWidget {
  const InvitePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0, left: 30, right: 30),
        child: BlocBuilder<AlbumFrameCubit, AlbumFrameState>(
          builder: (context, state) {
            return ListView.builder(
              itemCount: state.album.sortedGuestsByInvite.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor:
                                const Color.fromRGBO(16, 16, 16, 1),
                            foregroundImage: NetworkImage(
                              state.album.sortedGuestsByInvite[index].avatarReq,
                              headers:
                                  context.read<AppBloc>().state.user.headers,
                            ),
                            onForegroundImageError: (_, __) {},
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            state.album.sortedGuestsByInvite[index].fullName,
                            style: GoogleFonts.josefinSans(
                              color: state.album.sortedGuestsByInvite[index]
                                          .status ==
                                      InviteStatus.accept
                                  ? Colors.white
                                  : const Color.fromRGBO(125, 125, 125, 1),
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      switch (state.album.sortedGuestsByInvite[index].status) {
                        InviteStatus.accept =>
                          const Icon(Icons.check_circle, color: Colors.green),
                        InviteStatus.pending => const Icon(
                            Icons.help_outline_outlined,
                            color: Color.fromRGBO(125, 125, 125, 1)),
                        InviteStatus.decline =>
                          const Icon(Icons.cancel, color: Colors.red)
                      }
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
