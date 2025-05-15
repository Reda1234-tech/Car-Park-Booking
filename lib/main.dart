import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'untils/firebase_options.dart';

import 'widgets/splash_page.dart';
import 'provider/parking_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ParkingProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashPage(),

        // Set SplashPage as the initial screen
      ),
    ),
  );
}
