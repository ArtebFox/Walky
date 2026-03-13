import 'package:flutter/material.dart';

class PointsBadge extends StatelessWidget {

  final int points;

  const PointsBadge({
    super.key,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
          )
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium,
              color: Colors.amber, size: 20),
          const SizedBox(width: 6),
          Text(
            points.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
