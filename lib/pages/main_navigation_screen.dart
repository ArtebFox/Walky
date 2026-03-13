import 'package:flutter/material.dart';
import 'package:walky/pages/convertpage.dart';
import 'package:walky/pages/historic_page.dart';
import 'package:walky/pages/settings_page.dart';
import 'package:walky/pages/shop_screen_page.dart';
import 'package:walky/pages/test.dart';
import '../colors/colors.dart';
import 'homepage.dart';
import 'nav_bar.dart';


class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});


  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  int availableSteps = 0;
  int currentIndex = 0;
  late PageController _pageController;

  final List<Widget> pages =  [
    StepCounterScreen(),
    ShopScreen(),
    StepCounterScreen(),
    HistoricPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onNavTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        children: [
          StepCounterScreen(
            onStepsUpdated: (steps) {
              setState(() {
                availableSteps = steps;
              });
            },
          ),
          ShopScreen(),
          StepCounterScreen(),
          HistoricPage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: WalkyNavBar(
        currentIndex: currentIndex,
        onTap: (index) {

          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );

          setState(() {
            currentIndex = index;
          });
        },
      ),


    );
  }
}
