import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_photo/bloc/bloc/profile_bloc.dart';
import 'package:shared_photo/components/new_profile_comp/profile_header_comps/profile_detail_element.dart';

class ProfileHeaderDetail extends StatelessWidget {
  const ProfileHeaderDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProfileDetailElement(
              title: "friends",
              value: state.myFriends.length.toString(),
            ),
            const SizedBox(width: 45),
            ProfileDetailElement(
              title: "albums",
              value: state.myAlbumsMap.length.toString(),
            ),
          ],
        );
      },
    );
  }
}
