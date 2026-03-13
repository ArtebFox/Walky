import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Ensure intl is in pubspec.yaml

class HistoricPage extends StatefulWidget {
  const HistoricPage({super.key});

  @override
  State<HistoricPage> createState() => _HistoricPageState();
}

class _HistoricPageState extends State<HistoricPage> {
  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xfffdf8d6),
      appBar: AppBar(
        title: const Text(
          "All Conversions",
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('history')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState();
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            itemCount: docs.length + 1, // +1 for the Summary Header
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildTotalSummary(docs);
              }

              final data = docs[index - 1].data() as Map<String, dynamic>;
              int steps = data['steps'] ?? 0;
              int pts = data['points'] ?? 0;
              Timestamp? timestamp = data['date'];

              String formattedDate = "Processing...";
              if (timestamp != null) {
                formattedDate = DateFormat('MMM dd, yyyy').format(timestamp.toDate());
              }

              return _historyTile(steps, pts, formattedDate);
            },
          );
        },
      ),
    );
  }

  /// 1. SUMMARY HEADER
  Widget _buildTotalSummary(List<QueryDocumentSnapshot> docs) {
    int totalPoints = 0;
    for (var doc in docs) {
      totalPoints += (doc.data() as Map<String, dynamic>)['points'] as int? ?? 0;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("LIFETIME EARNINGS",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.black38,
                      letterSpacing: 1.1)),
              Text("$totalPoints Points",
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.w900)),
            ],
          ),
          const Icon(Icons.auto_graph_rounded, color: Colors.orange, size: 40),
        ],
      ),
    );
  }

  /// 2. POLISHED TILE (Matches ConvertPage style)
  Widget _historyTile(int steps, int pts, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.amber.withOpacity(0.1),
          child: const Icon(Icons.stars, color: Colors.amber, size: 20),
        ),
        title: Text(
          "+$pts Points",
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min, // Constrain the row
          children: [
            const Icon(Icons.directions_walk, size: 14, color: Colors.black38),
            const SizedBox(width: 4),
            // Wrap in Expanded to prevent the 12px overflow
            Expanded(
              child: Text(
                "$steps steps converted",
                style: const TextStyle(color: Colors.black38, fontSize: 13),
                overflow: TextOverflow.ellipsis, // Adds "..." if still too long
                maxLines: 1,
              ),
            ),
          ],
        ),
        // Use a ConstrainedBox for trailing to ensure it doesn't get squeezed
        trailing: Text(
          date,
          textAlign: TextAlign.right,
          style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.black26
          ),
        ),
      ),
    );
  }
  /// 3. EMPTY STATE
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.black12),
          const SizedBox(height: 16),
          const Text(
            "No conversions recorded yet",
            style: TextStyle(
                color: Colors.black38,
                fontSize: 16,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}