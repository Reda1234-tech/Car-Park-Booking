import 'package:flutter/material.dart';
import 'dart:async';
import 'login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

import './maps.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;

    double imageSize = screenWidth * 0.5;
    double fontSize = screenWidth * 0.08;

    Future.delayed(Duration(seconds: 3), () {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // User is already signed in → go to home page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MapScreen()), // or HomePage()
        );
      } else {
        // User not signed in → go to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
    });

    return Scaffold(
      backgroundColor:
          Color.fromRGBO(103, 83, 164, 1), // Splash screen background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the image with responsive size (larger size)
            Image.asset(
              'assets/images/img2.png',
              height: imageSize,
              width: imageSize,
            ),
            SizedBox(height: 20),
            Text(
              'Easy Parking',
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
