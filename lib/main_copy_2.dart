import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'maps.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

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
      ),
    ),
  );
}

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    // double screenHeight = MediaQuery.of(context).size.height;

    double imageSize = screenWidth * 0.5;
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

List<ParkBooking> bookings = [
  ParkBooking(
      date: DateTime(2025, 2, 3, 10, 0),
      duration: {'hour': 2, 'min': 30},
      parkingID: "downtown_parking",
      slotNumber: "G1",
      userID: "user123"),
  ParkBooking(
      date: DateTime(2025, 2, 4, 11, 0),
      duration: {'hour': 3, 'min': 0},
      parkingID: "downtown_parking",
      slotNumber: "A2",
      userID: "user123"),
  ParkBooking(
      date: DateTime(2025, 2, 4, 11, 0),
      duration: {'hour': 1, 'min': 30},
      parkingID: "downtown_parking",
      slotNumber: "A1",
      userID: "user456"),
  ParkBooking(
      date: DateTime(2025, 2, 3, 12, 0),
      duration: {'hour': 1, 'min': 30},
      parkingID: "downtown_parking",
      slotNumber: "A2",
      userID: "user456"),
  ParkBooking(
      date: DateTime(2025, 2, 3, 10, 0),
      duration: {'hour': 2, 'min': 30},
      parkingID: "feer",
      slotNumber: "B1",
      userID: "user456"),
];

//

class ParkBooking {
  String parkingID;
  String slotNumber;
  final DateTime date;
  final Map<String, int> duration;
  String userID;

  ParkBooking({
    required this.parkingID,
    required this.slotNumber,
    required this.date,
    required this.duration,
    required this.userID,
  });
}

class ParkingSlot {
  final String parkingID;
  final String number;
  final Map<String, double> area;

  ParkingSlot({
    required this.parkingID,
    required this.number,
    required this.area,
  });
}

class ParkingProvider extends ChangeNotifier {
  List<ParkBooking> bookedSlots = [];
  List<ParkingSlot> _slots = [];
  String _parkID = "downtown_parking";

  List<ParkingSlot> get slots => _slots;
  String get parkID => _parkID;
//////////////////////////////////////////////////////////////////
  Future<void> addBooking(String userId, String parkingId, String slotNumber,
      DateTime date, Map<String, int> duration) async {
    try {
      // Reference to the bookings collection
      CollectionReference bookingsRef =
          FirebaseFirestore.instance.collection('bookings');

      // Add booking document
      DocumentReference docRef = await bookingsRef.add({
        'user_id': userId,
        'parking_id': parkingId, // Link to the parking place
        'slot_number': slotNumber, // Link to the slot
        'date': date,
        'duration': duration,
      });

      // Check if the document was added successfully
      if (docRef.id.isNotEmpty) {
        print('Booking added successfully with ID: ${docRef.id}');
      } else {
        print('Booking failed: Document reference is empty.');
      }
    } catch (e) {
      print('Error adding booking: $e');
    }
  }
  // Set the initial list of slots (can be dynamic or from an API)

//////////////////////////////////////////////////////////////////////////////////////
  void setParkingSlots(List<ParkingSlot> newSlots) {
    _slots = newSlots;
    notifyListeners();
  }

  void setBookedSlots(List<ParkBooking> newBookedSlots) {
    bookedSlots = newBookedSlots;
    notifyListeners();
  }

  void addNewBooked(ParkBooking newBookedSlot) {
    bookedSlots.add(newBookedSlot);
    notifyListeners();
  }

  void setParkingID(String parkingID) {
    _parkID = parkingID;
    notifyListeners();
  }

  Future<void> fetchSlots(String parkingID) async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore
        .collection('slots')
        .where('parking_id', isEqualTo: parkingID)
        .get();

    _slots = snapshot.docs.map((doc) {
      final data = doc.data();
      return ParkingSlot(
        parkingID: data['parking_id'],
        area: data['area'], // Ensure 'area' is a Map<String, dynamic>
        number: data['number'],
      );
    }).toList();

    notifyListeners();
  }

  // Book a slot
  void bookSlot(String id, int hours, int minutes, String date) {
    int index = slots.indexWhere((slot) => slot.number == id);
    if (index != -1) {
      // slots[index].isBooked = true;
      // slots[index].hours = hours;
      // slots[index].minutes = minutes;
      // slots[index].startDate = date;
      notifyListeners();
    }
  }
}
