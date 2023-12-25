import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shuttle_v1/ui/map_ui.dart';

class StudUi extends StatefulWidget {
  const StudUi({super.key});

  @override
  State<StudUi> createState() => _StudUiState();
}

class _StudUiState extends State<StudUi> {
  final database = FirebaseDatabase.instance.ref();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Portal')),
      body: FirebaseAnimatedList(
        key: widget.key,
        query: database.child('/users').orderByChild('status').equalTo(1),
        itemBuilder: (BuildContext context, DataSnapshot snapshot,
            Animation<double> animation, int index) {
          if (snapshot.child('status').value == 1) {
            return SizeTransition(
              sizeFactor: animation,
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.directions_bus),
                  title: Text('${snapshot.child('blpnumber').value}'),
                  tileColor: Colors.white,
                  subtitle: Text(
                      '${snapshot.child('dest').value} - ${snapshot.child('root').value}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MapUi(uid: snapshot.key ?? "")),
                    );
                  },
                ),
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}
