import 'package:shared_photo/bloc/cubit/album_frame_cubit.dart';
import 'package:shared_photo/bloc/cubit/image_frame_cubit.dart';
import 'package:shared_photo/components/image_page_comp/image_frame_comments/floating_comment_container.dart';
import 'package:shared_photo/components/image_page_comp/image_frame_comments/image_frame_caption.dart';
import 'package:shared_photo/components/image_page_comp/image_frame_comments/image_frame_comment.dart';
import 'package:shared_photo/components/image_page_comp/image_frame_container/image_frame_image_container.dart';
import 'package:shared_photo/components/image_page_comp/image_frame_control_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_photo/bloc/bloc/app_bloc.dart';
import 'package:shared_photo/components/image_page_comp/image_frame_dialog/image_frame_dialog.dart';
import 'package:shared_photo/models/album.dart';

class ImageFrame extends StatelessWidget {
  const ImageFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AlbumFrameCubit, AlbumFrameState>(
      listenWhen: (previous, current) {
        return previous.selectedImage != current.selectedImage;
      },
      listener: (context, state) {
        context
            .read<ImageFrameCubit>()
            .changeImageFrameState(state.selectedImage!);
      },
      child: BlocBuilder<ImageFrameCubit, ImageFrameState>(
        builder: (context, state) {
          Map<String, String> headers =
              context.read<AppBloc>().state.user.headers;
          return SizedBox(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                const Expanded(
                  child: AspectRatio(
                    aspectRatio: 9 / 16,
                    child: ImageFrameImageContainer(),
                  ),
                ),
                BlocBuilder<AlbumFrameCubit, AlbumFrameState>(
                  builder: (context, albumState) {
                    return Container(
                      height: MediaQuery.of(context).size.height * .08,
                      margin: const EdgeInsets.only(top: 15, bottom: 15),
                      child: Stack(
                        children: [
                          PageView.builder(
                            controller: albumState.miniMapController,
                            itemCount: albumState.imageFrameTimelineList.length,
                            itemBuilder: (context, index) {
                              bool isImage =
                                  albumState.selectedImage?.imageId ==
                                      albumState.imageFrameTimelineList[index]
                                          .imageId;
                              return GestureDetector(
                                onTap: () {
                                  context
                                      .read<AlbumFrameCubit>()
                                      .updateImageFrameWithSelectedImage(
                                        index,
                                        changeMiniMap: true,
                                        changeMainPage: true,
                                      );
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(19, 19, 19, 1),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        albumState.imageFrameTimelineList[index]
                                            .imageReqSmallSize,
                                        headers: context
                                            .read<AppBloc>()
                                            .state
                                            .user
                                            .headers,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: isImage
                                          ? const Color.fromRGBO(
                                              255, 205, 178, 1)
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              height: MediaQuery.of(context).size.height * .08,
                              padding: const EdgeInsets.only(left: 8),
                              color: Colors.black,
                              child: GestureDetector(
                                onTap: () => showDialog(
                                  context: context,
                                  barrierColor: Colors.black87,
                                  builder: (ctx) => BlocProvider.value(
                                    value: BlocProvider.of<AlbumFrameCubit>(
                                        context),
                                    child: const ImageFrameDialog(),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.view_timeline,
                                  size: 30,
                                  color: Color.fromRGBO(225, 225, 225, 1),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
