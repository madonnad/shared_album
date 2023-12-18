import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_photo/bloc/cubit/create_album_cubit.dart';
import 'package:shared_photo/components/new_create_album_comp/create_album_friend_comp/search_list_item.dart';

class SearchResultsListView extends StatelessWidget {
  const SearchResultsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateAlbumCubit, CreateAlbumState>(
      builder: (context, state) {
        return ListView.builder(
          itemCount: state.searchResult.length,
          itemBuilder: (context, index) {
            bool isInvited =
                state.invitedUIDList.contains(state.searchResult[index].uid);
            return Padding(
              padding: const EdgeInsets.only(top: 25.0),
              child: SearchListItem(
                friend: state.searchResult[index],
                isInvited: isInvited,
              ),
            );
          },
        );
      },
    );
  }
}