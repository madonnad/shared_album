import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';

class AlbumLockTabBar extends StatelessWidget {
  const AlbumLockTabBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ButtonsTabBar(
      duration: 1,
      buttonMargin: const EdgeInsets.only(top: 9, bottom: 9, right: 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      radius: 20,
      unselectedDecoration: const BoxDecoration(
        color: Color.fromRGBO(44, 44, 44, 1),
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromRGBO(255, 205, 178, 1),
            Color.fromRGBO(255, 180, 162, 1),
            Color.fromRGBO(229, 152, 155, 1),
            Color.fromRGBO(181, 131, 141, 1),
            Color.fromRGBO(109, 104, 117, 1),
          ],
        ),
      ),
      unselectedLabelStyle: const TextStyle(
        color: Colors.white54,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
      tabs: const [
        Tab(
          text: "TIMELINE",
        ),
      ],
    );
  }
}
