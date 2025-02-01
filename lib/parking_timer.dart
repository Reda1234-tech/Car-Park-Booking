import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ParkingTimerPage(
          slotName: 'A-2'), // Set the ParkingTimerPage as the home page
    );
  }
}

class ParkingTimerPage extends StatefulWidget {
  final String slotName;

  ParkingTimerPage({required this.slotName});

  @override
  _ParkingTimerPageState createState() => _ParkingTimerPageState();
}

class _ParkingTimerPageState extends State<ParkingTimerPage> {
  Duration remainingTime =
      Duration(hours: 0, minutes: 58, seconds: 24); // Initial time
  Timer? _timer;
  bool _isTimerRunning = true;

  @override
  void initState() {
    super.initState();
    // Start the timer
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (remainingTime.inSeconds > 0) {
          remainingTime = remainingTime - Duration(seconds: 1);
        } else {
          _timer?.cancel(); // Stop the timer when time reaches 0
          _isTimerRunning = false;
        }
      });
    });
  }

  void _stopTimer() {
    setState(() {
      _timer?.cancel(); // Stop the timer
      _isTimerRunning = false;
    });
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
                        additionalHours =
                            int.tryParse(value) ?? 0; // Parse input to integer
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
                        additionalMinutes =
                            int.tryParse(value) ?? 0; // Parse input to integer
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
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: Text('Extend'),
              onPressed: () {
                setState(() {
                  // Add the additional hours and minutes to the remaining time
                  remainingTime = remainingTime +
                      Duration(
                          hours: additionalHours, minutes: additionalMinutes);
                  if (!_isTimerRunning) {
                    _startTimer(); // Restart the timer if it was stopped
                  }
                });
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the page is disposed
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
          image: DecorationImage(
            image: AssetImage(
                'assets/background_image.png'), // Add your background image
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Subheader: "Parking time"
              Text(
                'Parking time',
                style: TextStyle(
                  fontSize: 18,
                  color: Color.fromRGBO(103, 83, 164, 1),
                ),
              ),
              SizedBox(height: 15),

              // Timer: Remaining time in HH:MM:SS format
              Text(
                _formatDuration(remainingTime),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(103, 83, 164, 1),
                ),
              ),
              SizedBox(height: 32),

              // Slot Name
              Text(
                'Slot: ${widget.slotName}',
                style: TextStyle(
                  fontSize: 24,
                  color: Color.fromRGBO(103, 83, 164, 1),
                ),
              ),
              SizedBox(height: 32),

              // Stop and Extend Buttons
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Stop Button
                  SizedBox(
                    width: 200, // Fixed width for both buttons
                    height: 50, // Fixed height for both buttons
                    child: ElevatedButton(
                      onPressed: _isTimerRunning ? _stopTimer : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(103, 83, 164, 1),
                      ),
                      child: Text(
                        'Stop',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),

                  // Extend Button
                  SizedBox(
                    width: 200, // Fixed width for both buttons
                    height: 50, // Fixed height for both buttons
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
