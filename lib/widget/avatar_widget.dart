import 'package:flutter/material.dart';

class AvatarWidget extends StatelessWidget {
  final String hair;
  final String head;
  final String body;
  final String legs;
  final String hand;

  const AvatarWidget({
    super.key,
    required this.hair,
    required this.head,
    required this.body,
    required this.legs,
    required this.hand,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      height: 420,
      alignment: Alignment.center,
      child : Center(
          child: FittedBox(
            fit: BoxFit.contain,
            child: Center(
                child: SizedBox(
                  width: 160,
                  height: 230,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: 105,
                        left: 40,
                        child: Image.asset(legs),
                      ),

                      Positioned(
                        top: 70,
                        left: 40,
                        child: Image.asset(body),
                      ),

                      Positioned(
                        top: 35,
                        left: 40,
                        child: Image.asset(head),
                      ),

                      Positioned(
                        top: 32,
                        left: 39.7,
                        child: Image.asset(hair),
                      ),
                      Positioned(
                        top: 70,
                        left: 40,
                        child: Image.asset(hand),
                      ),
                    ],
                  ),
                ),
            )

          )
      ),

    );
  }
}
