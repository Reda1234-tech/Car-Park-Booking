import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Ensure this file is generated using `flutterfire configure`
import 'main.dart';
// import './current_reserve_details.dart';

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

  void _showBookingDetails(
      BuildContext context,
      String slotNumber,
      Map<String, int> selectedDuration,
      DateTime selectedDate,
      ParkingProvider provider) {
    // int selectedHours = int.tryParse(hourController.text) ?? 0;
    // int selectedMinutes = int.tryParse(minuteController.text) ?? 0;
    String formattedDuration =
        '${selectedDuration['hour']} hours ${selectedDuration['min']} minutes';
    String formattedDate =
        '${selectedDate.month}-${selectedDate.day}-${selectedDate.year} ${selectedDate.hour}:${selectedDate.minute}';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Slot Booking'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image.asset('assets/images/image.gif', height: 120, width: 120
              // Gif(
              // image: AssetImage(
              //   "images/img.gif",
              // ),

              // ),
              // SizedBox(height: 16),
              Text('Start Datetime: $formattedDate'),
              SizedBox(height: 16),
              Text('Duration: $formattedDuration'),
              SizedBox(height: 16),
              Text('Slot Number: $slotNumber'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final parkingProvider =
                    Provider.of<ParkingProvider>(context, listen: false);

                // adding to db
                parkingProvider.addBooking("user123", parkingProvider.parkID,
                    slotNumber, selectedDate, selectedDuration);

                Navigator.of(context).pop();
              },
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final parkingProvider = Provider.of<ParkingProvider>(context);
    bool areThereSlots = true;

    // Fetch slots if not already fetched
    print('here');
    print(parkingProvider.slots);
    if (parkingProvider.slots.isEmpty) {
      // parkingProvider.setParkingSlots([
      //   ParkingSlot(
      //       parkingID: 'nearresho',
      //       area: {'width': 500, 'height': 200},
      //       number: "G1"),
      //   ParkingSlot(
      //       parkingID: 'nearresho',
      //       area: {'width': 400, 'height': 300},
      //       number: "A2"),
      //   ParkingSlot(
      //       parkingID: 'nearresho',
      //       area: {'width': 300, 'height': 500},
      //       number: "B1"),
      //   ParkingSlot(
      //       parkingID: 'nearresho',
      //       area: {'width': 600, 'height': 100},
      //       number: "C1"),
      // ]);

      parkingProvider.fetchSlots(parkingProvider.parkID);
    }

    // Filter bookings for the selected parking place
    var selectedBookings =
        bookings.where((item) => item.parkingID == parkingProvider.parkID);

    List<String> reservedSlots = []; // Contains IDs of reserved slots
    List<String> userBookedSlots = []; // Contains IDs of user booked slots

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

      if (booking.userID == "user123") {
        userBookedSlots.add(booking.slotNumber);
      }
      //if its the user one and want to book will be blocked also

      bool isOverlapping = requestedStart.isBefore(bookingEnd) &&
          requestedEnd.isAfter(bookingStart);

      if (isOverlapping) {
        reservedSlots.add(booking.slotNumber);
      }
    }

    print('reserved');
    print(reservedSlots);

    if (parkingProvider.slots.isEmpty) areThereSlots = false;

    //  if(selectedBookings.isEmpty)
    // return Text("No slots available");

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
        bool isUserReserve = userBookedSlots.contains(slot.number);

        return GestureDetector(
          onTap: isUserReserve
              ? () {
                  //GO_TO_EXTEND
                  // CurrentReservePage(slotName: slot.number);
                }
              : () {
                  _showBookingDetails(context, slot.number, widget.bookDuration,
                      widget.bookDate, parkingProvider);
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
              child: (areThereSlots)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(slot.number,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize:
                                        getResponsiveFontSize(context, 0.03),
                                  )),
                            ),
                            SizedBox(width: 10),
                            Text("${slot.area['width']}x${slot.area['height']}",
                                style: TextStyle(
                                    color: Color.fromRGBO(103, 83, 164, 1))),
                            if (isUserReserve) ...[
                              SizedBox(width: 10),
                              Text(
                                  // "${widget.bookDuration['hour']}h ${widget.bookDuration['min']}m",
                                  "Yours",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize:
                                        getResponsiveFontSize(context, 0.02),
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
                    )
                  : Center(child: Text("No slots to show"))),
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
