import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'book.dart';
import 'package:provider/provider.dart';
import 'main.dart';
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
    "parkName": "temp1",
    "parkSlots": [
      ParkingSlot(id: 'A-1', area: 'Small'),
      ParkingSlot(id: 'A-2', area: 'Medium'),
      ParkingSlot(id: 'A-3', area: 'Large'),
      ParkingSlot(id: 'A-4', area: 'Medium'),
      ParkingSlot(id: 'B-1', area: 'Small'),
    ]
  },
  {
    "parkName": "nearresho",
    "parkSlots": [
      ParkingSlot(id: 'B-2', area: 'Large'),
      ParkingSlot(id: 'B-3', area: 'Small'),
      ParkingSlot(id: 'B-4', area: 'Medium'),
      ParkingSlot(id: 'C-1', area: 'Small'),
      ParkingSlot(id: 'C-2', area: 'Large'),
    ]
  },
  {
    "parkName": "AbvNorthPark",
    "parkSlots": [
      ParkingSlot(id: 'D-1', area: 'Small'),
      ParkingSlot(id: 'D-2', area: 'Large'),
      ParkingSlot(id: 'E-2', area: 'Large'),
      ParkingSlot(id: 'G-1', area: 'Small'),
      ParkingSlot(id: 'G-2', area: 'Large'),
      ParkingSlot(id: 'H-1', area: 'Small'),
      ParkingSlot(id: 'H-2', area: 'Large'),
      ParkingSlot(id: 'I-1', area: 'Small'),
      ParkingSlot(id: 'I-2', area: 'Large'),
      ParkingSlot(id: 'J-1', area: 'Small'),
      ParkingSlot(id: 'J-2', area: 'Large'),
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

  List<Map<String, dynamic>> parkingNamesLoc = [
    {
      "parkingName": "SouthPark",
      "parkingLoc": LatLng(28.381887070530755, 36.48516313513801),
    },
    {
      "parkingName": "BlwMiddlePark",
      "parkingLoc": LatLng(28.38430764818877, 36.48233091840871),
    },
    {
      "parkingName": "MiddlePark",
      "parkingLoc": LatLng(28.386086163460778, 36.48629568337576),
    },
    /*
    {
      "parkingName": "BtwMiddlePark",
      "parkingLoc": LatLng(28.38385457510328, 36.48241674909716),
    },
    {
      "parkingName": "NorthPark",
      "parkingLoc": LatLng(28.391850748988013, 36.478448742014166),
    },
    */
    {
      "parkingName": "AbvNorthPark",
      "parkingLoc": LatLng(28.394981997394027, 36.477801571592586),
    },
    {
      "parkingName": "temp1",
      "parkingLoc": LatLng(28.391048436166116, 36.478019580309514),
    },
    {
      "parkingName": "nearresho",
      "parkingLoc": LatLng(28.39407811999997, 36.47768698639167),
    },
    /*
    {
      "parkingName": "faiezrashedy",
      "parkingLoc": LatLng(28.373652902944748, 36.474148326350225),
    },
    {
      "parkingName": "shareaafaculty",
      "parkingLoc": LatLng(28.37391046232078, 36.47226390499414),
    },
    */
  ];
/*
  Future<void> _searchLocation(String query) async {
    if (query.isNotEmpty) {
      try {
        // Attempt to get the location from the address
        List<Location> locations = await locationFromAddress(query);

        // If no results found, suggest nearby or fallback to default location
        if (locations.isNotEmpty) {
          // _controller!.animateCamera(
          //   CameraUpdate.newLatLng(
          //     LatLng(locations[0].latitude, locations[0].longitude),
          //   ),
          // );
        } else {
          // No result found: Suggest a nearby location or default
          print(
              'No exact match found for $query. Suggesting a nearby location.');

          // Fallback to a predefined location (e.g., user's current location or a default city)
          // Example: using a default location like "New York"
          // List<Location> fallbackLocation =
          //     await locationFromAddress("New York, NY");

          List<Placemark> placemarks =
              await placemarkFromCoordinates(52.2165157, 6.9437819);

          // if (fallbackLocation.isNotEmpty) {
          // _controller!.animateCamera(
          //   CameraUpdate.newLatLng(
          //     LatLng(fallbackLocation[0].latitude,
          //         fallbackLocation[0].longitude),
          //   ),
          // );
          // } else {
          //   print('No fallback location found either.');
          // }
        }
      } catch (e) {
        // Handle errors such as network issues, API failures
        print('Error during geocoding: $e');

        // Fallback action: try using a default location if an error occurs
        // List<Location> fallbackLocation =
        //     await locationFromAddress("New York, NY");
        List<Placemark> placemarks =
            await placemarkFromCoordinates(52.2165157, 6.9437819);

        // if (fallbackLocation.isNotEmpty) {
        //   _controller!.animateCamera(
        //     CameraUpdate.newLatLng(
        //       LatLng(
        //           fallbackLocation[0].latitude, fallbackLocation[0].longitude),
        //     ),
        //   );
        // }
      }
    } else {
      print('Search query is empty. Suggesting default location.');
      // Default to a predefined location when the query is empty
      // List<Location> defaultLocation =
      //     await locationFromAddress("San Francisco, CA");

      List<Placemark> placemarks =
          await placemarkFromCoordinates(52.2165157, 6.9437819);

      // if (defaultLocation.isNotEmpty) {
      //   _controller!.animateCamera(
      //     CameraUpdate.newLatLng(
      //       LatLng(defaultLocation[0].latitude, defaultLocation[0].longitude),
      //     ),
      //   );
      // }
    }
  }
*/
/*
  // Method to search location by address
  Future<void> _searchLocation(String query) async {
    try {
      // Call locationFromAddress to get coordinates of the query address
      List<Location> locations =
          await GeocodingPlatform.instance!.locationFromAddress(query);

      if (locations.isNotEmpty) {
        // If location found, animate the camera to the location
        _controller!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(locations[0].latitude, locations[0].longitude),
          ),
        );
      } else {
        print('No location found for the query: $query');
      }
    } catch (e) {
      print('Error during geocoding: $e');

      // Fallback to a predefined location (e.g., New York) if error occurs
      List<Location> fallbackLocation =
          await locationFromAddress("New York, NY");

      if (fallbackLocation.isNotEmpty) {
        _controller!.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(fallbackLocation[0].latitude, fallbackLocation[0].longitude),
          ),
        );
      }
    }
  }

  void _onSearchButtonPressed() {
    _searchLocation("San Francisco, CA");
  }
*/
/*
Future<Null> displayPrediction(Prediction p) async {
    if (p != null) {
      PlacesDetailsResponse detail =
      await _places.getDetailsByPlaceId(p.placeId!);

      var placeId = p.placeId;
      double lat = detail.result.geometry!.location.lat;
      double lng = detail.result.geometry!.location.lng;

      var address = await Geocoder.local.findAddressesFromQuery(p.description);

      print(lat);
      print(lng);
    }
  }
  */

  @override
  Widget build(BuildContext context) {
    // final parkingProvider = Provider.of<ParkingProvider>(context, listen: true);

    markers = parkingNamesLoc.map((item) {
      return Marker(
        markerId: MarkerId(item['parkingName']),
        position: item['parkingLoc'],
        onTap: () {
          // List<Map<String, dynamic>> targetSlot = parkingLoc
          //     .where((test) => test["parkName"] == item['parkingName'])
          //     .toList();
          // if (targetSlot.isEmpty) return;

          List<ParkingSlot> selectedSlots = [];
          var selectedParking = parkingLoc.firstWhere(
            (p) => p["parkName"] == item["parkingName"],
            orElse: () => {},
          );

          if (selectedParking.isNotEmpty) {
            selectedSlots =
                List<ParkingSlot>.from(selectedParking["parkSlots"]);
          }

          Provider.of<ParkingProvider>(context, listen: false)
              .setParkingSlots(selectedSlots);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ParkingSlotsScreen(),
              // parkingName: item['parkingName'], parkingLoc: selectedSlots
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
                          zoom: 15, // Default zoom level
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
                // ElevatedButton(
                // onPressed: () async {
                //   Prediction? p = await PlacesAutocomplete.show(
                //       context: context, apiKey: kGoogleApiKey);
                //   displayPrediction(p);
                // },
                // onPressed: _onSearchButtonPressed,
                //   child: Text("click"),
                // ),
                // Padding(
                //   padding: const EdgeInsets.all(10.0),
                //   child: SizedBox(
                //     width: 300,
                //     child: TextField(
                //       onChanged: (query) {
                //         // _searchLocation(query);
                //       },
                //       // style: ,

                //       decoration: InputDecoration(
                //         hintText: 'Search location',
                //         prefixIcon: Icon(Icons.search),
                //         border: OutlineInputBorder(),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
          ),
          // Padding(
          //   padding: EdgeInsets.all(16.0),
          //   child: ElevatedButton(
          //     onPressed: () {
          //       // ✅ Navigating to ParkingSpotScreen
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => ParkingSpotScreen()),
          //       );
          //     },
          //     child: ,
          //   ),
          // ),
        ],
      ),
    );
  }
}
