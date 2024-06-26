part of './data_repository.dart';

enum ImageChangeKey { userLikedUpdate, likeCountUpdate }

extension ImageDataRepo on DataRepository {
  Future<List<CapturedImage>> addImageToAlbum(
      List<CapturedImage> imagesToUpload) async {
    List<CapturedImage> failedUploads = [];

    for (int i = 0; i < imagesToUpload.length; i++) {
      CapturedImage image = imagesToUpload[i];

      if (image.album == null) {
        failedUploads.add(image);
        continue;
      }

      if (albumMap[image.album!.albumId] == null) {
        failedUploads.add(image);
        continue;
      }

      String albumID = image.album!.albumId;

      try {
        Photo? uploadedImage =
            await ImageService.postCapturedImage(user.token, image);
        if (uploadedImage == null) {
          throw false;
        }

        imagesToUpload.removeAt(i);

        Map<String, Photo> albumImages = albumMap[albumID]!.imageMap;
        albumImages[uploadedImage.imageId] = uploadedImage;

        ImageChange change = ImageChange(
          albumID: albumID,
          imageID: uploadedImage.imageId,
          image: uploadedImage,
        );

        _imageController.add(change);

        i--;
      } catch (e) {
        failedUploads.add(image);
        continue;
      }
    }
    return failedUploads;
  }

  Future<void> moveImageToAlbum(
      String imageID, String newAlbum, String oldAlbum) async {
    if (albumMap[oldAlbum] == null || albumMap[newAlbum] == null) return;

    bool success =
        await ImageService.moveImageToAlbum(user.token, imageID, newAlbum);

    if (success) {
      Photo foundImage = albumMap[oldAlbum]!
          .images
          .firstWhere((image) => image.imageId == imageID);

      // Remove Image from Old Album
      albumMap[oldAlbum]!.imageMap.remove(foundImage.imageId);

      // Add Image to New Album
      albumMap[newAlbum]!.imageMap[foundImage.imageId] = foundImage;
      _albumController.add((StreamOperation.update, albumMap[oldAlbum]!));
      _albumController.add((StreamOperation.update, albumMap[newAlbum]!));
    }
  }

  // Initalize and Coordinate Storage of Comments
  Future<Map<String, Comment>> initalizeCommentsAndStore(
      String albumID, String imageID) async {
    Map<String, Comment> commentMap = {};

    if (albumMap[albumID]?.imageMap[imageID] != null) {
      if (albumMap[albumID]!.imageMap[imageID]!.commentMap.isEmpty) {
        // Fetch List from Service
        List<Comment> imageComments =
            await EngagementService.getImageComments(user.token, imageID);

        // Transform List to Map
        commentMap = {
          for (Comment comment in imageComments) comment.id: comment,
        };

        albumMap[albumID]!.imageMap[imageID]!.commentMap = commentMap;

        return commentMap;
      } else {
        return albumMap[albumID]!.imageMap[imageID]!.commentMap;
      }
    }
    return commentMap;
  }

  Future<Comment?> addCommentToImage(
      String albumID, String imageID, String comment) async {
    Comment? postedComment =
        await EngagementService.postNewComment(user.token, imageID, comment);

    if (postedComment == null) return postedComment;

    if (albumMap[albumID]?.imageMap[imageID] != null) {
      Photo image = albumMap[albumID]!.imageMap[imageID]!;

      image.commentMap[postedComment.id] = postedComment;
    }

    return postedComment;
  }

  Future<(bool, int)> toggleImageLike(
      String albumID, String imageID, bool currentStatus) async {
    late bool userLiked;
    late int newCount;

    if (albumMap[albumID]?.imageMap[imageID] != null) {
      Photo image;
      if (currentStatus) {
        newCount = await EngagementService.unlikePhoto(user.token, imageID);
        userLiked = false;
      } else {
        newCount = await EngagementService.likePhoto(user.token, imageID);
        userLiked = true;
      }

      // Update Repo Store
      image = albumMap[albumID]!.imageMap[imageID]!;

      image.userLiked = userLiked;
      image.likes = newCount;
      albumMap[albumID]!.imageMap[imageID] = image;

      ImageChange imageChange =
          ImageChange(albumID: albumID, imageID: imageID, image: image);
      _imageController.add(imageChange);
      return (userLiked, newCount);
    }

    //Return to Image Cubit
    newCount = 0;
    userLiked = false;
    return (userLiked, newCount);
  }

  Future<(bool, int)> toggleImageUpvote(
      String albumID, String imageID, bool currentStatus) async {
    late bool userUpvoted;
    late int newCount;

    if (albumMap[albumID]?.imageMap[imageID] != null) {
      Photo image;
      if (currentStatus) {
        newCount =
            await EngagementService.removeUpvoteFromPhoto(user.token, imageID);
        userUpvoted = false;
      } else {
        newCount = await EngagementService.upvotePhoto(user.token, imageID);
        userUpvoted = true;
      }

      // Update Repo Store
      image = albumMap[albumID]!.imageMap[imageID]!;

      image.userUpvoted = userUpvoted;
      image.upvotes = newCount;
      albumMap[albumID]!.imageMap[imageID] = image;

      ImageChange imageChange =
          ImageChange(albumID: albumID, imageID: imageID, image: image);
      _imageController.add(imageChange);
      return (userUpvoted, newCount);
    }

    //Return to Image Cubit
    newCount = 0;
    userUpvoted = false;
    return (userUpvoted, newCount);
  }

  void _handleImageComment(CommentNotification notification) {
    switch (notification.operation) {
      case EngageOperation.add:
        Comment comment = Comment.fromCommentNotification(notification);

        String albumID = notification.albumID;
        String imageID = notification.notificationMediaID;

        if (albumMap[albumID]?.imageMap[imageID] != null) {
          Photo image = albumMap[albumID]!.imageMap[imageID]!;

          image.commentMap[comment.id] = comment;

          ImageChange imageChange =
              ImageChange(albumID: albumID, imageID: imageID, image: image);
          _imageController.add(imageChange);
        }
        return;
      case EngageOperation.remove:
      // TODO: Handle this case.
      case EngageOperation.update:
      // TODO: Handle this case.
    }
  }

  void _handleImageEngagement(EngagementNotification notification) {
    switch (notification.notificationType) {
      case EngageType.liked:
        String imageID = notification.notificationMediaID;
        String albumID = notification.albumID;
        EngageOperation operation = notification.operation;

        if (albumMap[albumID]?.imageMap[imageID] == null) return;

        Photo image = albumMap[albumID]!.imageMap[imageID]!;

        switch (operation) {
          case EngageOperation.add:
            // Add the upvote to the upvote count
            image.likes = notification.newCount;

            // Check if the person who upvote is in the list - if not then add
            if (image.upvotesUID
                .any((element) => element.uid != notification.notifierID)) {
              String uid = notification.notifierID;
              String firstName = notification.notifierFirst;
              String lastName = notification.notifierLast;
              Engager engager =
                  Engager(uid: uid, firstName: firstName, lastName: lastName);

              image.likesUID.add(engager);
            }

            // Add the image back to the global cache
            albumMap[albumID]?.imageMap[imageID] = image;

            // Preapre the ImageChange class for the image stream to update
            ImageChange imageChange =
                ImageChange(albumID: albumID, imageID: imageID, image: image);
            _imageController.add(imageChange);
            return;
          case EngageOperation.remove:
            image.likes = notification.newCount;
            image.likesUID.removeWhere(
                (element) => element.uid == notification.notifierID);

            // Add the image back to the global cache
            albumMap[albumID]?.imageMap[imageID] = image;

            // Preapre the ImageChange class for the image stream to update
            ImageChange imageChange =
                ImageChange(albumID: albumID, imageID: imageID, image: image);
            _imageController.add(imageChange);
            return;
          case EngageOperation.update:
          // TODO: Handle this case.
        }
      case EngageType.upvoted:
        String imageID = notification.notificationMediaID;
        String albumID = notification.albumID;
        EngageOperation operation = notification.operation;

        if (albumMap[albumID]?.imageMap[imageID] == null) return;

        Photo image = albumMap[albumID]!.imageMap[imageID]!;

        switch (operation) {
          case EngageOperation.add:
            // Add the upvote to the upvote count
            image.upvotes = notification.newCount;

            // Check if the person who upvote is in the list - if not then add
            if (image.upvotesUID
                .any((element) => element.uid != notification.notifierID)) {
              String uid = notification.notifierID;
              String firstName = notification.notifierFirst;
              String lastName = notification.notifierLast;
              Engager engager =
                  Engager(uid: uid, firstName: firstName, lastName: lastName);

              image.upvotesUID.add(engager);
            }

            // Add the image back to the global cache
            albumMap[albumID]?.imageMap[imageID] = image;

            // Preapre the ImageChange class for the image stream to update
            ImageChange imageChange =
                ImageChange(albumID: albumID, imageID: imageID, image: image);
            _imageController.add(imageChange);

            return;
          case EngageOperation.remove:
            image.upvotes = notification.newCount;
            image.upvotesUID.removeWhere(
                (element) => element.uid == notification.notifierID);

            // Add the image back to the global cache
            albumMap[albumID]?.imageMap[imageID] = image;

            // Preapre the ImageChange class for the image stream to update
            ImageChange imageChange =
                ImageChange(albumID: albumID, imageID: imageID, image: image);
            _imageController.add(imageChange);
            return;
          case EngageOperation.update:
          // TODO: Handle this case.
        }
    }
  }
}
