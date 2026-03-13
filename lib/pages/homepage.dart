import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:pedometer/pedometer.dart';
import 'package:walky/colors/colors.dart';
import 'package:walky/pages/convertpage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:walky/pages/shop_screen_page.dart';
import 'package:walky/pages/user_friendly_screen.dart';
import 'package:walky/widget/avatar_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'dart:async';
import '../providers/avatar_provider.dart';
import '../providers/user_provider.dart';
import '../services/flutter_foreground_task.dart';
import '../widget/cal_kil_widget.dart';
import '../widget/points_header_widget.dart';


class StepCounterScreen extends ConsumerStatefulWidget {
  final Function(int steps)? onStepsUpdated;
  const StepCounterScreen({super.key, this.onStepsUpdated});

  @override
  ConsumerState<StepCounterScreen> createState() => _StepCounterScreenState();
}



class _StepCounterScreenState extends ConsumerState<StepCounterScreen> {
  // Pedometer State
  StreamSubscription<StepCount>? _stepSubscription;
  int _stepsSinceLastSync = 0;

  // Persistence Variables (Kept only what is necessary for Delta calculation)
  int lastRawSteps = 0;
  String lastResetDate = "";

  /// 4. FOREGROUND TASK SETUP
  void _initForegroundTask() {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'step_tracker_channel',
        channelName: 'Step Tracker',
        channelDescription: 'Keeps your steps counting in the background.',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        iconData: const NotificationIconData(
          resType: ResourceType.mipmap,
          resPrefix: ResourcePrefix.ic,
          name: 'launcher', // Ensure this matches your app icon name
        ),
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: const ForegroundTaskOptions(
        interval: 5000,
        isOnceEvent: false,
        autoRunOnBoot: true,
        allowWakeLock: true,
        allowWifiLock: true,
      ),
    );
  }

  Future<bool> _startService() async {
    if (await FlutterForegroundTask.isRunningService) {
      return FlutterForegroundTask.restartService();
    } else {
      return FlutterForegroundTask.startService(
        notificationTitle: 'Step Counter Active',
        notificationText: 'Counting your progress...',
        callback: startCallback, // This must be the top-level function defined in your service file
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Use Future.microtask to avoid provider state conflicts during build
    Future.microtask(() {
      ref.read(avatarProvider.notifier).loadAvatar();
      ref.read(userProvider.notifier).loadUser();
    });
    _initializeData();
  }

  @override
  void dispose() {
    _stepSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    _initForegroundTask();

    //1. load local persistent from Hive to prevent "steps jump"
    final box  =  Hive.box('walkyBox');
    final String today = DateTime.now().toString().split(' ')[0];

    setState(() {
      lastRawSteps = box.get('lastRawSteps', defaultValue: 0);
      lastResetDate = box.get('lastResetDate', defaultValue: today);
    });

    //2. Permission Check
    var status = await Permission.activityRecognition.request();
    if (status.isDenied || status.isPermanentlyDenied ){
      if (mounted) {
        Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const PermissionRequiredScreen())
        );
      }
      return;
    }
    //3. Sync with Firebase and Start services
    await loadStepData();
    await _startService();
    _initPedometer();
  }
  void _initPedometer() {
    _stepSubscription?.cancel();
    _stepSubscription = Pedometer.stepCountStream.listen((StepCount event) {
      int rawSteps = event.steps;
      final String today = DateTime.now().toString().split(' ')[0];

      //get steps from User Riverpoder (with is backed by Hive)
      final currentStoredSteps = ref.read(userProvider)?.todaySteps ?? 0;

      // --- Case A: First time opening the app ---
      if (lastRawSteps == 0) {
        setState(() => lastRawSteps = rawSteps);
        _syncStepsToFirebase(currentStoredSteps);
        return;
      }

      // --- Case B: Resetting the device daily ---
      if (lastResetDate != today) {
        setState(() {
          lastResetDate = today;
          lastRawSteps = rawSteps;
        });
        // Update Riverpood and Hive via the methode we added to UserNotifier
        ref.read(userProvider.notifier).updateSteps(0);
        _syncStepsToFirebase(0);
        return;
      }

      // ---Case C: Normal Operation ---
      int delta = rawSteps - lastRawSteps;
      if (delta < 0) delta = rawSteps; // Handle phone reboot

      int newTotal = currentStoredSteps + delta;

      // Update Riverpod  and Hive (Single Source of Truth)
      ref.read(userProvider.notifier).updateSteps(newTotal);

      setState(() => lastRawSteps = rawSteps);

      _stepsSinceLastSync += delta;
      if (_stepsSinceLastSync >= 50) {
        _syncStepsToFirebase(newTotal);
        _stepsSinceLastSync = 0;
      }
    });
  }

  Future<void> _syncStepsToFirebase(int currentSteps) async {

    //Keep local persistent update in Hive
    final box = Hive.box('walkyBox');
    box.put('lastRawSteps', lastRawSteps);
    box.put('lastResetDate', lastResetDate);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'todaySteps': currentSteps, // Use the parameter passed
        'lastRawSteps': lastRawSteps,
        'lastResetDate': lastResetDate,
      });
    } catch (e) {
      debugPrint("Sync Error: $e");
    }
  }

  Future<void> loadStepData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try{
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final String today = DateTime.now().toString().split(' ')[0];
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          lastResetDate = data['lastResetDate'] ?? today;
          lastRawSteps = data['lastRawSteps'] ?? 0;
        });

        // Update the steps provider so the UI reflects the DB state immediately
        int dbSteps = (lastResetDate != today) ? 0 : (data['todaySteps'] ?? 0);
        ref.read(userProvider.notifier).updateSteps(dbSteps);
      }


    }catch(e) {
      debugPrint("Sync Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final avatar = ref.watch(avatarProvider);
    final userState = ref.watch(userProvider);
    bool isNewUser = (userState?.points ?? 0) == 0 && (userState?.todaySteps ?? 0) == 0;
    String greeting = isNewUser ? "Welcome 👋" : "Welcome back 👋";



    // UI uses steps from userstate wich is automaticly sync with HIve
    final steps = userState?.todaySteps ?? 0;
    final String today = DateTime.now().toString().split(' ')[0];
    bool alreadyConverted = userState?.lastConvertDate == today;

    // Initiate variables for calories and kilometer CAlculation
    double km = steps * 0.0008;
    double calories = steps * 0.04;

    // Change the sleek color based on steps
    Color progressColor;
    if (steps < 3000) {
      progressColor = Colors.red;
    } else if (steps < 7000) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.green;
    }

    final user = FirebaseAuth.instance.currentUser;
    final userName = user?.displayName ?? "Walker";


    return Scaffold(
      backgroundColor: const Color(0xfffdf8d6),


      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        greeting,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        userName,
                        style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      ),
                    ],
                  ),

                  const PointsHeader(),
                ],
              ),

              const SizedBox(height: 30),

              // AVATAR PREVIEW (Now synced with avatarProvider)
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: AppColors.thirdApp,
                  child: ClipOval(
                    child: AvatarWidget(
                      hair: avatar.hair,
                      head: avatar.head,
                      body: avatar.body,
                      legs: avatar.legs,
                      hand: avatar.hand,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // STEP COUNTER CARD
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Column(
                  children: [
                    const Text("TODAY'S STEPS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 9),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            steps.toString(),
                            key: ValueKey(steps),
                            style: const TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "/ 10,000",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SleekCircularSlider(
                      key: ValueKey(steps),
                      min: 0,
                      max: 10000,
                      initialValue: steps.toDouble().clamp(0, 10000),
                      appearance: CircularSliderAppearance(
                        customColors: CustomSliderColors(
                          progressBarColor: progressColor,
                          trackColor: AppColors.PrimApp, // ou Colors.black
                        ),
                        infoProperties: InfoProperties(
                          modifier: (value) => "${(value / 100).toInt()}%",
                        ),
                      ),
                    ),

                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[2],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: StatItem(
                              icon: Icons.route,
                              value: km.toStringAsFixed(2),
                              label: "Kilometers",
                            ),
                        ),
                        Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[2],
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child:
                            StatItem(
                              icon: Icons.local_fire_department,
                              value: calories.toStringAsFixed(0),
                              label: "Calories",
                            ),
                        )

                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewPadding.bottom + 16,
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: alreadyConverted ? Colors.grey : AppColors.PrimApp,
                    padding: const EdgeInsets.all(18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
                  ),
                  onPressed: steps < 100 || alreadyConverted ? null : () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Convertpage(steps)),
                    );
                    // Refreshing the user state updates steps AND lastConvertDate
                    if (result == true) {
                      await ref.read(userProvider.notifier).loadUser();
                    }
                  },
                  child: Text(
                    alreadyConverted ? "Already Converted Today" : "Convert Steps",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}