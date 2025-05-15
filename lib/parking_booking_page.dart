import 'package:car_park_booking/maps.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'book.dart';
import 'main.dart';
import 'package:flutter/services.dart';

// import 'package:gif/gif.dart';

// void main() {
//   runApp(MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (context) => ParkingProvider()),
//       ],
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         //
//         home: ParkingBookingPage(
//             targetSlot: ParkingSlot(id: 'A-6', area: 'Large'),
//             slotID: 123), // Example spot name passed
//       )));
// }

class ParkingBookingPage extends StatefulWidget {
  // final int slotID;
  // late ParkingSlot targetSlot;

  // ParkingBookingPage({required this.targetSlot, required this.slotID});

  @override
  _ParkingBookingPageState createState() => _ParkingBookingPageState();
}

class _ParkingBookingPageState extends State<ParkingBookingPage> {
  // late GifController controller;

  void initState() {
    super.initState();
    // controller = GifController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
  }

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay(hour: 10, minute: 00);
  TextEditingController hourController = TextEditingController();
  TextEditingController minuteController = TextEditingController();
  String? errorMessage;

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: selectedDate,
      lastDate: DateTime(2030, 12, 31),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  bool _validateDuration() {
    int hours = int.tryParse(hourController.text) ?? 0;
    int minutes = int.tryParse(minuteController.text) ?? 0;
    int totalMinutes = hours * 60 + minutes;

    // Check if total time is between 10 minutes and 12 hours
    if (totalMinutes >= 10 && totalMinutes <= 12 * 60) {
      setState(() {
        errorMessage = null;
      });
      print("Selected Duration: $hours hours $minutes minutes");
      return true;
    } else {
      setState(() {
        errorMessage =
            "Invalid duration. Please enter a value between 10 minutes and 12 hours.";
      });
      return false;
    }
  }

  void _validateHour(String value) {
    int hour = int.tryParse(value) ?? 0;
    if (hour < 0) {
      hourController.text = "00"; // Prevent negative hour input
    }
  }

  void _validateMinute(String value) {
    int minute = int.tryParse(value) ?? 0;
    if (minute < 0 || minute > 59) {
      minuteController.text = minute < 0 ? "00" : "59";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Book Parking Details for ${Provider.of<ParkingProvider>(context).parkID}'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),

              // Date selection
              Text("Start Date",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('MMM dd, yyyy').format(selectedDate)),
                      Icon(Icons.calendar_today, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Start time selection
              Text("Start Time",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectTime(context),
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(selectedTime.format(context)),
                      Icon(Icons.access_time, color: Colors.grey),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Duration input
              Text("Duration",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 60,
                              child: TextFormField(
                                controller: hourController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 8),
                                  hintText: "HH",
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter
                                      .digitsOnly, // Allow only numbers
                                  LengthLimitingTextInputFormatter(2),
                                  _HourInputFormatter(), // Custom restriction (0-23)
                                ],
                                onChanged: _validateHour,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 16), // Adjust spacing
                        // Padding(
                        // padding: const EdgeInsets.only(bottom: 30.0),
                        // child:
                        Text(":",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)),
                        // ),
                        SizedBox(width: 16), // Adjust spacing
                        Column(
                          children: [
                            Container(
                              width: 60,
                              child: TextFormField(
                                controller: minuteController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 8),
                                  hintText: "MM",
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(2),
                                  _MinuteInputFormatter(), // Custom restriction (0-59)
                                ],
                                onChanged: _validateMinute,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    if (errorMessage != null)
                      Text(
                        errorMessage!,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceEvenly, // Distributes space evenly
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => MapScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(103, 83, 164, 1),
                        minimumSize: Size(double.infinity, 50),
                      ),
                      child: Text("Cancel",
                          style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  SizedBox(width: 50),
                  Expanded(
                    child: Consumer<ParkingProvider>(
                      builder: (context, parkProvider, child) {
                        return ElevatedButton(
                          onPressed: () {
                            if (_validateDuration()) {
                              int selectedHours =
                                  int.tryParse(hourController.text) ?? 0;
                              int selectedMinutes =
                                  int.tryParse(minuteController.text) ?? 0;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ParkingSlotsScreen(
                                            bookDate: DateTime(
                                              selectedDate.year,
                                              selectedDate.month,
                                              selectedDate.day,
                                              selectedTime.hour,
                                              selectedTime.minute,
                                            ),
                                            bookDuration: {
                                              'hour': selectedHours,
                                              'min': selectedMinutes
                                            })),
                              );

                              // parkProvider.bookSlot(
                              //   widget.targetSlot.id,
                              //   selectedHours,
                              //   selectedMinutes,
                              //   DateFormat('yyyy-MM-dd').format(
                              //       selectedDate), // Format selectedDate as a string
                              // );
                              // _showBookingDetails(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(103, 83, 164, 1),
                            minimumSize: Size(double.infinity, 50),
                          ),
                          child: Text("Choose Slot",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white)),
                        );
                      },
                    ),
                  ),
                  // Space between buttons
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom formatter to ensure valid hour input (0-23)
class _HourInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    int? value = int.tryParse(newValue.text);
    if (value == null || value < 0 || value > 23) {
      return oldValue;
    }
    return newValue;
  }
}

// Custom formatter to ensure valid minute input (0-59)
class _MinuteInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    int? value = int.tryParse(newValue.text);
    if (value == null || value < 0 || value > 59) {
      return oldValue;
    }
    return newValue;
  }
}
