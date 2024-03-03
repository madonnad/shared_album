import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_photo/bloc/cubit/image_frame_cubit.dart';
import 'package:shared_photo/bloc/cubit/album_frame_cubit.dart';
import 'package:shared_photo/models/album.dart';
import 'package:shared_photo/models/image.dart' as img;
import 'package:shared_photo/repositories/data_repository/data_repository.dart';
import 'package:shared_photo/screens/image_frame.dart';

class GuestItemComponent extends StatelessWidget {
  final img.Image image;
  final Map<String, String> headers;

  const GuestItemComponent({
    super.key,
    required this.image,
    required this.headers,
  });

  @override
  Widget build(BuildContext context) {
    Album album = context.read<AlbumFrameCubit>().album;
    AlbumViewMode viewMode = context.read<AlbumFrameCubit>().state.viewMode;

    int selectedIndex =
        context.read<AlbumFrameCubit>().state.selectedModeImages.indexOf(image);
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useRootNavigator: true,
          useSafeArea: true,
          builder: (ctx) => BlocProvider(
            create: (context) => ImageFrameCubit(
              dataRepository: context.read<DataRepository>(),
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
      child: AspectRatio(
        aspectRatio: 4 / 5,
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
    );
  }
}
