import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:shared_photo/bloc/cubit/camera_cubit.dart';
import 'package:shared_photo/components/camera_comp/active_album_dropdown.dart';
import 'package:shared_photo/components/camera_comp/camera_utils/camera_controls.dart';
import 'package:shared_photo/components/camera_comp/camera_utils/no_albums_overlay.dart';
import 'package:shared_photo/components/camera_comp/custom_cam_preview.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const CameraScreen({
    super.key,
    required this.cameras,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController controller;
  bool isCameraBack = false;
  double minZoom = 0;
  double maxZoom = 1;
  double currentZoom = 0;

  @override
  void initState() {
    print(widget.cameras);
    CameraDescription camera = widget.cameras.isNotEmpty
        ? widget.cameras[0]
        : const CameraDescription(
            name: 'empty',
            lensDirection: CameraLensDirection.back,
            sensorOrientation: 0,
          );
    controller = CameraController(
      camera,
      ResolutionPreset.max,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    super.initState();
    Future.microtask(() async {
      await initializeCameraController();
    });
  }

  Future<void> initializeCameraController() async {
    await controller.initialize();
    await lockOrientation();
    await setZoomValues();
    await controller.setFlashMode(FlashMode.auto);
    await controller.setFocusMode(FocusMode.auto);
  }

  Future<void> lockOrientation() async {
    await controller.lockCaptureOrientation(DeviceOrientation.portraitUp);
  }

  Future<void> setZoomValues() async {
    await controller.getMinZoomLevel().then((value) => setState(() {
          minZoom = value;
          currentZoom = value;
        }));
    await controller.getMaxZoomLevel().then((value) => setState(() {
          maxZoom = value.floor().toDouble();
          if (maxZoom > 5) {
            maxZoom = 5;
          }
        }));

    await controller.setZoomLevel(currentZoom);
  }

  @override
  void dispose() {
    controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    super.dispose();
  }

  void changeCameraDirection() async {
    setState(() {
      isCameraBack = !isCameraBack;
    });

    int cameraSelect = isCameraBack ? 1 : 0;

    controller = CameraController(
      widget.cameras[cameraSelect],
      ResolutionPreset.max,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    if (mounted) {
      Future.microtask(() async {
        await initializeCameraController();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraCubit, CameraState>(
      builder: (context, state) {
        // final size = MediaQuery.of(context).size;
        return Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).viewPadding.top,
                ),
                ActiveAlbumDropdown(
                  opacity: .25,
                ),
                Gap(10),
                (controller.value.isInitialized)
                    ? Expanded(
                        child: AspectRatio(
                          aspectRatio: 4 / 3,
                          child: GestureDetector(
                            onDoubleTap: () => changeCameraDirection(),
                            child: CustomCamPreview(
                              controller: controller,
                              maxZoom: maxZoom,
                              minZoom: minZoom,
                            ),
                          ),
                        ),
                      )
                    : Expanded(
                        child: Container(
                          color: Colors.black,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                Gap(10),
                CameraControls(
                  controller: controller,
                  flipCamera: changeCameraDirection,
                ),
                SizedBox(
                  height: 120,
                ),
              ],
            ),
            const NoAlbumsOverlay(),
          ],
        );
      },
    );
  }
}
