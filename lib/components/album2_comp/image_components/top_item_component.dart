import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_photo/bloc/cubit/image_frame_cubit.dart';
import 'package:shared_photo/bloc/cubit/new_album_frame_cubit.dart';
import 'package:shared_photo/models/album.dart';
import 'package:shared_photo/models/image.dart' as img;
import 'package:shared_photo/screens/image_frame.dart';

class TopItemComponent extends StatelessWidget {
  final double radius;
  final img.Image image;
  final Map<String, String> headers;
  const TopItemComponent({
    super.key,
    required this.image,
    required this.radius,
    required this.headers,
  });

  @override
  Widget build(BuildContext context) {
    Album album = context.read<NewAlbumFrameCubit>().album;
    AlbumViewMode viewMode = context.read<NewAlbumFrameCubit>().state.viewMode;

    int selectedIndex = context
        .read<NewAlbumFrameCubit>()
        .state
        .selectedModeImages
        .indexOf(image);
    return AspectRatio(
      aspectRatio: 4 / 5,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useRootNavigator: true,
                useSafeArea: true,
                builder: (ctx) => BlocProvider(
                  create: (context) => ImageFrameCubit(
                    image: image,
                    album: album,
                    viewMode: viewMode,
                    initialIndex: selectedIndex,
                  ),
                  child: ImageFrame(
                    image: image,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromRGBO(44, 44, 44, .75),
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    image.imageReq,
                    headers: headers,
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              borderRadius: BorderRadius.circular(radius),
              elevation: 2,
              child: CircleAvatar(
                backgroundColor: const Color.fromRGBO(16, 16, 16, 1),
                foregroundImage: CachedNetworkImageProvider(
                  image.avatarReq,
                  headers: headers,
                ),
                radius: radius,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
