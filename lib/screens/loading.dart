import 'package:flutter/material.dart';

import 'package:shared_photo/components/app_comp/standard_logo.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StandardLogo(
              fontSize: 40,
            ),
            CircularProgressIndicator.adaptive()
          ],
        ),
      ),
    );
  }
}
