import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CurrentReservePage(
        slotName: 'ب-2',
        reservedTime: DateTime(2025, 2, 2, 13, 0), // Example reserved time
        duration: Duration(hours: 2), // Example duration
      ),
    );
  }
}

class CurrentReservePage extends StatefulWidget {
  final String slotName;
  final DateTime reservedTime;
  final Duration duration;

  const CurrentReservePage({
    super.key,
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
  bool _isTimerRunning = true;
  bool _isExpired = false;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    if (!_isExpired) {
      _startTimer();
    }
  }

  void _calculateRemainingTime() {
    DateTime now = DateTime.now();
    DateTime endTime = widget.reservedTime.add(widget.duration);

    if (now.isBefore(widget.reservedTime)) {
      // Booking hasn't started yet
      remainingTime = widget.reservedTime.difference(now);
      _isTimerRunning = false;
    } else if (now.isAfter(endTime)) {
      // Booking time has expired
      remainingTime = Duration.zero;
      _isExpired = true;
      _isTimerRunning = false;
    } else {
      // Booking is ongoing
      remainingTime = endTime.difference(now);
    }
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

  void _stopTimer() {
    setState(() {
      _timer?.cancel();
      _isTimerRunning = false;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
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
              Text('Slot: ${widget.slotName}',
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
                        onPressed: _isTimerRunning ? _stopTimer : null,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(103, 83, 164, 1)),
                        child: Text('Stop',
                            style:
                                TextStyle(fontSize: 18, color: Colors.white)),
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
