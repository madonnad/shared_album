part of 'notification_repository.dart';

extension AlbumInviteRepo on NotificationRepository {
  void _ablumInviteHandler(AlbumInviteNotification invite) {
    switch (invite.status) {
      case RequestStatus.pending:
        albumInviteMap.putIfAbsent(invite.notificationID, () => invite);
        _notificationController.add((StreamOperation.add, invite));
      case RequestStatus.accepted:
      case RequestStatus.denied:
    }
  }

  Future<bool> acceptAlbumInvite(String requestID) async {
    bool success =
        await RequestService.acceptAlbumInvite(user.token, requestID);

    if (success) {
      // Update Source of Truth
      albumInviteMap.update(
          requestID, (value) => value.copyWith(status: RequestStatus.accepted));
      // Notify Listeners Locally
      _notificationController
          .add((StreamOperation.update, albumInviteMap[requestID]!));
      return true;
    }
    return false;
  }

  Future<bool> denyAlbumInvite(String requestID) async {
    bool success = await RequestService.denyAlbumInvite(user.token, requestID);
    if (success) {
      // Update Source of Truth
      AlbumInviteNotification request =
          albumInviteMap[requestID]!.copyWith(status: RequestStatus.denied);

      albumInviteMap.removeWhere((key, value) => key == requestID);
      // Notify Listeners Locally
      _notificationController.add((StreamOperation.delete, request));
      return true;
    }
    return false;
  }
}
