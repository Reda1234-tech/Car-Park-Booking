import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'book.dart';
import 'main.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  Set<Marker> markers = Set();
  final double _latitude = 28.39412359758817;
  final double _longitude = 36.47677376620625;
  List<Map<String, dynamic>> parkingPlaces = [];

  @override
  void initState() {
    super.initState();
    _fetchParkingPlaces();
  }

  Future<void> _fetchParkingPlaces() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('parking_places').get();
    setState(() {
      parkingPlaces = snapshot.docs.map((doc) {
        final data = doc.data();
        print('Fetched data: $data'); // Print fetched data
        final location = data['location'] as Map<String, dynamic>?;
        final lat = location?['lat'] as double?;
        final long = location?['long'] as double?;

        if (lat == null || long == null) {
          print('Invalid location data for ${data['name']}');
          return null; // Return null for invalid entries
        }

        return {
          "parkingName": data['name'],
          "parkingLoc": LatLng(lat, long),
        };
      }).where((item) => item != null).toList().cast<Map<String, dynamic>>(); // Cast to non-nullable list
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filter out null values and create markers
    markers = parkingPlaces
        .where((item) => item != null) // Filter out null values
        .map((item) {
      return Marker(
        markerId: MarkerId(item!['parkingName']), // Use non-null assertion
        position: item['parkingLoc'],
        onTap: () {
          List<ParkingSlot> selectedSlots = [];

          // Find the selected parking place
          var selectedParking = parkingPlaces.firstWhere(
                (p) => p["parkingName"] == item["parkingName"],
            orElse: () => <String, dynamic>{}, // Return an empty map if not found
          );

          // Check if the selected parking place is not empty
          if (selectedParking.isNotEmpty) {
            // Assuming selectedParking contains a list of slots under the key "parkSlots"
            if (selectedParking["parkSlots"] != null) {
              selectedSlots = List<ParkingSlot>.from(selectedParking["parkSlots"]);
            }
          }

          // Update the provider or navigate to the next screen
          Provider.of<ParkingProvider>(context, listen: false)
              .setParkingSlots(selectedSlots);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ParkingSlotsScreen(),
            ),
          );
        },
      );
    }).toSet();

    return Scaffold(
      appBar: AppBar(
        title: Text('Parking Map'),
        backgroundColor: Color.fromRGBO(103, 83, 164, 1),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text('Select A Parking Spot', style: TextStyle(fontSize: 14)),
          SizedBox(height: 20),
          Expanded(
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Consumer(builder: (context, provider, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(_latitude, _longitude),
                          zoom: 15,
                        ),
                        buildingsEnabled: true,
                        compassEnabled: true,
                        mapType: MapType.hybrid,
                        markers: markers,
                        onMapCreated: (GoogleMapController controller) {
                          _controller = controller;
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}