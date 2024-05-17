import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_photo/bloc/bloc/app_bloc.dart';
import 'package:shared_photo/bloc/cubit/camera_cubit.dart';
import 'package:shared_photo/components/camera_comp/edit_screen_comp/captured_edit_screen.dart';
import 'package:shared_photo/models/album.dart';
import 'package:shared_photo/repositories/data_repository/data_repository.dart';

class ForgotShotFab extends StatelessWidget {
  final Album album;
  const ForgotShotFab({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (ctx) {
          return BlocProvider(
            create: (context) => CameraCubit(
              dataRepository: context.read<DataRepository>(),
              user: context.read<AppBloc>().state.user,
              mode: UploadMode.singleAlbum,
              album: album,
            ),
            child: const CapturedEditScreen(),
          );
        },
      ),
      child: Container(
        height: 69,
        width: 69,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: Color.fromRGBO(19, 19, 19, 1),
          //borderRadius: BorderRadius.circular(10),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Color.fromRGBO(44, 44, 44, .5),
              blurRadius: 15,
              spreadRadius: 15,
            )
          ],
        ),
        child: const Text(
          '😅',
          style: TextStyle(fontSize: 32),
        ),
      ),
    );
  }
}
