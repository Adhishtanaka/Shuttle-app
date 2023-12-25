import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class DetailsUi extends StatefulWidget {
  final String uid;

  const DetailsUi({super.key, required this.uid});

  @override
  State<DetailsUi> createState() => _DetailsUiState();
}

class _DetailsUiState extends State<DetailsUi> {
  final database = FirebaseDatabase.instance.ref();

  String blpNumber = "";
  String dContact = "";
  String oContact = "";
  String destination = "";
  String route = "";

  @override
  void initState() {
    super.initState();
    fetchBusDetails();
  }

Future<void> fetchBusDetails() async {
  final busSnapshot = await database.child('users/${widget.uid}').get();

  if (busSnapshot.value != null) {
    final Map<dynamic, dynamic>? busData = busSnapshot.value as Map<dynamic, dynamic>?;

    if (busData != null) {
      setState(() {
        blpNumber = busData['blpnumber'];
        dContact = busData['dcontact'];
        oContact = busData['ocontact'];
        destination = busData['dest'];
        route = busData['root'];
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shuttle Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('License Plate Number: $blpNumber'),
            const SizedBox(height: 8.0),
            Text('Driver Contact: $dContact'),
            const SizedBox(height: 8.0),
            Text('Owner Contact: $oContact'),
            const SizedBox(height: 8.0),
            Text('Destination: $destination'),
            const SizedBox(height: 8.0),
            Text('Route: $route'),
          ],
        ),
      ),
    );
  }
}
