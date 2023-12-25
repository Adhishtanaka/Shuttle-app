import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shuttle_v1/account.dart';
import 'package:location/location.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class BusUi extends StatefulWidget {
  const BusUi({super.key});

  @override
  State<BusUi> createState() => _BusUiState();
}

class _BusUiState extends State<BusUi> {
  final User? user = Account().currentUser;
  LocationData? currentLocation;
  bool isTrackingLocation = false;
  final database = FirebaseDatabase.instance.ref();
  int index = 0;
  late Timer locationUpdateTimer;
  String selectedMessage = 'Normal';
  String blpnum = '';
 
  @override
  void initState() {
    super.initState();
     
    locationUpdateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (isTrackingLocation) {
        uploadLocation();
      }
    });
    getBusBLP();

  }

  @override
  void dispose() {
    locationUpdateTimer.cancel();
    if (isTrackingLocation) {
      updateStatus(0);
    }
    super.dispose();
  }

  Future<void> updateBusMessage(String messageType) async {
    final userDatabase = database.child('users/${user?.uid ?? 'unknown'}');

    await userDatabase.update({
      'message': messageType,
    });
  }

  Future<void> updateStatus(int status) async {
    final userDatabase = database.child('users/${user?.uid ?? 'unknown'}');

    await userDatabase.update({
      'status': status,
    });
  }

Future<void> getBusBLP() async {
    final userDatabase = database.child('users/${user?.uid ?? 'unknown'}');
    userDatabase.child('blpnumber').onValue.listen((event) {
      final dynamic value = event.snapshot.value;
      if (value is String) {
        setState(() {
          blpnum = value;
        });
      } else {
        blpnum = '';
      }
    });
  }
  

  Future<void> updateLocation() async {
    Location location = Location();
    location.getLocation().then((locationData) {
      setState(() {
        currentLocation = locationData;
      });
    });

    location.onLocationChanged.listen((latestLocation) {
      if (isTrackingLocation) {
        setState(() {
          currentLocation = latestLocation;
        });
        uploadLocation();
      }
    });
  }

  Future<void> uploadLocation() async {
    final userDatabase = database.child('users/${user?.uid ?? 'unknown'}');

    if (currentLocation != null) {
      await userDatabase.update({
        'location': {
          'latitude': currentLocation!.latitude,
          'longitude': currentLocation!.longitude,
          'speed': currentLocation!.speed
        },
      });
      updateStatus(1);
    }
  }

  void toggleLocationTracking() {
    setState(() {
      isTrackingLocation = !isTrackingLocation;
    });

    if (isTrackingLocation) {
      updateLocation();
    } else {
      setState(() {
        currentLocation = null;
      });
      updateStatus(0);
    }
  }

  Future<void> signOut() async {
    await Account().signOut();
  }

  Widget _toggleLocationButton() {
    return ElevatedButton(
      onPressed: toggleLocationTracking,
      child: Text(isTrackingLocation ? 'Stop Sharing' : 'Share Location'),
    );
  }

  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }

  Widget _locationInfoText() {
    if (currentLocation != null) {
      return Text(
        'Latitude: ${currentLocation!.latitude}\nLongitude: ${currentLocation!.longitude}',
        style: const TextStyle(fontSize: 16),
      );
    } else {
      return const Text('Location not available');
    }
  }

  Widget _UserEmail() {
    return Text(
      user?.email ?? '',
      style: const TextStyle(fontSize: 16),
    );
  }

Widget _buildMessageDropdown() {
  List<String> messageOptions = ['Normal', 'Delay', 'Emergency'];

  return DropdownButton<String>(
    value: selectedMessage, 
    onChanged: (String? newValue) {
      setState(() {
        selectedMessage = newValue!;
        updateBusMessage(selectedMessage);
      });
    },
    items: messageOptions.map((String message) {
      return DropdownMenuItem<String>(
        value: message,
        child: Text(message),
      );
    }).toList(),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driver Portal')),
      body: _getPage(index),
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (index) => {setState(() => this.index = index)},
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _getPage(int index) {
    switch (index) {
      case 0:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Bus Status:', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8.0),
                  _buildMessageDropdown(),
                ],
              ),
              const SizedBox(height: 50.0),
              _locationInfoText(),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: _toggleLocationButton(),
              ),
            ],
          ),
        );
     case 1:
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        
        Text(
          "Licence Plate Number : " + blpnum,
        
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 25),  
        _UserEmail(),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _signOutButton(),
          ],
        ),
      ],
    ),
  );


      default:
        return Container();
    }
  }
}
