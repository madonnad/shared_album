import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_photo/bloc/cubit/image_frame_cubit.dart';

class ImageFrameMetadataRow extends StatelessWidget {
  const ImageFrameMetadataRow({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageFrameCubit, ImageFrameState>(
      builder: (context, state) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          textBaseline: TextBaseline.alphabetic,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.favorite,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  state.selectedImage.upvotes.toString(),
                  style: GoogleFonts.josefinSans(
                    fontSize: 18,
                    color: Colors.white,
                    textBaseline: TextBaseline.alphabetic,
                  ),
                ),
              ],
            ),
            Text(
              state.selectedImage.dateString,
              style: GoogleFonts.josefinSans(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(.75),
                textBaseline: TextBaseline.alphabetic,
              ),
            )
          ],
        );
      },
    );
  }
}