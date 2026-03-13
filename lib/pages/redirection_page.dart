import 'package:flutter/material.dart';
import 'package:walky/pages/homepage.dart';
import 'package:walky/pages/main_navigation_screen.dart';

import '../services/firebase/auth.dart';
import 'onboarding_page.dart';


class RedirectionPage extends StatefulWidget {
  const RedirectionPage({super.key});

  @override
  State<RedirectionPage> createState() => RedirectionPageState();
}

class RedirectionPageState extends State<RedirectionPage> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData) {
            return const MainNavigationScreen();
          } else {
            return const OnboardingPage();
          }
        });
  }
}