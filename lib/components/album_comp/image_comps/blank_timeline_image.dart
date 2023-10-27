import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_photo/bloc/bloc/album_bloc.dart';
import 'package:shared_photo/bloc/bloc/app_bloc.dart';

class BlankTimelineImage extends StatelessWidget {
  final int index;
  final Map<String, String> header;

  const BlankTimelineImage({
    super.key,
    required this.index,
    required this.header,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlbumBloc, AlbumState>(
      builder: (context, state) {
        return AspectRatio(
          aspectRatio: 1,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * .6,
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        RotatedBox(
                          quarterTurns: 3,
                          child: Text(
                            state.album.images[index].timeString,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w300,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        const Column(
                          children: [
                            Icon(
                              Icons.favorite,
                              color: Colors.black38,
                            ),
                            Icon(
                              Icons.arrow_circle_up,
                              color: Colors.black38,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 12,
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    clipBehavior: Clip.hardEdge,
                    child: Container(
                      padding: const EdgeInsets.only(bottom: 25),
                      height: MediaQuery.of(context).size.height * .6,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
