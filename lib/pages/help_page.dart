import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../colors/colors.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

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
          "Help & Support",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          /// --- HERO HEADER ---
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.PrimApp, AppColors.PrimApp.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: AppColors.PrimApp.withOpacity(.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "How can we help? 👋",
                  style: TextStyle(
                      fontSize: 22,
                      color: Colors.white,
                      fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 8),
                Text(
                  "Find answers to common questions about your steps, points, and account.",
                  style: TextStyle(color: Colors.white70, height: 1.4),
                )
              ],
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "FREQUENTLY ASKED QUESTIONS",
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.black45,
                letterSpacing: 1.2),
          ),
          const SizedBox(height: 15),

          /// --- FAQ SECTION ---
          _helpTile(
            icon: Icons.directions_walk_rounded,
            title: "Steps aren't counting?",
            content:
            "Walky uses a Foreground Service to count steps accurately. "
                "Ensure 'Physical Activity' permissions are allowed in settings. "
                "If steps stall, try walking for 10 seconds to wake the sensors.",
          ),

          _helpTile(
            icon: Icons.sync_problem_rounded,
            title: "What is 'Step Cache'?",
            content:
            "We use Hive to save your steps locally so they update instantly. "
                "If your data looks out of sync, you can 'Clear Cache' in Account Details to force a refresh from the server.",
          ),

          _helpTile(
            icon: Icons.stars_rounded,
            title: "Conversion Rules",
            content:
            "100 steps = 1 Walky Point. Points are used to unlock Avatar items in the Shop. "
                "Note: You can only convert steps once per day!",
          ),

          _helpTile(
            icon: Icons.shopping_bag_rounded,
            title: "Purchased items missing?",
            content:
            "All purchases are tied to your Firebase ID. Ensure you are logged into the correct email. "
                "Items will sync automatically across your devices.",
          ),

          const SizedBox(height: 30),

          /// --- SUPPORT ACTION CARD ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.PrimApp.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                const Icon(Icons.support_agent_rounded, size: 40, color: AppColors.PrimApp),
                const SizedBox(height: 12),
                const Text(
                  "Still having trouble?",
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Our team is ready to assist you.",
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.PrimApp,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () async {
                    final Uri emailLaunchUri = Uri(
                      scheme: 'mailto',
                      path: 'walky.spp@gmail.com',
                      queryParameters: {
                        'subject': 'Support Request: Walky App',
                        'body': 'Please describe your issue here...'
                      },
                    );

                    try {
                      if (await canLaunchUrl(emailLaunchUri)) {
                        await launchUrl(emailLaunchUri);
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Could not open email app")),
                          );
                        }
                      }
                    } catch (e) {
                      debugPrint("Error launching email: $e");
                    }
                  },
                  child: const Text("Contact Support", style: TextStyle(fontWeight: FontWeight.bold)),
                )              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _helpTile({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: ExpansionTile(
        shape: const RoundedRectangleBorder(side: BorderSide.none),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.PrimApp.withOpacity(.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.PrimApp, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 70, right: 20, bottom: 20),
            child: Text(
              content,
              style: const TextStyle(color: Colors.black54, height: 1.5, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}