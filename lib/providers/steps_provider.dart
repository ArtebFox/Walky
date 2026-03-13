import 'package:flutter_riverpod/flutter_riverpod.dart';

class StepsNotifier extends StateNotifier<int> {
  StepsNotifier() : super(0);

  void setSteps(int steps) {
    state = steps;
  }

  void addSteps(int delta) {
    state += delta;
  }

  void reset() {
    state = 0;
  }
}

final stepsProvider =
StateNotifierProvider<StepsNotifier, int>((ref) {
  return StepsNotifier();
});