import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import './book.dart'; // Ensure the path is correct
import 'maps.dart';

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;

    double imageSize = screenWidth * 0.7;
    double fontSize = screenWidth * 0.08;

    // Navigate to the next page after 5 seconds
    Future.delayed(Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MapScreen()),
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

class ParkingProvider extends ChangeNotifier {
  List<ParkingSlot> slots = [];

  // Set the initial list of slots (can be dynamic or from an API)
  void setParkingSlots(List<ParkingSlot> newSlots) {
    slots = newSlots;
    notifyListeners();
  }

  // Book a slot
  void bookSlot(String id, int hours, int minutes) {
    int index = slots.indexWhere((slot) => slot.id == id);
    if (index != -1) {
      slots[index].isBooked = true;
      slots[index].hours = hours;
      slots[index].minutes = minutes;
      notifyListeners();
    }
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ParkingProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashPage(), // Set SplashPage as the initial screen
      ),
    ),
  );
}
