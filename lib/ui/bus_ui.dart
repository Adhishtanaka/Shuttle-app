import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shuttle_v1/account.dart';
import 'package:location/location.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';

class BusUi extends StatefulWidget {
  const BusUi({super.key});

  @override
  State<BusUi> createState() => license();
}

class license extends State<BusUi> {
  final User? user = Account().currentUser;
  LocationData? currentLocation;
  bool isTrackingLocation = false;
  final database = FirebaseDatabase.instance.ref();
  int index = 0;
  late Timer locationUpdateTimer;
  String selectedMessage = 'To NSBM';
  String blpnum = '';
 
  @override
  void initState() {
    super.initState();
     
    locationUpdateTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (isTrackingLocation) {
         updateStatus(1);
        uploadLocation();
      }else{
         updateStatus(0);
      }
    });
    getBusBLP();

  }

  @override
  void dispose() {
    locationUpdateTimer.cancel();
    updateStatus(0);
    super.dispose();
  }

  //update bus message
  Future<void> updateBusMessage(String messageType) async {
    final userDatabase = database.child('users/${user?.uid ?? 'unknown'}');

    await userDatabase.update({
      'message': messageType,
    });
  }

//update bus status offline or not
  Future<void> updateStatus(int status) async {
    final userDatabase = database.child('users/${user?.uid ?? 'unknown'}');

    await userDatabase.update({
      'status': status,
    });
  }

//get bus licence plate number
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
  
  //updating bus location using gpu
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

   //uploading that updated location to firebase
Future<void> uploadLocation() async {
  final userDatabase = database.child('users/${user?.uid ?? 'unknown'}');

  if (isTrackingLocation && currentLocation != null) { 
    await userDatabase.update({
      'location': {
        'latitude': currentLocation!.latitude,
        'longitude': currentLocation!.longitude,
        'speed': currentLocation!.speed
      },
    });
   
  }
}

  //this for location share button
  void toggleLocationTracking() {
    setState(() {
      isTrackingLocation = !isTrackingLocation;
    });

    if (isTrackingLocation) {
      updateLocation();
      updateBusMessage(selectedMessage);
    } else {
      setState(() {
        currentLocation = null;
      });
      
    }
  }

  //signout function from account model
  Future<void> signOut() async {
    await Account().signOut();
  }

 //widget locationbutton
  Widget _toggleLocationButton() {
    return ElevatedButton(
      onPressed: toggleLocationTracking,
      child: Text(isTrackingLocation ? 'Stop Sharing' : 'Share Location'),
    );
  }

  //signout button widget
  Widget _signOutButton() {
    return ElevatedButton(
      onPressed: signOut,
      child: const Text('Sign Out'),
    );
  }
  
  //location text widget
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

  //email text widget
  Widget _UserEmail() {
    return Text(
      user?.email ?? '',
      style: const TextStyle(fontSize: 16),
    );
  }

  //dropdown button widget
 Widget _buildMessageDropdown() {
  List<String> messageOptions = ['To NSBM', 'Delay', 'Emergency','From NSBM'];

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


  //ui
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

  //bottomnavbar 
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
          "Licence Plate Number : $blpnum",
        
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
