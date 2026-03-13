import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:walky/colors/colors.dart';
import '../providers/user_provider.dart';

class Convertpage extends ConsumerStatefulWidget {
  final int steps;
  const Convertpage(this.steps, {super.key});

  @override
  ConsumerState<Convertpage> createState() => _ConvertpageState();
}

class _ConvertpageState extends ConsumerState<Convertpage> {
  bool _isProcessing = false;

  Future<void> _handleConversion() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isProcessing = true);

    final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final int pointsToEarn = (widget.steps / 100).floor();
    final String today = DateTime.now().toIso8601String().split('T')[0];

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(userRef);
        if (!snapshot.exists) throw Exception("User data not found");

        final data = snapshot.data()!;
        String lastConvert = data['lastConvertDate'] ?? "";

        if (lastConvert == today) {
          throw Exception("You already converted today.");
        }

        int currentTotalPoints = data['totalPoints'] ?? 0;
        int currentTodaySteps = data['todaySteps'] ?? 0;

        transaction.update(userRef, {
          'totalPoints': currentTotalPoints + pointsToEarn,
          'todaySteps': (currentTodaySteps - widget.steps).clamp(0, 999999),
          'lastConvertDate': today,
        });

        // Add to sub-collection for history
        transaction.set(userRef.collection('history').doc(), {
          'steps': widget.steps,
          'points': pointsToEarn,
          'date': FieldValue.serverTimestamp(),
        });
      });

      if (mounted) {
        // Sync Riverpod and Hive
        ref.read(userProvider.notifier).completeConversion(widget.steps, pointsToEarn);

        // Show Success SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Conversion successful! +Points earned")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    int points = (widget.steps / 100).floor();
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xfffdf8d6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text("Daily Exchange", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView( // Allow scrolling for history
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// --- MAIN CONVERSION CARD ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(35),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  const Text("YOU ARE CONVERTING",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.2, fontSize: 12)),
                  const SizedBox(height: 20),

                  // Steps Input Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.directions_walk, color: AppColors.PrimApp, size: 30),
                      const SizedBox(width: 10),
                      Text("${widget.steps}", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const Text("Today's Steps", style: TextStyle(color: Colors.black38)),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Icon(Icons.swap_vert_circle_rounded, color: AppColors.PrimApp, size: 40),
                  ),

                  // Points Output Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.stars, color: Colors.amber, size: 30),
                      const SizedBox(width: 10),
                      Text("$points", style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.amber)),
                    ],
                  ),
                  const Text("Walky Points", style: TextStyle(color: Colors.black38)),

                  const SizedBox(height: 30),

                  _isProcessing
                      ? const CircularProgressIndicator()
                      : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.PrimApp,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      onPressed: _handleConversion,
                      child: const Text("CONFIRM EXCHANGE",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// --- HISTORY SECTION ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 10, bottom: 10),
                child: Text("RECENT ACTIVITY",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 1.1, fontSize: 13)),
              ),
            ),

            // Firebase Stream for History
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(user?.uid)
                  .collection('history')
                  .orderBy('date', descending: true)
                  .limit(5)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(20),
                    child: const Text("No conversions yet!", style: TextStyle(color: Colors.black26)),
                  );
                }

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 60),
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final DateTime? date = (data['date'] as Timestamp?)?.toDate();
                      final String dateStr = date != null
                          ? "${date.day}/${date.month}/${date.year}"
                          : "Processing...";

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.amber.withOpacity(0.1),
                          child: const Icon(Icons.stars, color: Colors.amber, size: 20),
                        ),
                        title: Text("+${data['points']} Points", style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text("${data['steps']} steps converted"),
                        trailing: Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.black38)),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}