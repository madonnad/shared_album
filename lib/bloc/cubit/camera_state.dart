part of 'camera_cubit.dart';

enum UploadMode { unlockedAlbums, singleAlbum }

class CameraState extends Equatable {
  final List<CapturedImage> photosTaken;
  final int? selectedIndex;
  final CapturedImage? selectedImage;
  final Map<String, Album> albumMap;
  final Album? selectedAlbum;
  final TextEditingController captionTextController;
  final bool loading;
  final UploadMode mode;
  const CameraState({
    required this.photosTaken,
    required this.selectedIndex,
    required this.selectedImage,
    required this.albumMap,
    required this.selectedAlbum,
    required this.captionTextController,
    required this.loading,
    required this.mode,
  });

  factory CameraState.empty() {
    return CameraState(
      photosTaken: const [],
      selectedIndex: null,
      selectedImage: null,
      selectedAlbum: null,
      albumMap: HashMap(),
      captionTextController: TextEditingController(),
      loading: false,
      mode: UploadMode.unlockedAlbums,
    );
  }

  CameraState copyWith({
    List<CapturedImage>? photosTaken,
    int? selectedIndex,
    CapturedImage? selectedImage,
    Map<String, Album>? albumMap,
    Album? selectedAlbum,
    TextEditingController? captionTextController,
    bool? loading,
    UploadMode? mode,
  }) {
    return CameraState(
      photosTaken: photosTaken ?? this.photosTaken,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      selectedImage: selectedImage ?? this.selectedImage,
      selectedAlbum: selectedAlbum ?? this.selectedAlbum,
      albumMap: albumMap ?? this.albumMap,
      captionTextController:
          captionTextController ?? this.captionTextController,
      loading: loading ?? this.loading,
      mode: mode ?? this.mode,
    );
  }

  List<CapturedImage> get selectedAlbumImageList {
    return List.from(photosTaken
        .where((element) => element.albumID == selectedAlbum!.albumId));
  }

  List<Album> get unlockedAlbums {
    return albumMap.values.toList();
  }

  int get selectedAlbumIndex {
    if (selectedAlbum != null) {
      return unlockedAlbums
          .indexWhere((element) => element.albumId == selectedAlbum!.albumId);
    }
    return 0;
  }

  Map<String, List<CapturedImage>> get mapOfAlbumImages {
    Map<String, List<CapturedImage>> mapOfAlbImg = {};

    for (CapturedImage image in photosTaken) {
      if (image.albumID != null) {
        mapOfAlbImg
            .putIfAbsent(image.albumID!, () => <CapturedImage>[])
            .add(image);
      }
    }
    return mapOfAlbImg;
  }

  bool get selectedImageRecap {
    if (selectedImage != null) {
      return selectedImage!.addToRecap;
    }
    return false;
  }

  @override
  List<Object?> get props => [
        photosTaken,
        selectedIndex,
        selectedAlbum,
        albumMap,
        selectedImage,
        selectedImageRecap,
        captionTextController,
        loading,
        mode,
      ];
}
