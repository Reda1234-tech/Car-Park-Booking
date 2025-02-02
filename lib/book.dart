import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'firebase_options.dart'; // Ensure this file is generated using `flutterfire configure`

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
        home: ParkingSlotsScreen(
          bookDate: DateTime.now(),
          bookDuration: {'hour': 2, 'min': 30},
        ),
      ),
    ),
  );
}

class ParkingSlot {
  final String parkingID;
  final Map<String, dynamic> area;
  final String number;

  ParkingSlot({
    required this.parkingID,
    required this.area,
    required this.number,
  });
}

class ParkingProvider with ChangeNotifier {
  List<ParkingSlot> _slots = [];
  String _parkID = 'downtown_parking'; // Default parking ID

  List<ParkingSlot> get slots => _slots;
  String get parkID => _parkID;

  void setParkID(String parkID) {
    _parkID = parkID;
    notifyListeners();
  }

  // Fetch slots from Firestore
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
}

// Placeholder for bookings
List<Booking> bookings = [
  Booking(
    parkingID: 'downtown_parking',
    slotNumber: 'G1',
    date: DateTime.now(),
    duration: {'hour': 1, 'min': 0},
  ),
];

class Booking {
  final String parkingID;
  final String slotNumber;
  final DateTime date;
  final Map<String, int> duration;

  Booking({
    required this.parkingID,
    required this.slotNumber,
    required this.date,
    required this.duration,
  });
}

class ParkingSlotsScreen extends StatelessWidget {
  final DateTime bookDate;
  final Map<String, int> bookDuration;


  ParkingSlotsScreen({required this.bookDate, required this.bookDuration});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
// addParkingPlaces();
    return Scaffold(
      appBar: AppBar(
        title: Text("Parking Slots"),
        backgroundColor: Color.fromRGBO(103, 83, 164, 1),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 10),
          Text("🚗 Parking Area 🚗",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          if (screenWidth < 600)
            Text("ENTRY",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow.shade800)),
          if (screenWidth < 600)
            Text("\u2B9F",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow.shade800)),
          Expanded(
            child: Stack(
              children: [
                buildGridView(
                  bookDate: bookDate,
                  bookDuration: bookDuration,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class buildGridView extends StatefulWidget {
  final DateTime bookDate;
  final Map<String, int> bookDuration;

  const buildGridView(
      {super.key, required this.bookDate, required this.bookDuration});

  @override
  State<buildGridView> createState() => _buildGridViewState();
}

class _buildGridViewState extends State<buildGridView> {
  double getResponsiveFontSize(BuildContext context, double factor) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return screenWidth * factor / 0.8;
    } else if (screenWidth < 1000) {
      return screenWidth * factor / 1.5;
    }
    return screenWidth * factor / 1.2;
  }

  double getResponsiveImgSize(BuildContext context, double factor) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenheight = MediaQuery.of(context).size.height;

    if (screenWidth < 600) {
      return screenheight * factor / 1.8;
    } else if (screenWidth < 1000) {
      return screenheight * factor / 3;
    }
    return screenheight * factor / 2.4;
  }

  int _getResponsiveCrossAxisCount(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return 2;
    } else if (screenWidth < 1000) {
      return 3;
    } else {
      return 4; // For large screens
    }
  }

  double _getResponsiveSpacing(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 600) {
      return 15.0; // Smaller
    } else if (screenWidth < 1000) {
      return 18.0; // Medium
    } else {
      return 20.0; // Larger
    }
  }

  double _getResponsiveChildAspectRatio(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double aspectRatio = 0;

    if (screenWidth > 1000) {
      aspectRatio = (screenWidth / screenHeight) * 0.5;
    } else if (screenWidth > 600) {
      aspectRatio = (screenWidth / screenHeight) * 1.7;
    } else {
      aspectRatio = (screenWidth / screenHeight) * 2.6;
    }

    return aspectRatio;
  }

  @override
  Widget build(BuildContext context) {
    final parkingProvider = Provider.of<ParkingProvider>(context);

    // Fetch slots if not already fetched
    if (parkingProvider.slots.isEmpty) {
      parkingProvider.fetchSlots(parkingProvider.parkID);
    }

    // Filter bookings for the selected parking place
    var selectedBookings =
        bookings.where((item) => item.parkingID == parkingProvider.parkID);

    List<String> reservedSlots = []; // Contains IDs of reserved slots

    DateTime requestedStart = widget.bookDate;
    DateTime requestedEnd = requestedStart.add(Duration(
      hours: widget.bookDuration['hour'] ?? 0,
      minutes: widget.bookDuration['min'] ?? 0,
    ));

    // Check for overlapping bookings
    for (var booking in selectedBookings) {
      DateTime bookingStart = booking.date;
      DateTime bookingEnd = bookingStart.add(Duration(
        hours: booking.duration['hour'] ?? 0,
        minutes: booking.duration['min'] ?? 0,
      ));

      bool isOverlapping = requestedStart.isBefore(bookingEnd) &&
          requestedEnd.isAfter(bookingStart);

      if (isOverlapping) {
        ParkingSlot? slot = parkingProvider.slots.firstWhere(
            (slot) =>
                slot.parkingID == parkingProvider.parkID &&
                slot.number == booking.slotNumber,
            orElse: () => ParkingSlot(parkingID: '', area: {}, number: ''));

        if (slot != null && !reservedSlots.contains(slot.number)) {
          reservedSlots.add(slot.number);
        }
      }
    }

    print(reservedSlots);

    return GridView.builder(
      physics: BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getResponsiveCrossAxisCount(context),
        mainAxisSpacing: _getResponsiveSpacing(context),
        crossAxisSpacing: _getResponsiveSpacing(context),
        childAspectRatio: _getResponsiveChildAspectRatio(context),
      ),
      padding: EdgeInsets.fromLTRB(0, 8, 0, 0),
      itemCount: parkingProvider.slots.length,
      itemBuilder: (context, index) {
        ParkingSlot slot = parkingProvider.slots[index];
        bool isReserved = reservedSlots.contains(slot.number);

        return GestureDetector(

          onTap: isReserved
              ? null
              : () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ParkingBookingPage()));
                },
          child: Container(
            height: 120,
            width: 200,
            decoration: BoxDecoration(
                color: isReserved
                    ? Colors.grey.withOpacity(0.8)
                    : Colors.transparent,
                border: Border.all(color: Color.fromRGBO(103, 83, 164, 1)),
                borderRadius: BorderRadius.circular(8)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(slot.number,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: getResponsiveFontSize(context, 0.03),
                          )),
                    ),
                    SizedBox(width: 10),
                    Text("${slot.area['width']}x${slot.area['height']}",
                        style:
                            TextStyle(color: Color.fromRGBO(103, 83, 164, 1))),
                    if (isReserved) ...[
                      SizedBox(width: 10),
                      Text(
                          "${widget.bookDuration['hour']}h ${widget.bookDuration['min']}m",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: getResponsiveFontSize(context, 0.03),
                          )),
                    ]
                  ],
                ),
                if (isReserved) ...[
                  Container(
                    height: getResponsiveImgSize(context, 0.25),
                    width: 220,
                    child: Image.asset(
                      'assets/images/car_elevation2.png',
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

// Placeholder for ParkingBookingPage
class ParkingBookingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Booking Page"),
      ),
      body: Center(
        child: Text("Booking Page Placeholder"),
      ),
    );
  }
}
