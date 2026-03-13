import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:walky/colors/colors.dart';
import 'package:walky/pages/redirection_page.dart';



final GlobalKey<NavigatorState> navigatorKey =
GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await Hive.initFlutter();
  await Hive.openBox('walkyBox');
  runApp(
    const ProviderScope(
      child: WalkyApp(),
    ),
  );
}


class WalkyApp extends StatelessWidget {
  const WalkyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(

        colorScheme: .fromSeed(seedColor:AppColors.PrimApp ),
      ),
      home:  const RedirectionPage(),
      navigatorKey: navigatorKey,
    );
  }
}





