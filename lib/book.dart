import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'parking_booking_page_copy.dart';
import "main.dart";

// void main() {
//   runApp(
//     // MultiProvider(
//     // providers: [
//     //   ChangeNotifierProvider(create: (context) => ParkingProvider()),
//     // ],
//     // child:
//     // ChangeNotifierProvider(
//     //   create: (context) => ParkingProvider(),
//     //   child:
//     MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: ParkingSlotsScreen(
//         // parkingID: "downtown_parking",
//         bookDate: DateTime(2025, 1, 30, 11, 0),
//         bookDuration: {'hour': 0, 'min': 30},
//       ),
//       // ),
//     ),
//     // ),
//   );
// }

String entrySlot = 'A-1';
String exitSlot = 'C-2';
// Static set of reserved slots
Set<String> reservedSlots = {'A-1', 'B-4'};

class ParkingSlotsScreen extends StatelessWidget {
  // final List<ParkingSlot> parkingLoc;
  // final String parkingID;
  final DateTime bookDate;
  final Map<String, int> bookDuration;

  ParkingSlotsScreen({required this.bookDate, required this.bookDuration});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

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
    if (parkingProvider.slots.isEmpty) {
      parkingProvider.slots = [
        ParkingSlot(
            parkingID: 'downtown_parking',
            area: {'width': 500, 'height': 200},
            number: "G1"),
        ParkingSlot(
            parkingID: 'downtown_parking',
            area: {'width': 400, 'height': 300},
            number: "A2"),
        ParkingSlot(
            parkingID: 'feer',
            area: {'width': 300, 'height': 500},
            number: "B1"),
        ParkingSlot(
            parkingID: 'downtown_parking',
            area: {'width': 600, 'height': 100},
            number: "D1"),
      ];
    }

    print(parkingProvider.slots);

    var selectedBookings =
        bookings.where((item) => item.parkingID == parkingProvider.parkID);

    List<String> reservedSlots = []; //contains ID

    DateTime requestedStart = widget.bookDate;
    DateTime requestedEnd = requestedStart.add(Duration(
      hours: widget.bookDuration['hour'] ?? 0,
      minutes: widget.bookDuration['min'] ?? 0,
    ));

    for (var booking in selectedBookings) {
      DateTime bookingStart = booking.date;
      DateTime bookingEnd = bookingStart.add(Duration(
        hours: booking.duration['hour'] ?? 0,
        minutes: booking.duration['min'] ?? 0,
      ));

      bool isOverlapping = requestedStart.isBefore(bookingEnd) &&
          requestedEnd.isAfter(bookingStart);
      print(requestedStart);
      print(requestedEnd);
      print('----------');
      print(bookingStart);
      print(bookingEnd);
      print('----------');

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
                          builder: (context) => ParkingBookingPage())
                      // builder: (context) => ParkingBookingPage(
                      //     targetSlot: slot, slotID: index)),
                      );
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

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    double dashHeight = 90;
    double dashSpace = 50;
    double startY = 0;

    // Draw only the center dashed line
    double centerX = size.width / 2;

    while (startY < size.height) {
      canvas.drawLine(
          Offset(centerX, startY), Offset(centerX, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
