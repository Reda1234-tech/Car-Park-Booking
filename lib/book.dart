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
//     MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: ParkingSlotsScreen(parkingName: "test", parkingLoc: [
//         ParkingSlot(id: 'A-1', area: 'Small'),
//         ParkingSlot(id: 'A-2', area: 'Medium'),
//         ParkingSlot(id: 'A-6', area: 'Large'),
//       ]),
//       // ),
//     ),
//   );
// }

class ParkingSlot {
  final String id;
  final String area;
  bool isBooked;
  int hours;
  int minutes;

  ParkingSlot({
    required this.id,
    required this.area,
    this.isBooked = false,
    this.hours = 0,
    this.minutes = 0,
  });
}

String entrySlot = 'A-1';
String exitSlot = 'C-2';
// Static set of reserved slots
Set<String> reservedSlots = {'A-3', 'B-4'};

class ParkingSlotsScreen extends StatelessWidget {
  const ParkingSlotsScreen({super.key});

  // final List<ParkingSlot> parkingLoc;
  // final String parkingName;

  // ParkingSlotsScreen({required this.parkingName, required this.parkingLoc});

  @override
  Widget build(BuildContext context) {
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
          Text("ENTRY",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow.shade800)),
          Text("\u2B9F",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellow.shade800)),
          Expanded(
            child: Stack(
              children: [buildGridView()],
            ),
          )
        ],
      ),
    );
  }
}

class buildGridView extends StatefulWidget {
  const buildGridView({super.key});

  @override
  State<buildGridView> createState() => _buildGridViewState();
}

class _buildGridViewState extends State<buildGridView> {
  double getResponsiveFontSize(BuildContext context, double factor) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1000) {
      return screenWidth * factor / 2;
    }
    return screenWidth * factor;
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
    } else {
      aspectRatio = (screenWidth / screenHeight) * 2;
    }

    return aspectRatio;
  }

  @override
  Widget build(BuildContext context) {
    final parkingProvider = Provider.of<ParkingProvider>(context);

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
        bool isReserved = reservedSlots.contains(slot.id);
        return GestureDetector(
          onTap: slot.isBooked
              ? null
              : () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ParkingBookingPage(
                            targetSlot: slot, slotID: index)),
                  );
                },
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 220,
                height: 160,
                decoration: BoxDecoration(
                  color: slot.isBooked
                      ? Colors.grey.withOpacity(0.8)
                      : isReserved
                          ? Colors.grey.withOpacity(0.5)
                          : Colors.transparent,
                ),
                child: CustomPaint(
                  painter: DashedBorderPainter(),
                ),
              ),
              // Positioned(
              //   top: 30,
              //   left: 0,
              //   child: Container(
              //     width: 2,
              //     height: MediaQuery.of(context).size.height,
              //     child: CustomPaint(
              //       painter: DashedLinePainter(),
              //     ),
              //   ),
              // ),
              SizedBox(
                height: 160,
                width: 220,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(slot.id,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: getResponsiveFontSize(context, 0.03),
                              )),
                        ),
                        SizedBox(width: 10),
                        Text(slot.area,
                            style: TextStyle(
                                color: Color.fromRGBO(103, 83, 164, 1))),
                        if (slot.isBooked) ...[
                          SizedBox(width: 10),
                          Text("${slot.hours}h ${slot.minutes}m",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: getResponsiveFontSize(context, 0.03),
                              )),
                        ]
                      ],
                    ),
                    if (slot.isBooked || isReserved) ...[
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.1,
                        width: 220,
                        child: Image.asset(
                          'assets/images/car_elevation2.png',
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
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

// Dashed border custom painter
class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color.fromRGBO(103, 83, 164, 1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double dashWidth = 8;
    double dashSpace = 9;
    double startX = 0;
    double startY = 0;

    // Draw top border
    while (startX < size.width) {
      canvas.drawLine(
          Offset(startX, startY), Offset(startX + dashWidth, startY), paint);
      startX += dashWidth + dashSpace;
    }

    startX = 0;
    startY = size.height;

    // Draw bottom border
    while (startX < size.width) {
      canvas.drawLine(
          Offset(startX, startY), Offset(startX + dashWidth, startY), paint);
      startX += dashWidth + dashSpace;
    }

    startX = 0;
    startY = 0;

    // Draw left border
    while (startY < size.height) {
      canvas.drawLine(
          Offset(startX, startY), Offset(startX, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }

    startX = size.width;
    startY = 0;

    // Draw right border
    while (startY < size.height) {
      canvas.drawLine(
          Offset(startX, startY), Offset(startX, startY + dashWidth), paint);
      startY += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
