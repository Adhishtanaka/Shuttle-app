import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:shuttle_v1/ui/map_ui.dart';

class StudUi extends StatefulWidget {
  const StudUi({Key? key}) : super(key: key);

  @override
  State<StudUi> createState() => _StudUiState();
}

class _StudUiState extends State<StudUi> {
  final database = FirebaseDatabase.instance.ref();
  int _selectedIndex = 0;

  //ui
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Portal')),
      body: _selectedIndex == 0 ? _buildComeList() : _buildGoList(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_upward),
            label: 'To NSBM',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.arrow_downward),
            label: 'From NSBM',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
  //bottom navpage1
  Widget _buildComeList() {
    return FirebaseAnimatedList(
      query: database.child('/users').orderByChild('status').equalTo(1),
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int index) {
        if (snapshot.child('status').value == 1 && snapshot.child('message').value != "From NSBM") {
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
                      builder: (context) =>
                          MapUi(uid: snapshot.key ?? ""),
                    ),
                  );
                },
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

 //bottomnav page 2
  Widget _buildGoList() {
    return FirebaseAnimatedList(
      query: database.child('/users').orderByChild('status').equalTo(1),
      itemBuilder: (BuildContext context, DataSnapshot snapshot,
          Animation<double> animation, int index) {
        if (snapshot.child('status').value == 1 && snapshot.child('message').value == "From NSBM") {
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
                      builder: (context) =>
                          MapUi(uid: snapshot.key ?? ""),
                    ),
                  );
                },
              ),
            ),
          );
        } else {
          return Container();
        }
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}
