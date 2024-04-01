import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_photo/bloc/cubit/notification_cubit.dart';
import 'package:shared_photo/components/notification_comps/empty_lists/empty_list_comp.dart';
import 'package:shared_photo/components/notification_comps/friend_requests/friend_request_accepted_item.dart';
import 'package:shared_photo/components/notification_comps/friend_requests/friend_request_item.dart';
import 'package:shared_photo/models/notification.dart';

class FriendRequestList extends StatelessWidget {
  const FriendRequestList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        if (state.unseenFriendRequests) {
          context.read<NotificationCubit>().markListAsRead(2);
        }
        return Padding(
          padding: const EdgeInsets.only(top: 25.0),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: state.friendRequestList.length,
                  itemBuilder: (context, index) {
                    switch (state.friendRequestList[index].status) {
                      case FriendRequestStatus.accepted:
                        return FriendRequestAcceptedItem(
                          firstName: state.friendRequestList[index].firstName,
                          profileImage: state.friendRequestList[index].imageReq,
                          requesterID:
                              state.friendRequestList[index].notificationID,
                        );
                      case FriendRequestStatus.pending:
                        return FriendRequestItem(
                          firstName: state.friendRequestList[index].firstName,
                          lastName: state.friendRequestList[index].lastName,
                          profileImage: state.friendRequestList[index].imageReq,
                          requesterID:
                              state.friendRequestList[index].notificationID,
                        );

                      case FriendRequestStatus.decline:
                        return const SizedBox(height: 0);
                    }
                  },
                ),
              ),
              (state.friendRequestList.any((request) =>
                      request.status == FriendRequestStatus.pending))
                  ? const SizedBox(height: 0)
                  : const Expanded(
                      flex: 10,
                      child: EmptyListComponent(listName: "Friend Request"),
                    )
            ],
          ),
        );
      },
    );
  }
}
