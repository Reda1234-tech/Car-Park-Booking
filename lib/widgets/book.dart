import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import '../utils/firebase_options.dart'; // Ensure this file is generated using `flutterfire configure`
import 'current_reserve_details.dart';

import '../provider/parking_provider.dart';
import '../model/park_slot.dart';

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

  const ParkingSlotsScreen(
      {super.key, required this.bookDate, required this.bookDuration});

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

  late Future<List<Map<String, dynamic>>> _bookingsFuture;

  @override
  void initState() {
    super.initState();
    // final parkingProvider = Provider.of<ParkingProvider>(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final parkingProvider =
        Provider.of<ParkingProvider?>(context, listen: false);
    _bookingsFuture = parkingProvider!.fetchBookings(parkingProvider.parkID);
    print('chang');
  }

  void _showBookingDetails(
      BuildContext context,
      String slotNumber,
      Map<String, int> selectedDuration,
      DateTime selectedDate,
      ParkingProvider provider) {
    String formattedDuration =
        '${selectedDuration['hour']} hours ${selectedDuration['min']} minutes';
    String formattedDate =
        '${selectedDate.month}-${selectedDate.day}-${selectedDate.year} ${selectedDate.hour}:${selectedDate.minute}';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final parkingProvider =
            Provider.of<ParkingProvider>(context, listen: false);
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

    if (parkingProvider.slots.isEmpty) {
      parkingProvider.fetchSlots(parkingProvider.parkID);
    }

    /*
    // Filter bookings for the selected parking place

    if (parkingProvider.slots.isEmpty) areThereSlots = false;

*/

    return FutureBuilder<List<Map<String, dynamic>>>(
        future: _bookingsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching bookings'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No bookings available'));
          } else {
            List<Map<String, dynamic>> bookings = snapshot.data!;

            // Filter bookings for the selected parking place
            var selectedBookings = bookings.where((item) =>
                item['booking_details'].parkingID == parkingProvider.parkID);

            List<String> reservedSlots = []; // Contains IDs of reserved slots
            List<String> userBookedSlots =
                []; // Contains IDs of user booked slots
            Map<String, dynamic> userBookingIDs = {};

            DateTime requestedStart = widget.bookDate;
            DateTime requestedEnd = requestedStart.add(Duration(
              hours: widget.bookDuration['hour'] ?? 0,
              minutes: widget.bookDuration['min'] ?? 0,
            ));

            // Check for overlapping bookings
            for (var booking in selectedBookings) {
              DateTime bookingStart = booking['booking_details'].date;
              DateTime bookingEnd = bookingStart.add(Duration(
                hours: booking['booking_details'].duration['hour'] ?? 0,
                minutes: booking['booking_details'].duration['min'] ?? 0,
              ));

              bool isOverlapping = requestedStart.isBefore(bookingEnd) &&
                  requestedEnd.isAfter(bookingStart);

              if (isOverlapping) {
                reservedSlots.add(booking['booking_details'].slotNumber);

                if (booking['booking_details'].userID == "user123") {
                  userBookedSlots.add(booking['booking_details'].slotNumber);
                  userBookingIDs.addAll({
                    booking['booking_details'].slotNumber: {
                      'id': booking['id'],
                      'reservedDate': booking['booking_details'].date,
                      'reserveDuration': booking['booking_details'].duration
                    }
                  });
                }
              }
            }

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

                return Consumer<ParkingProvider>(
                    builder: (context, parkProvider, child) {
                  return GestureDetector(
                    onTap: isReserved
                        ? isUserReserve
                            ? () {
                                //GO_TO_EXTEND
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CurrentReservePage(
                                            bookingID:
                                                userBookingIDs[slot.number]
                                                    ['id']!,
                                            slotName: slot.number,
                                            reservedTime:
                                                userBookingIDs[slot.number]
                                                    ['reservedDate'],
                                            duration:
                                                userBookingIDs[slot.number]
                                                    ['reserveDuration'],
                                          )),
                                );
                              }
                            : null
                        : () {
                            _showBookingDetails(
                                context,
                                slot.number,
                                widget.bookDuration,
                                widget.bookDate,
                                parkingProvider);
                          },
                    child: Container(
                        height: 120,
                        width: 200,
                        decoration: BoxDecoration(
                            color: isReserved
                                ? Colors.grey.withOpacity(0.8)
                                : Colors.transparent,
                            border: Border.all(
                                color: Color.fromRGBO(103, 83, 164, 1)),
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
                                              fontSize: getResponsiveFontSize(
                                                  context, 0.03),
                                            )),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                          "${slot.area['width']}x${slot.area['height']}",
                                          style: TextStyle(
                                              color: Color.fromRGBO(
                                                  103, 83, 164, 1))),
                                      if (isReserved && isUserReserve) ...[
                                        SizedBox(width: 10),
                                        Text(
                                            // "${widget.bookDuration['hour']}h ${widget.bookDuration['min']}m",
                                            "Yours",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: getResponsiveFontSize(
                                                  context, 0.02),
                                            )),
                                      ]
                                    ],
                                  ),
                                  if (isReserved) ...[
                                    SizedBox(
                                      height:
                                          getResponsiveImgSize(context, 0.25),
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
                });
              },
            );
          }
        });
  }
}

// Placeholder for ParkingBookingPage
class ParkingBookingPage extends StatelessWidget {
  const ParkingBookingPage({super.key});

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
