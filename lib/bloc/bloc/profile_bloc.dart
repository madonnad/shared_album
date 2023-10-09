import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_photo/bloc/bloc/app_bloc.dart';
import 'package:shared_photo/models/album.dart';
import 'package:shared_photo/models/friend.dart';
import 'package:shared_photo/models/image.dart';
import 'package:shared_photo/models/notification.dart';
import 'package:shared_photo/repositories/data_repository.dart';
import 'package:shared_photo/repositories/go_repository.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AppBloc appBloc;
  final DataRepository dataRepository;
  final GoRepository goRepository;

  ProfileBloc(
      {required this.appBloc,
      required this.dataRepository,
      required this.goRepository})
      : super(ProfileState.empty) {
    on<InitializeProfile>((event, emit) async {
      String token = appBloc.state.user.token;
      emit(state.copyWith(isLoading: true));
      List<Album> myAlbums =
          await goRepository.getAuthenticatedUsersAlbums(token);
      //print(myAlbums);
      List<Notification> myNotifications =
          await goRepository.getNotifications(token);

      emit(
        state.copyWith(
            myAlbums: myAlbums,
            myNotifications: myNotifications,
            isLoading: false),
      );
    });

    on<ReceiveNotification>((event, emit) async {
      List<Notification> myNotifications = [];
      myNotifications = List.from(state.myNotifications);

      Notification notification = await dataRepository.getReceivedNotification(
          event.notificationType, event.identifier);
      myNotifications.insert(0, notification);

      emit(state.copyWith(
          myNotifications: myNotifications, showNotification: true));
      await Future.delayed(const Duration(seconds: 4));
      emit(state.copyWith(showNotification: false));
    });

    on<NotificationRemoved>(
      (event, emit) {
        List<Notification> myNotifications = [];
        myNotifications = List.from(state.myNotifications);

        var type = event.notificationType;

        /*myNotifications.removeWhere((element) {
          switch (type) {
            case NotificationType.albumInvite:
              if (element is AlbumInviteNotification &&
                  element.notificationID == event.identifier) {
                return true;
              }
            case NotificationType.friendRequest:
              if (element is FriendRequestNotification &&
                  element.notifierID == event.identifier) {
                return true;
              }
            case NotificationType.generic:
          }

          return false;
        });*/

        print(myNotifications);

        emit(state.copyWith(myNotifications: myNotifications));
      },
    );

    on<LoadNotifications>((event, emit) async {
      int index = event.index;
      List<Notification> myNotifications = [];

      emit(state.copyWith(isLoading: true));

      //Fill the list if it is empty - eventually will add the realtime update here
      if (state.myNotifications.isEmpty) {
        myNotifications = await dataRepository.fetchMyNotifications();
        emit(
            state.copyWith(myNotifications: myNotifications, isLoading: false));
      }

      //Grab the URL of the media as it becomes available.
      /*if (event.location == LoadLocation.list &&
          state.myNotifications[index].notificationMediaURL == null) {
        emit(state.copyWith(isLoading: true));
        //Grab notifications from state emitted above;
        myNotifications = state.myNotifications;
        Notification notification = myNotifications[index];

        //Get the ID to pass to the fetchSignURL function
        String imageId = notification.notificationMediaID;
        String notificationMediaURL =
            await dataRepository.fetchSignedUrl(imageId);

        //Assign the notification to MediaURL in notification
        //Then set that equal to the index in the list
        notification.notificationMediaURL = notificationMediaURL;
        myNotifications[index] = notification;

        emit(
            state.copyWith(myNotifications: myNotifications, isLoading: false));
      }*/
      emit(state.copyWith(isLoading: false));
    });

    on<FetchProfileAlbumCoverURL>(
      (event, emit) async {
        int index = event.index;
        DateTime revealDT =
            DateTime.parse(state.myAlbums[index].revealDateTime);
        List<Album> listOfAlbums = state.myAlbums;
        Album album = state.myAlbums[index];
        String albumCoverID = album.albumCoverId;

        emit(state.copyWith(isLoading: true));

        if (state.myAlbums[index].images.isEmpty ||
            revealDT.isBefore(DateTime.now())) {
          try {
            album.albumCoverUrl =
                await dataRepository.fetchSignedUrl(albumCoverID);
            listOfAlbums[index] = album;
            emit(state.copyWith(isLoading: false, myAlbums: listOfAlbums));
          } catch (e) {
            emit(state.copyWith(error: e.toString(), isLoading: false));
            emit(state.copyWith(error: ''));
          }
        } else if (album.images[0].imageUrl == null) {
          String firstImage = album.images[0]!.imageId;
          try {
            album.albumCoverUrl =
                await dataRepository.fetchSignedUrl(firstImage);
            listOfAlbums[index] = album;
            emit(state.copyWith(isLoading: false, myAlbums: listOfAlbums));
          } catch (e) {
            emit(state.copyWith(error: e.toString(), isLoading: false));
            emit(state.copyWith(error: ''));
          }
        } else if (album.images[0].imageUrl == null) {
          emit(state.copyWith(isLoading: false));
        }
      },
    );

    Stream<(bool, String, NotificationType)> notificationStream =
        dataRepository.receivedNotification();

    Stream<(bool, String, NotificationType)> deletedStream =
        dataRepository.notificationRemoved();

    notificationStream.listen((event) {
      var (
        bool isRequest,
        String identifier,
        NotificationType notificationType
      ) = event;
      if (isRequest == true) {
        add(ReceiveNotification(
            identifier: identifier, notificationType: notificationType));
      }
    });

    deletedStream.listen((event) {
      var (
        bool isRequest,
        String identifier,
        NotificationType notificationType
      ) = event;
      if (isRequest == true) {
        add(NotificationRemoved(
            identifier: identifier, notificationType: notificationType));
      }
    });

    if (appBloc.state is AuthenticatedState) {
      add(InitializeProfile());
    }
  }
}
