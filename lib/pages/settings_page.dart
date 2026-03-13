import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Add Riverpod
import 'package:walky/pages/signin_page.dart';
import '../colors/colors.dart';
import '../providers/avatar_provider.dart'; // Import your avatar provider
import '../widget/avatar_widget.dart';    // Import your avatar widget
import 'account_detailsp_age.dart';
import 'privacy_policy_page.dart';
import 'help_page.dart';

// Change to ConsumerWidget to access Riverpod
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    // Watch the current avatar state
    final avatar = ref.watch(avatarProvider);

    return Scaffold(
      backgroundColor: const Color(0xfffdf8d6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          /// ===== IMPROVED PROFILE CARD =====
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.04),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: Column(
              children: [
                // THE CUSTOM AVATAR CIRCLE
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppColors.thirdApp.withOpacity(0.3),
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: ClipOval(
                    child: Transform.scale(
                      scale: 1.3,
                      child: AvatarWidget(
                        hair: avatar.hair,
                        head: avatar.head,
                        body: avatar.body,
                        legs: avatar.legs,
                        hand: avatar.hand,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.email?.split('@')[0].toUpperCase() ?? "WALKY USER",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  user?.email ?? "Guest Account",
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          /// ===== SETTINGS SECTION LABEL =====
          const Padding(
            padding: EdgeInsets.only(left: 10, bottom: 10),
            child: Text(
              "PREFERENCES",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black45,
                fontSize: 12,
                letterSpacing: 1.2,
              ),
            ),
          ),

          /// ===== SETTINGS CARD =====
          _settingsCard(context),

          const SizedBox(height: 30),

          /// ===== LOGOUT BUTTON =====
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.redAccent,
              elevation: 0,
              side: const BorderSide(color: Colors.redAccent, width: 1.5),
              padding: const EdgeInsets.all(18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
            onPressed: () async {
              _showLogoutDialog(context);
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text(
              "Logout Account",
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to exit Walky?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const SigninPage()),
                      (route) => false,
                );
              }
            },
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _settingsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
        _tile(
          icon: Icons.account_circle_outlined,
          title: "Account Details",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AccountDetailsPage())
            );
          },
        ),
          const Divider(height: 1, indent: 60),
          _tile(
            icon: Icons.privacy_tip_outlined,
            title: "Privacy Policy",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage()));
            },
          ),
          const Divider(height: 1, indent: 60),
          _tile(
            icon: Icons.help_outline,
            title: "Help & Support",
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpPage()));
            },
          ),
        ],
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.PrimApp.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.PrimApp, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.black26),
    );
  }
}