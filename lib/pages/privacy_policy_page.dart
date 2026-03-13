import 'package:flutter/material.dart';
import '../colors/colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfffdf8d6),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Privacy Policy",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          /// --- LAST UPDATED BADGE ---
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.PrimApp.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Last Updated: March 2026",
                style: TextStyle(
                  color: AppColors.PrimApp,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),

          _section(
            title: "1. Introduction",
            content:
            "At Walky, your privacy is our priority. This policy explains how we handle your movement data and account information across our local and cloud systems.",
          ),

          _section(
            title: "2. Data Collection & Storage",
            content:
            "• Account Info: Email and UID are stored via Firebase.\n"
                "• Step Data: Collected via device sensors and synced to Cloud Firestore.\n"
                "• Local Caching: We use Hive (encrypted local storage) to keep your step count instant and available offline.\n"
                "• Foreground Tasks: Walky uses a background service to ensure your steps are counted even when the app is minimized.",
          ),

          _section(
            title: "3. Service Usage",
            content:
            "We use Foreground Services to maintain a persistent connection with your phone's pedometer. This is strictly used for step counting and does not track your GPS location.",
          ),

          _section(
            title: "4. Data Security",
            content:
            "All communication between your device and our servers is encrypted via HTTPS. Your local data in Hive is restricted to the Walky application sandbox.",
          ),

          _section(
            title: "5. Third-Party Services",
            content:
            "We utilize Google Firebase for authentication and database management. We do not share your personal activity data with any other third-party advertisers.",
          ),

          _section(
            title: "6. Your Rights & Deletion",
            content:
            "You have the right to delete your account at any time through the 'Account Details' page. This will permanently erase your data from both Hive (local) and Firestore (cloud).",
          ),

          _section(
            title: "7. Contact Us",
            content:
            "For privacy-related questions or data requests, please contact our support team at:\n\nwalky.spp@gmail.com",
          ),

          const SizedBox(height: 40),
          const Center(
            child: Text(
              "Thank you for trusting Walky.",
              style: TextStyle(color: Colors.black26, fontSize: 12),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _section({
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(22), // Increased padding for readability
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user_outlined, size: 18, color: AppColors.PrimApp),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: Colors.black.withOpacity(0.6),
              height: 1.6, // Better line spacing for long legal text
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}