import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_photo/bloc/cubit/create_album_cubit.dart';
import 'package:shared_photo/components/new_create_album_comp/create_album_friend_comp/search_list_item.dart';

class EmptyFriendsListView extends StatelessWidget {
  const EmptyFriendsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateAlbumCubit, CreateAlbumState>(
      builder: (context, state) {
        return ListView.builder(
          itemCount: state.friendsList.length,
          itemBuilder: (context, index) {
            bool isInvited =
                state.invitedUIDList.contains(state.friendsList[index].uid);
            return Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: SearchListItem(
                friend: state.friendsList[index],
                isInvited: isInvited,
              ),
            );
          },
        );
      },
    );
  }
}
