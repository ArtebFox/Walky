import 'package:flutter/material.dart';
import '../colors/colors.dart';

class WalkyNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const WalkyNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [

        /// BAR BACKGROUND
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: Color(0xfffdf8d6),
            border: Border(
              top: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _item(Icons.home, 0),
              _item(Icons.person, 1),
              const SizedBox(width: 60), // space for center button
              _item(Icons. history, 3),
              _item(Icons.settings, 4),
            ],
          ),
        ),

        /// CENTER FLOAT BUTTON
        Positioned(
          top: -28,
          left: MediaQuery.of(context).size.width / 2 - 30,
          child: GestureDetector(
            onTap: () => onTap(2),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.PrimApp,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.PrimApp.withOpacity(0.5),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: const Icon(
                Icons.directions_run,
                size: 30,
                color: AppColors.thirdApp,
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _item(IconData icon, int index) {
    final bool active = index == currentIndex;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active ? AppColors.PrimApp : Colors.grey,
          ),
          const SizedBox(height: 4),
          Container(
            height: 4,
            width: 4,
            decoration: BoxDecoration(
              color: active ? AppColors.PrimApp : Colors.transparent,
              shape: BoxShape.circle,
            ),
          )
        ],
      ),
    );
  }
}
