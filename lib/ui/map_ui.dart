import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shuttle_v1/ui/details_ui.dart';
import 'package:shuttle_v1/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

class MapUi extends StatefulWidget {
  final String uid;

  const MapUi({super.key, required this.uid});

  @override
  State<MapUi> createState() => estimated();
}

class estimated extends State<MapUi> {
  final database = FirebaseDatabase.instance.ref();
  late GoogleMapController mapController1;
  final Completer<GoogleMapController> mapController2 = Completer();
  late LatLng currentBusLocation;
  late Timer locationUpdateTimer;
  late Marker driverMarker;
  String message = "";
  late String tappedMarkerInfo = "";
  late int sub;
  late PolylinePoints polylinePoints;
  late List<LatLng> polylineCoordinates = [];
  late SharedPreferences prefs;
  late LatLng tappedPosition = LatLng(0.0, 0.0);
  late bool timeModeOn;
  late bool animatePause = false;

  @override
  void initState() {
    super.initState();
    timeModeOn = false;
    _initializePrefs().then((_) {
      driverMarker = Marker(
        markerId: const MarkerId('Bus'),
        position: const LatLng(0.0, 0.0),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: "Shuttle"),
      );

      polylinePoints = PolylinePoints();
      fetchMessageUpdate();
      fetchLocationUpdate();

      locationUpdateTimer =
          Timer.periodic(const Duration(seconds: 3), (timer) {
        fetchLocationUpdate();
        fetchMessageUpdate();
      });

      fetchSubUpdate();
    });
  }

  //adding sharedpreferences
  Future<void> _initializePrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  //fetching route and show polyline
  Future<void> fetchRoute() async {
    if (currentBusLocation != null) {
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        googleMapsApiKey,
        const PointLatLng(6.821403, 80.041684),
        PointLatLng(currentBusLocation.latitude, currentBusLocation.longitude),
        travelMode: TravelMode.driving,
      );

      if (result.points.isNotEmpty) {
        setState(() {
          polylineCoordinates = result.points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
        });
      }
    }
  }

  //fetch message
  Future<void> fetchMessageUpdate() async {
    final messageSnapshot =
        await database.child('users/${widget.uid}/message').get();

    if (messageSnapshot.value != null) {
      setState(() {
        message = messageSnapshot.value.toString();
      });
    }
  }

  //fetch & upload subscriber count by increasing one
  Future<void> fetchSubUpdate() async {
    print("Checking SharedPreferences for 'sub' value");
    if (prefs.getInt('sub') == null) {
      print(
          "'sub' value not found in SharedPreferences. Fetching from database.");
      final subSnapshot = await database.child('users/${widget.uid}/sub').get();

      if (subSnapshot.value != null) {
        setState(() {
          sub = (subSnapshot.value as num).toInt();
          sub++;
        });

        await database.child('users/${widget.uid}/sub').set(sub);

        prefs.setInt('sub', sub);
        print("'sub' value updated and saved in SharedPreferences: $sub");
      }
    } else {
      print(
          "'sub' value found in SharedPreferences. No need to fetch from database.");
    }
  }

   //fetch location
  Future<void> fetchLocationUpdate() async {
    final locationSnapshot =
        await database.child('users/${widget.uid}/location').get();

    if (locationSnapshot.value != null) {
      final locationData = locationSnapshot.value as Map<dynamic, dynamic>?;

      if (locationData != null) {
        final double? latitude = locationData['latitude'];
        final double? longitude = locationData['longitude'];

        if (latitude != null && longitude != null) {
          final LatLng newLocation = LatLng(latitude, longitude);

          setState(() {
            currentBusLocation = newLocation;
            driverMarker = driverMarker.copyWith(
              positionParam: newLocation,
            );
          });
             if(animatePause == false) {
          mapController2.future.then((controller) {
            controller.animateCamera(
              CameraUpdate.newLatLngZoom(newLocation, 17.0),
            );
          });}
        }
      }
    }
  }

 //fetch estimated travel time
  Future<void> fetchTravelTime(LatLng destination) async {
    final String origin =
        '${currentBusLocation.latitude},${currentBusLocation.longitude}';
    final String destinationStr =
        '${destination.latitude},${destination.longitude}';
    final String url =
        'https://maps.googleapis.com/maps/api/distancematrix/json?units=metric&origins=$origin&destinations=$destinationStr&key=$googleMapsApiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decodedResponse = json.decode(response.body);
      final now = DateTime.now();
      final estimatedArrival = now.add(Duration(
          seconds: decodedResponse['rows'][0]['elements'][0]['duration']
              ['value']));

      final estimatedArrivalTime =
          TimeOfDay.fromDateTime(estimatedArrival).format(context);

      setState(() {
        tappedMarkerInfo = 'Estimated Shuttle Arrival: $estimatedArrivalTime';
      });
    } else {
      print('Failed to fetch travel time: ${response.reasonPhrase}');
    }
  }

  //this for adding marker to estimate time for pickup location
  void _handleMapTap(LatLng tappedPoint) {
    animatePause = false;
    if (timeModeOn) {
      setState(() {
        tappedPosition = tappedPoint;
        fetchTravelTime(tappedPoint);
        timeModeOn = false;
      });
    }
  }

  @override
  void dispose() {
    locationUpdateTimer.cancel();
    super.dispose();
  }

  void onPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DetailsUi(uid: widget.uid ?? "")),
    );
  }

 //ui
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Map'),
          actions: <Widget>[
            IconButton(
              onPressed: onPressed,
              icon: const Icon(Icons.info),
            )
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Bus Status : " + message,
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            timeModeOn = !timeModeOn;
                            animatePause = true;
                          });
                          if (timeModeOn) {
                            Fluttertoast.showToast(
                              msg:
                                  "Select pickup location by clicking on the polyline",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                            );
                          }
                        },
                        icon: Icon(
                          Icons.add_location,
                          color: timeModeOn
                              ? Colors.red
                              : Colors
                                  .black, 
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: currentBusLocation == null
            ? const Center(
                child: Text("Loading"),
              )
            : GoogleMap(
                onMapCreated: (mapController) {
                  mapController2.complete(mapController);
                  fetchRoute();
                },
                initialCameraPosition: CameraPosition(
                  target: currentBusLocation,
                  zoom: 17.0,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('tappedPosition'),
                    infoWindow: InfoWindow(title: tappedMarkerInfo),
                    position: tappedPosition,
                  ),
                  driverMarker,
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                compassEnabled: true,
                onTap: _handleMapTap,
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    color: Colors.blue,
                    points: polylineCoordinates,
                  ),
                },
              ));
  }
}
