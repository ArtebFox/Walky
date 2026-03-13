import 'dart:async';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:pedometer/pedometer.dart';

@pragma('vm:entry-point')
void startCallback() {
  // The callback used to set the task handler
  FlutterForegroundTask.setTaskHandler(MyStepTaskHandler());
}

class MyStepTaskHandler extends TaskHandler {
  StreamSubscription<StepCount>? _subscription;

  @override
  void onStart(DateTime timestamp,  serviceControl) {
    // We listen to the pedometer in the background
    _subscription = Pedometer.stepCountStream.listen((event) {
      // You can update the notification text dynamically
      FlutterForegroundTask.updateService(
        notificationTitle: 'Step Tracker is active',
        notificationText: 'Keep walking to earn points!',
      );
    });
  }

  @override
  void onRepeatEvent(DateTime timestamp,  serviceControl) {
    // This runs based on the interval you set in init
  }

  @override
  void onDestroy(DateTime timestamp,  serviceControl) {
    // Clean up the stream when the service is stopped
    _subscription?.cancel();
  }
}