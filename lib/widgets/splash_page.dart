import 'package:flutter/material.dart';
import 'dart:async';
import 'registration.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;

    double imageSize = screenWidth * 0.5;
    double fontSize = screenWidth * 0.08;

    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
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
