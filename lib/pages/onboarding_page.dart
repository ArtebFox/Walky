import 'package:flutter/material.dart';
import 'package:walky/pages/privacy_policy_page.dart';
import 'package:walky/pages/signin_page.dart';
import '../colors/colors.dart';
import '../widget/onboarding.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController pageController = PageController();
  int currentpage = 0;

  void goSignin() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SigninPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          /// --- FULL SCREEN PAGEVIEW ---
          /// This allows the images in the 'Onboarding' widget to take up the whole screen
          PageView(
            controller: pageController,
            onPageChanged: (index) {
              setState(() => currentpage = index);
            },
            children: const [
              Onboarding(
                tittle: 'Walk. Earn. Level Up.',
                subTittle: "Every step you take has value. Turn your daily movement into real rewards.",
                image: 'assets/images/run1.jpg',
              ),
              Onboarding(
                tittle: 'Convert Steps into Points',
                subTittle: "100 steps = 1 point. The more you walk, the more you earn.",
                image: 'assets/images/run2.jpg',
              ),
              Onboarding(
                tittle: 'Customize Your Avatar',
                subTittle: "Use your points to unlock styles, upgrade your character, and show your progress.",
                image: 'assets/images/run3.jpg',
              ),
            ],
          ),

          /// --- TOP NAVIGATION BAR ---
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Image.asset(
                    "assets/images/W_logo.png",
                    width: 35,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage())),
                    child: const Text("Privacy", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextButton(
                      onPressed: goSignin,
                      child: const Text("Sign in", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ),

          /// --- BOTTOM CONTROLS ---
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.8), Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  /// INDICATORS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                          (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 6,
                        width: currentpage == index ? 24 : 6,
                        decoration: BoxDecoration(
                          color: currentpage == index ? AppColors.PrimApp : Colors.white30,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  /// DYNAMIC BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () {
                        if (currentpage < 2) {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeOutCubic,
                          );
                        } else {
                          goSignin();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.PrimApp,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          currentpage == 2 ? "START WALKING" : "CONTINUE",
                          key: ValueKey<int>(currentpage),
                          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// SKIP / BACK
                  Opacity(
                    opacity: currentpage == 2 ? 0 : 1, // Hide skip on last page
                    child: TextButton(
                      onPressed: currentpage == 2 ? null : goSignin,
                      child: const Text(
                        "Skip Introduction",
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}