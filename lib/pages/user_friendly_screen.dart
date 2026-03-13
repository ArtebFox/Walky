import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:walky/colors/colors.dart';

class PermissionRequiredScreen extends StatelessWidget {
  const PermissionRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xfffdf8d6), // ton theme
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Icon(
                Icons.directions_walk,
                size: 90,
                color: AppColors.PrimApp,
              ),

              const SizedBox(height: 30),

              Text(
                "Permission Required",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.PrimApp,
                ),
              ),

              const SizedBox(height: 20),

              Text(
                "Walky needs access to your activity and sensors "
                    "to count your steps accurately and reward you with points."
                    "Please grant the permission to continue.",

                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.PrimApp,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () async {
                  await openAppSettings();
                },
                child: const Text(
                  "Open Settings",
                  style:
                  TextStyle(
                      color: AppColors.thirdApp,
                      fontSize: 16),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}