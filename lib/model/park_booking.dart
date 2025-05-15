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
