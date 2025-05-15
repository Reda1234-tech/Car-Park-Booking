import '../model/park_booking.dart';

class Bookings {
  static List<ParkBooking> bookings = [
    ParkBooking(
        date: DateTime(2025, 2, 3, 10, 0),
        duration: {'hour': 2, 'min': 30},
        parkingID: "nearresho",
        slotNumber: "ت-1",
        userID: "user123"),
    ParkBooking(
        date: DateTime(2025, 2, 4, 11, 0),
        duration: {'hour': 3, 'min': 0},
        parkingID: "nearresho",
        slotNumber: "ب-1",
        userID: "user123"),
    ParkBooking(
        date: DateTime(2025, 2, 4, 11, 0),
        duration: {'hour': 1, 'min': 30},
        parkingID: "nearresho",
        slotNumber: "أ-3",
        userID: "user456"),
    ParkBooking(
        date: DateTime(2025, 2, 3, 12, 0),
        duration: {'hour': 1, 'min': 30},
        parkingID: "nearresho",
        slotNumber: "ب-3",
        userID: "user456"),
    ParkBooking(
        date: DateTime(2025, 2, 3, 10, 0),
        duration: {'hour': 2, 'min': 30},
        parkingID: "feer",
        slotNumber: "B1",
        userID: "user456"),
  ];
}
