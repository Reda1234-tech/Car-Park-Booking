import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'parking_booking_page_copy.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:geocoding/geocoding.dart';
// import 'package:flutter_google_places/flutter_google_places.dart';
// import 'package:google_maps_webservice/places.dart';

// import 'package:flutter/scheduler.dart';

// void main() {
//   runApp(
//     // MultiProvider(
//     //   providers: [
//     //     ChangeNotifierProvider(create: (context) => ParkingProvider()),
//     //   ],
//     ChangeNotifierProvider(
//       create: (context) => ParkingProvider(),
//       child: ParkingApp(),
//     ),
//   );
// }

List<Map<String, dynamic>> parkingLoc = [
  {
    "parkName": "downtown_parking",
    "parkSlots": [
      ParkingSlot(
          parkingID: 'downtown_parking',
          area: {'width': 500, 'height': 200},
          number: "A1"),
      ParkingSlot(
          parkingID: 'feer', area: {'width': 400, 'height': 300}, number: "A2"),
      ParkingSlot(
          parkingID: 'feer', area: {'width': 300, 'height': 500}, number: "B1"),
      ParkingSlot(
          parkingID: 'downtown_parking',
          area: {'width': 600, 'height': 100},
          number: "C1"),
    ]
  },
  {
    "parkName": "feer",
    "parkSlots": [
      ParkingSlot(
          parkingID: 'downtown_parking',
          area: {'width': 500, 'height': 200},
          number: "A1"),
      ParkingSlot(
          parkingID: 'downtown_parking',
          area: {'width': 400, 'height': 300},
          number: "A2"),
      ParkingSlot(
          parkingID: 'feer', area: {'width': 300, 'height': 500}, number: "B1"),
      ParkingSlot(
          parkingID: 'feer', area: {'width': 600, 'height': 100}, number: "C1"),
    ]
  }
];

const kGoogleApiKey = "AIzaSyAIb-HJSutTY63dIxqAVYZ9dAl6fE-BsQA";

// GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: kGoogleApiKey);

class ParkingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;
  Set<Marker> markers = Set();

  final double _latitude = 28.39412359758817;
  final double _longitude = 36.47677376620625;
  final String _apiKey = 'AIzaSyAIb-HJSutTY63dIxqAVYZ9dAl6fE-BsQA';

  @override
  void initState() {
    super.initState();
    // _loadParkingSpots();
    _fetchParkingPlaces();
  }

  Future<void> _fetchParkingPlaces() async {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('parking_places').get();
    setState(() {
      parkingPlaces = snapshot.docs
          .map((doc) {
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
              "parkingID": data['parking_id'],
              "parkingLoc": LatLng(lat, long),
            };
          })
          .where((item) => item != null)
          .toList()
          .cast<Map<String, dynamic>>(); // Cast to non-nullable list
    });
  }

  // Function to fetch nearby parking from Google Places API
  Future<List<Map<String, dynamic>>> fetchNearbyParking(
      double latitude, double longitude) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=2000&type=parking&key=$_apiKey';

    final response = await http.get(Uri.parse(url));

    try {
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print('API Response: $data');

        if (data['results'] == null || data['results'].isEmpty) {
          print("No parking spots found...");
          return [];
        }

        List<Map<String, dynamic>> parkingSpots = [];
        for (var place in data['results']) {
          parkingSpots.add({
            'name': place['name'],
            'lat': place['geometry']['location']['lat'],
            'lng': place['geometry']['location']['lng'],
            'address': place['vicinity'],
          });
        }
        return parkingSpots;
      } else {
        throw Exception('Failed to load parking spots: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching parking spots: $e');
      return []; // Return an empty list in case of an error
    }
  }

  List<Map<String, dynamic>> parkingPlaces = [
    {
      "parkingID": "downtown_parking",
      "parkingLoc": LatLng(28.381887070530755, 36.48516313513801),
    },
    {
      "parkingID": "feer",
      "parkingLoc": LatLng(28.38430764818877, 36.48233091840871),
    },
  ];

  @override
  Widget build(BuildContext context) {
    markers = parkingPlaces.where((item) => item != null).map((item) {
      return Marker(
        markerId: MarkerId(item['parkingID']),
        position: item['parkingLoc'],
        onTap: () {
          List<ParkingSlot> selectedSlots = [];
          var selectedParking = parkingLoc.firstWhere(
            (p) => p["parkName"] == item["parkingID"],
            orElse: () => {},
          );

          if (selectedParking.isNotEmpty) {
            selectedSlots =
                List<ParkingSlot>.from(selectedParking["parkSlots"]);
          }

          Provider.of<ParkingProvider>(context, listen: false)
              .setParkingSlots(selectedSlots);

          Provider.of<ParkingProvider>(context, listen: false)
              .setParkingID(item["parkingID"]);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ParkingBookingPage(),
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
          SizedBox(
            height: 20,
          ),
          Text('Select A Parking Spot',
              style: TextStyle(
                fontSize: 14,
              )),
          SizedBox(
            height: 20,
          ),
          Expanded(
            // height: 500,
            // width: 500,
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Consumer(builder: (context, provider, child) {
                    return Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                        Radius.circular(50),
                      )),
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target:
                              LatLng(_latitude, _longitude), // Center of campus
                          zoom: 14, // Default zoom level
                        ),
                        buildingsEnabled: true,
                        compassEnabled: true,
                        mapType: MapType.hybrid,
                        markers: markers,
                        onMapCreated: (GoogleMapController controller) {
                          _controller = controller;
                        },
                        myLocationButtonEnabled: true,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
          ),
        ],
      ),
    );
  }
}
