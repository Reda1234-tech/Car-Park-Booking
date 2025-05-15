import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import '../widgets/maps.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/firebase_options.dart';
import '../widgets/signup_page.dart';

import '../provider/parking_provider.dart';
import '../model/park_booking.dart';
import '../model/park_slot.dart';

import '../data/bookings.dart';

class ParkingProvider extends ChangeNotifier {
  List<ParkBooking> bookedSlots = [];
  List<ParkingSlot> _slots = [];
  String _parkID = "downtown_parking";
  bool isLoading = true;

  List<ParkingSlot> get slots => _slots;
  String get parkID => _parkID;

  // Set the initial list of slots (can be dynamic or from an API)
  void setParkingSlots(List<ParkingSlot> newSlots) {
    _slots = newSlots;

    notifyListeners();
  }

  void setBookedSlots(List<ParkBooking> newBookedSlots) {
    bookedSlots = newBookedSlots;
    notifyListeners();
  }

  void setParkingID(String parkingID) {
    _parkID = parkingID;

    notifyListeners();
  }

  Future<void> fetchSlots(String parkingID) async {
    final firestore = FirebaseFirestore.instance;
    try {
      final snapshot = await firestore
          .collection('slots')
          .where('parking_id', isEqualTo: parkingID)
          .get();

      _slots = snapshot.docs.map((doc) {
        final data = doc.data();

        // Convert 'area' to Map<String, double>
        final Map<String, double> area = (data['area'] as Map<String, dynamic>)
            .map((key, value) => MapEntry(key, (value as num).toDouble()));

        return ParkingSlot(
          parkingID: data['parking_id'],
          area: area,
          number: data['number'],
        );
      }).toList();
    } catch (e) {
      print('Error in fetching slots: $e');
    }

    notifyListeners();
  }

  //Fetch all bookings
  Future<List<Map<String, dynamic>>> fetchBookings(String parkingId) async {
    try {
      // Reference to the bookings collection
      CollectionReference bookingsRef =
          FirebaseFirestore.instance.collection('bookings');

      // Query the collection for bookings matching the parking ID
      QuerySnapshot snapshot =
          await bookingsRef.where('parking_id', isEqualTo: parkingId).get();

      // Convert documents into a list of maps
      List<Map<String, dynamic>> bookings = snapshot.docs.map((doc) {
        return {
          'id': doc.id, // Document ID
          'booking_details': ParkBooking(
              parkingID: doc['parking_id'],
              slotNumber: doc['slot_number'],
              date: (doc['date'] as Timestamp).toDate(),
              duration: Map<String, int>.from(doc['duration']),
              userID: doc['user_id'])
        };
      }).toList();

      print('Fetched ${bookings.length} bookings for parking ID: $parkingId');
      return bookings;
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  // Book a slot
  void bookSlot(String id, int hours, int minutes, String date) {
    int index = slots.indexWhere((slot) => slot.number == id);
    if (index != -1) {
      // slots[index].isBooked = true;
      // slots[index].hours = hours;
      // slots[index].minutes = minutes;
      // slots[index].startDate = date;
      notifyListeners();
    }
  }

  Future<void> addBooking(String userId, String parkingId, String slotNumberr,
      DateTime date, Map<String, int> duration) async {
    try {
      // Reference to the bookings collection
      CollectionReference bookingsRef =
          FirebaseFirestore.instance.collection('bookings');

      // Add booking document
      DocumentReference docRef = await bookingsRef.add({
        'user_id': userId,
        'parking_id': parkingId, // Link to the parking place
        'slot_number': slotNumberr, // Link to the slot
        'date': date,
        'duration': duration,
      });

      // Check if the document was added successfully
      if (docRef.id.isNotEmpty) {
        print('Booking added successfully with ID: ${docRef.id}');
        // FETCH ALL BOOKINGS
        // TEMP ADD
        Bookings.bookings.add(ParkBooking(
            date: date,
            duration: duration,
            parkingID: parkingId,
            slotNumber: slotNumberr,
            userID: userId));
        notifyListeners();
      } else {
        print('Booking failed: Document reference is empty.');
      }
    } catch (e) {
      print('Error adding booking: $e');
    }
  }

  Future<void> extendBookingDuration(
      String bookingId, int extraHours, int extraMinutes) async {
    try {
      // Reference to the specific booking document
      DocumentReference bookingRef =
          FirebaseFirestore.instance.collection('bookings').doc(bookingId);

      // Get the current booking data
      DocumentSnapshot bookingSnapshot = await bookingRef.get();

      if (!bookingSnapshot.exists) {
        print("Booking not found!");
        return;
      }

      // Extract the current duration and update it
      Map<String, int> currentDuration =
          Map<String, int>.from(bookingSnapshot['duration']);

      // Get the existing hours and minutes
      int updatedHours = currentDuration['hour'] ?? 0;
      int updatedMinutes = currentDuration['min'] ?? 0;

      // Add extra duration
      updatedHours += extraHours;
      updatedMinutes += extraMinutes;

      // Handle overflow of minutes (e.g., 90 min -> 1 hour 30 min)
      if (updatedMinutes >= 60) {
        updatedHours += updatedMinutes ~/ 60; // Convert excess minutes to hours
        updatedMinutes = updatedMinutes % 60; // Keep only remaining minutes
      }

      // Update Firestore
      await bookingRef.update({
        'duration': {
          'hour': updatedHours,
          'min': updatedMinutes,
        }
      });
      notifyListeners();

      print(
          "Booking duration extended by $extraHours hours and $extraMinutes minutes.");
      print("New duration: $updatedHours hours and $updatedMinutes minutes.");
    } catch (e) {
      print("Error extending booking duration: $e");
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    try {
      // Reference to the specific booking document
      DocumentReference bookingRef =
          FirebaseFirestore.instance.collection('bookings').doc(bookingId);

      // Check if the booking exists before attempting to delete
      DocumentSnapshot bookingSnapshot = await bookingRef.get();

      if (!bookingSnapshot.exists) {
        print("Booking not found!");
        return;
      }

      // Delete the document
      await bookingRef.delete();
      print("Booking with ID: $bookingId has been successfully deleted.");
      notifyListeners();
    } catch (e) {
      print("Error deleting booking: $e");
    }
  }
}
