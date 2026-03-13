import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import '../colors/colors.dart';
import '../pages/signin_page.dart';
import '../providers/user_provider.dart';

class AccountDetailsPage extends ConsumerStatefulWidget {
  const AccountDetailsPage({super.key});

  @override
  ConsumerState<AccountDetailsPage> createState() => _AccountDetailsPageState();
}

class _AccountDetailsPageState extends ConsumerState<AccountDetailsPage> {
  final user = FirebaseAuth.instance.currentUser;
  bool _isDeleting = false;



  @override
  Widget build(BuildContext context) {
    // Format the creation date
    String memberSince = "Unknown";
    if (user?.metadata.creationTime != null) {
      memberSince = DateFormat('MMMM dd, yyyy').format(user!.metadata.creationTime!);
    }

    return Scaffold(
      backgroundColor: const Color(0xfffdf8d6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text("Account Details", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          /// --- ACCOUNT INFO CARD ---
          _buildInfoCard(memberSince),

          const SizedBox(height: 30),

          /// --- DATA PRIVACY SECTION ---
          const Text(
            "DATA & PRIVACY",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.1),
          ),
          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildActionTile(
                  icon: Icons.history,
                  title: "Clear Step History",
                  subtitle: "Resets local step cache",
                  onTap: () => _confirmClearCache(),
                ),
                const Divider(height: 1, indent: 60),
                _buildActionTile(
                  icon: Icons.delete_forever,
                  title: "Delete Account",
                  subtitle: "Permanently erase all your data",
                  color: Colors.redAccent,
                  onTap: () => _confirmAccountDeletion(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          const Center(
            child: Text(
              "Walky Version 1.0.0",
              style: TextStyle(color: Colors.black26, fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard(String date) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        children: [
          _infoRow("Email Address", user?.email ?? "N/A"),
          const Divider(height: 30),
          _infoRow("Member Since", date),
          const Divider(height: 30),
          _infoRow("Account Status", "Verified"),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color color = Colors.black87,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }

  /// --- LOGIC: CLEAR CACHE ---
  void _confirmClearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear Cache?"),
        content: const Text("This will reset your local step counter for today but won't affect your earned points."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              // 1. Clear Hive Box
              final box = Hive.box('walkyBox');
              await box.clear();

              // 2. Reset Riverpod State
              ref.read(userProvider.notifier).updateSteps(0);

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Step cache cleared successfully"))
                );
              }
            },
            child: const Text("Clear", style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }
  /// --- LOGIC: ACCOUNT DELETION ---
  /// Note: Google Play Store REQUIRES an easy way to delete accounts.
  void _confirmAccountDeletion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account?"),
        content: const Text("This action cannot be undone. All your steps, points, and items will be permanently deleted from our servers."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () => _deleteUserAccount(),
            child: const Text("Delete Everything", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUserAccount() async {
    try {
      final uid = user?.uid;
      if (uid == null) return;

      setState(() => _isDeleting = true);

      // 1. Delete Firestore Data (Cleanup Database)
      await FirebaseFirestore.instance.collection('users').doc(uid).delete();

      // 2. Delete Auth Account (Cleanup Authentication)
      await user?.delete();

      // 3. Clear Local Storage
      await Hive.box('walkyBox').clear();

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const SigninPage()),
              (route) => false,
        );
      }
    } catch (e) {
      // Typically happens if the user has a "stale" session.
      // Firebase requires a fresh login to perform sensitive actions like deletion.
      if (mounted) {
        setState(() => _isDeleting = false);
        Navigator.pop(context); // Close the dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.redAccent,
            content: Text("For security, please logout and log back in before deleting your account."),
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }}