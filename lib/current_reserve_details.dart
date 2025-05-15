import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'book.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ChangeNotifierProvider(
      create: (context) => ParkingProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CurrentReservePage(
          bookingID: "asddsddxvcv",
          slotName: 'ب-2',
          reservedTime: DateTime(2025, 2, 3, 15, 0),
          duration: {'hour': 2, 'min': 0},
        ),
      )));
}

class CurrentReservePage extends StatefulWidget {
  final String bookingID;
  final String slotName;
  final DateTime reservedTime;
  final Map<String, int> duration;

  const CurrentReservePage({
    super.key,
    required this.bookingID,
    required this.slotName,
    required this.reservedTime,
    required this.duration,
  });

  @override
  _CurrentReservePageState createState() => _CurrentReservePageState();
}

class _CurrentReservePageState extends State<CurrentReservePage> {
  Duration remainingTime = Duration.zero;
  Timer? _timer;
  bool _isTimerRunning = false;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    // if (!_isExpired) {
    //   _startTimer();
    // }
  }

  void _calculateRemainingTime() {
    DateTime now = DateTime.now();
    DateTime startTime = widget.reservedTime;
    DateTime endTime = startTime.add(Duration(
      hours: widget.duration['hour']!,
      minutes: widget.duration['min']!,
    ));

    if (now.isBefore(startTime)) {
      // Booking hasn't started yet
      remainingTime = startTime.difference(now);
      _isTimerRunning = false;
      _waitForStartTime();
    } else if (now.isAfter(endTime)) {
      // Booking time has expired
      remainingTime = Duration.zero;
      _isExpired = true;
      _isTimerRunning = false;
    } else {
      // Booking is ongoing
      remainingTime = endTime.difference(now);
      _startTimer(); // Start countdown
    }
  }

  void _waitForStartTime() {
    Timer(Duration(seconds: remainingTime.inSeconds), () {
      if (mounted) {
        setState(() {
          _isTimerRunning = true;
          remainingTime = Duration(
            hours: widget.duration['hour']!,
            minutes: widget.duration['min']!,
          );
          _startTimer();
        });
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime.inSeconds > 0) {
          remainingTime -= Duration(seconds: 1);
        } else {
          _timer?.cancel();
          _isTimerRunning = false;
          _isExpired = true;
        }
      });
    });
  }

  void _showDeleteConfirm(String bookingID) {
    final parkingProvider =
        Provider.of<ParkingProvider>(context, listen: false);

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Confirm Deletion"),
            content: Text("Are you sure you want to delete this item?"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("No"),
              ),
              TextButton(
                onPressed: () {
                  parkingProvider.deleteBooking(bookingID);
                  setState(() {
                    _timer?.cancel();
                    _isTimerRunning = false;
                  });
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ParkingSlotsScreen(
                              bookDate: widget.reservedTime,
                              bookDuration: widget.duration,
                            )),
                  );
                },
                child: Text("Yes"),
              ),
            ],
          );
        });
  }

  String _formatDuration(Duration duration) {
    int days = duration.inDays;
    int hours = duration.inHours.remainder(24);
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);

    String formattedTime = '';

    if (days > 0) {
      formattedTime += '$days d, ';
    }
    if (hours > 0 || days > 0) {
      formattedTime += '$hours h, ';
    }
    formattedTime += '$minutes m, $seconds s';

    return formattedTime;
  }

  Future<bool> _checkForBookingConflict(
      String currentBookingID, DateTime newEndTime) async {
    final parkingProvider =
        Provider.of<ParkingProvider>(context, listen: false);

    List<Map<String, dynamic>> existingBookings =
        await parkingProvider.fetchBookings(parkingProvider.parkID);

    for (var booking in existingBookings) {
      if (currentBookingID == booking['id'])
        print(booking['booking_details'].date);
      if (widget.slotName == booking['booking_details'].slotNumber &&
          currentBookingID != booking['id']) {
        DateTime bookedStartTime = booking['booking_details'].date;
        DateTime bookedEndTime = bookedStartTime.add(Duration(
          hours: booking['booking_details'].duration['hour'],
          minutes: booking['booking_details'].duration['min'],
        ));

        print('yes ${bookedStartTime} ${newEndTime} ${bookedEndTime}');
        print(currentBookingID);
        print(booking['id']);
        if (currentBookingID != booking['id'] &&
            newEndTime.isAfter(bookedStartTime)) {
          return true; // Conflict found
        }
      }
    }
    return false; // No conflict
  }

  void _extendTimer() {
    // Show a dialog to allow the user to enter additional hours and minutes
    showDialog(
      context: context,
      builder: (BuildContext context) {
        int additionalHours = 0; // Default additional hours
        int additionalMinutes = 0; // Default additional minutes

        return AlertDialog(
          title: Text('Extend Time'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter additional time:'),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Hours',
                      ),
                      onChanged: (value) {
                        additionalHours = int.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Minutes',
                      ),
                      onChanged: (value) {
                        additionalMinutes = int.tryParse(value) ?? 0;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Extend'),
              onPressed: () async {
                final parkingProvider =
                    Provider.of<ParkingProvider>(context, listen: false);

                DateTime newEndTime = widget.reservedTime
                    .add(Duration(
                        hours: widget.duration['hour']!,
                        minutes: widget.duration['min']!))
                    .add(Duration(
                        hours: additionalHours, minutes: additionalMinutes));
                try {
                  bool hasConflict = await _checkForBookingConflict(
                      widget.bookingID, newEndTime);
                  if (hasConflict) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              'Time conflict! Cannot extend. Please, choose less time')),
                    );
                  } else {
                    setState(() {
                      widget.duration['hour'] =
                          widget.duration['hour']! + additionalHours;
                      widget.duration['min'] =
                          widget.duration['min']! + additionalMinutes;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Reservation Extended.')),
                    );
                    Navigator.of(context).pop();
                    parkingProvider.extendBookingDuration(
                        widget.bookingID, additionalHours, additionalMinutes);
                  }
                } catch (e) {
                  print('error ${e}');
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        // leading: IconButton(
        //   icon: Icon(Icons.arrow_back),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: Text(
          'Current Booking',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(103, 83, 164, 1),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
            // image: DecorationImage(
            //   image: AssetImage('assets/background_image.png'),
            //   fit: BoxFit.cover,
            // ),
            ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isExpired
                    ? 'Time Expired'
                    : _isTimerRunning
                        ? 'Parking time'
                        : 'Starts in',
                style: TextStyle(
                    fontSize: 18, color: Color.fromRGBO(103, 83, 164, 1)),
              ),
              SizedBox(height: 15),
              Text(
                _formatDuration(remainingTime),
                style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(103, 83, 164, 1)),
              ),
              SizedBox(height: 32),
              Text('Slot Number: ${widget.slotName}',
                  style: TextStyle(
                      fontSize: 24, color: Color.fromRGBO(103, 83, 164, 1))),
              SizedBox(height: 32),
              if (!_isExpired)
                Column(
                  children: [
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isExpired
                            ? null
                            : () {
                                _showDeleteConfirm(widget.bookingID);
                              },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(103, 83, 164, 1)),
                        child: Text('Cancel',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                    SizedBox(height: 15),
                    SizedBox(
                      width: 200,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _extendTimer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromRGBO(103, 83, 164, 1),
                        ),
                        child: Text(
                          'Extend',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
