import 'package:flutter/material.dart';
import 'package:shared_photo/components/new_profile_comp/profile_revealed_albums.dart';
import 'package:shared_photo/components/new_profile_comp/monthly_recap_comps/monthly_recap_list.dart';
import 'package:shared_photo/components/new_profile_comp/profile_header_comps/profile_header.dart';
import 'package:shared_photo/components/new_profile_comp/profile_topfriend_comps/top_friends_component.dart';
import 'package:shared_photo/components/profile_comp/logout_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(top: 50.0, left: 16, right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeader(),
              TopFriendsComponent(),
              SizedBox(height: 25),
              MonthlyRecapList(),
              ProfileRevealedAlbums(),
              LogoutButton(),
            ],
          ),
        ),
      ),
    );
  }
}