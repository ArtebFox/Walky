import 'package:flutter/material.dart';

class Onboarding extends StatelessWidget {

  final String tittle;
  final String subTittle;
  final String image;

  const Onboarding ({


    Key? key,
    required this.tittle,
    required this.subTittle,
    required this.image,
});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Full screen background image
        Positioned.fill(
          child: Image.asset(image, fit: BoxFit.cover),
        ),
        // Dark gradient overlay to make text readable
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.3), Colors.transparent, Colors.black.withOpacity(0.7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        // Text Content
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 100), // Push text down
              Text(tittle, textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
              const SizedBox(height: 16),
              Text(subTittle, textAlign: TextAlign.center, style: TextStyle(color: Colors.white70, fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }}