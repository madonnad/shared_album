import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CustomCamPreview extends StatefulWidget {
  final CameraController controller;
  final double maxZoom;
  final double minZoom;
  const CustomCamPreview(
      {super.key,
      required this.controller,
      required this.maxZoom,
      required this.minZoom});

  @override
  State<CustomCamPreview> createState() => _CustomCamPreviewState();
}

class _CustomCamPreviewState extends State<CustomCamPreview> {
  double currentZoom = 1;
  double previousScale = 1;
  bool showRing = false;
  Offset? focusOffset;
  double? widgetHeight;
  double? widgetWidth;

  @override
  void initState() {
    super.initState();
  }

  void pinchEnd(ScaleEndDetails details) async {
    setState(() {
      previousScale = 1;
    });
  }

  void pinchUpdate(ScaleUpdateDetails details) async {
    double newScale = 0;
    double newZoom = 0;

    if (details.scale == 1) return;

    newScale = details.scale - previousScale;
    if (newScale < 1) {
      newScale = newScale * 6;
    }
    newZoom = currentZoom + newScale;

    if (newZoom > widget.maxZoom) {
      newZoom = widget.maxZoom;
    }

    if (newZoom < widget.minZoom) {
      newZoom = widget.minZoom;
    }

    setState(() {
      currentZoom = newZoom;
      previousScale = details.scale;
    });

    await widget.controller.setZoomLevel(currentZoom);
  }

  @override
  Widget build(BuildContext context) {
    //final size = MediaQuery.of(context).size;
    //final RenderBox box = context.findRenderObject() as RenderBox;

    Future<void> setFocusPoint(TapDownDetails details) async {
      double? height = context.size?.height;
      double? width = context.size?.width;

      if (width != null && height != null) {
        double dx = details.localPosition.dx / width;
        double dy = details.localPosition.dy / height;
        Offset offset = Offset(dx, dy);

        setState(() {
          widgetWidth = width;
          widgetHeight = height;
          focusOffset = offset;
          showRing = true;
        });

        await widget.controller.setFocusPoint(Offset(dx, dy));
        await widget.controller.setFocusMode(FocusMode.auto);

        await Future.delayed(Duration(milliseconds: 700));

        setState(() {
          showRing = false;
        });
        // setState(() {
        //   focusOffset = null;
        // });
      }
    }

    return Container(
      //width: size.width,
      //height: size.height,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          GestureDetector(
            onScaleEnd: pinchEnd,
            onScaleUpdate: pinchUpdate,
            onTapDown: (details) => setFocusPoint(details),
            child: CameraPreview(widget.controller),
          ),
          (focusOffset != null && widgetWidth != null && widgetHeight != null)
              ? Positioned(
                  top: focusOffset!.dy * widgetHeight! - 25,
                  left: focusOffset!.dx * widgetWidth! - 25,
                  child: IgnorePointer(
                    ignoring: !showRing,
                    child: AnimatedOpacity(
                      opacity: showRing ? 1 : 0,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeInCubic,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(35),
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        height: 50,
                        width: 50,
                      ),
                    ),
                  ),
                )
              : SizedBox.shrink(),
        ],
      ),
    );
  }
}
